# POS Mobile App — Backend Endpoints Reference

Covers: Setup Screen, Update Screen, Collections flow, Transaction History / Details.
Grounded in source code (file:line cited); no endpoint here is assumed or guessed.

---

## 1. Setup Screen → Device Registration

**Service:** `gp_pos_tms`
**Route:** `POST /v1/pos/register`
**Auth:** none (public, device-facing)
**Gateway:** `gp_gateway` proxies `/api/v1/*` → `gp_pos_tms` `/v1/*`
**Source:** `gp_pos_tms/internal/controllers/pos_devices/pos_devices_controller.go:19-61`, DTO `gp_pos_tms/internal/models/dto.go:14-37`

### Request body

```json
{
  "serial_number": "string, required",
  "name": "string, required",
  "finger_print": "string, required",
  "description": "string, optional",
  "device_model": "string, optional",
  "operating_system": "string, optional",
  "phone_number_1": "string, optional",
  "phone_number_2": "string, optional",
  "device_identification_number": "string, optional",
  "terminal_type_id": "string (uuid), optional",
  "merchant_id": "string (uuid), optional",
  "merchant_email": "string, optional",
  "merchant_name": "string, optional",
  "current_app_version": "string, optional",
  "latitude": "string, optional",
  "longitude": "string, optional"
}
```

> Note: only `serial_number`, `name`, and `finger_print` are enforced (`binding:"required"`). `device_model`, `terminal_type_id`, and `merchant_id` are accepted but never validated against the terminal-types catalog or an existing merchant — a client can submit blank/fake values for these and the record is still created.

### Responses

**201 Created — new device registered**
```json
{
  "success": true,
  "message": "created",
  "data": { "device_id": "3e2f6b9a-....-uuid" }
}
```
(`utils.RespondWithCreated`, `pos_devices_controller.go:59`)

**409 Conflict — serial number already registered (upsert path)**
```json
{
  "success": false,
  "message": "device already registered",
  "data": { "device_id": "3e2f6b9a-....-uuid" }
}
```
(`pos_devices_controller.go:50-57`)

**400 Bad Request — missing required field**
```json
{ "success": false, "message": "<validation error text>" }
```

**500 Internal Server Error** — DB/registration failure
```json
{ "success": false, "message": "<error text>" }
```

---

## 2. Update Screen → OTA Check-Update

**Service:** `gp_pos_tms`
**Route:** `POST /v1/apps/check-update`
**Auth:** none (public, device-facing)
**Gateway:** `/api/v1/apps/check-update` → `gp_pos_tms` `/v1/apps/check-update`
**Source:** `gp_pos_tms/internal/controllers/apps/apps_controller.go:180-206`, DTO `gp_pos_tms/internal/models/dto.go:147-161`

### Request body

```json
{
  "app_id": "string, optional",
  "app_name": "string, optional",
  "version": "string, required",
  "terminal_type_id": "string, optional"
}
```

### Responses

**200 OK**
```json
{
  "success": true,
  "data": {
    "update_available": true,
    "latest_version": "2.4.0",
    "download_url": "https://.../app-2.4.0.apk",
    "release_notes": "Bug fixes and performance improvements"
  }
}
```
`update_available: false` → `latest_version`, `download_url`, `release_notes` are omitted (`omitempty`) since the client's version is already current.

**400 Bad Request** — missing `version`, or app/terminal-type lookup failure
```json
{ "success": false, "message": "<error text>" }
```

---

## 3. Collections Flow (Lookup → Confirm → Poll)

**Service:** `gp-payment-orchestration`
**Auth:** ⚠️ **Merchant API key/secret bearer token** (obtained via `POST /oauth/token` with `client_id`/`client_secret`) — **not** a `gp_auth` user/session JWT. A cashier's app-login token from `/auth/login` cannot call these directly; the app needs a separately provisioned merchant API credential.
**Gateway:** proxied at `/api/v2/mobile-money/...` and `/api/v2/name-lookup/...`, rewritten internally to the service's own `/api/v1/...` (`gp_gateway/internal/api/server.go:866-896`)

### 3a. Lookup — Name Lookup

**Route:** `GET /api/v1/name-lookup/:phone` (live) — gateway: `GET /api/v2/name-lookup/:phone`
**Source:** `gp-payment-orchestration/internal/modules/merchantapis/lookup.go:41-148`, route `merchant_api_routes.go:137`

Validates phone number is ≥12 digits and belongs to a supported provider before dispatching an RPC to `gp-mno-service`.

**200 OK — success**
```json
{
  "code": 200,
  "status": "success",
  "message": "<provider message>",
  "data": {
    "phone_number": "260956587842",
    "provider": "mtn",
    "status": "success",
    "names": "JOHN BANDA",
    "message": "Lookup successful",
    "processed_at": "2026-06-29T08:13:06Z"
  }
}
```

**400 Bad Request** — invalid phone format / unsupported provider / merchant not found
```json
{ "code": 400, "status": "error", "message": "Invalid phone number format. Phone number must be at least 12 digits long (e.g., 260XXXXXXXXX)." }
```

**500** — MNO service unreachable or response unparseable
```json
{ "code": 500, "status": "error", "message": "Failed to contact MNO service: <detail>" }
```

### 3b. Confirm / Submit — Mobile Money Collection

**Route:** `POST /api/v1/mobile-money/collect` (live) — gateway: `POST /api/v2/mobile-money/collect`
**Source:** `gp-payment-orchestration/internal/modules/merchantapis/collection.go:38-290`, route `merchant_api_routes.go:98`

### Request body

```json
{
  "client_id": "string",
  "merchant_id": "string",
  "phone_number": "260956587842",
  "amount": 100.00,
  "transaction_ref": "string, required, must be unique",
  "callback_url": "string, optional",
  "branch_id": "string, optional (POS attribution)",
  "pos_device_id": "string, optional (POS attribution)",
  "user_id": "string, optional (POS attribution — cashier)"
}
```

Validation order: `transaction_ref` required → `phone_number` ≥12 digits → `amount` > 0 → `client_id` resolves to a merchant → fee calculation → transaction record created → provider resolved from phone prefix → dispatched to MNO async.

### Responses

**200 OK — accepted and forwarded to MNO**
```json
{
  "code": 200,
  "status": "success",
  "message": "Collection request forwarded to MNO service and is now processing",
  "data": {
    "transaction_ref": "...",
    "phone_number": "260956587842",
    "amount": 100.00,
    "currency": "ZMW",
    "provider": "zamtel",
    "external_reference": "V406HWGD",
    "status": "pending",
    "processed_at": "2026-06-29T08:13:06Z"
  }
}
```

**202 Accepted — dispatched but MNO outcome unknown (timeout/parse failure)**
```json
{
  "code": 202,
  "status": "pending",
  "message": "Collection recorded; MNO dispatch outcome is being confirmed",
  "data": { "transaction_reference": "<transaction_ref>" }
}
```
(`collection.go:292-299` — this is not a failure; the transaction stays pending for later resolution.)

**400 Bad Request** — validation failure, invalid client_id, fee calculation rejection, unsupported provider, or transaction creation failure
```json
{ "code": 400, "status": "failed", "message": "<reason, e.g. 'Amount must be greater than 0'>" }
```

### 3c. Poll — Check Collection Status

**Route:** `GET /api/v1/mobile-money/check-status/:transaction_ref` (live) — gateway: `GET /api/v2/mobile-money/check-status/:transaction_ref`
**Source:** `gp-payment-orchestration/internal/modules/merchantapis/collection.go:301-330`, struct `auth.go:49-61`, route `merchant_api_routes.go:138`

Request has no body; `transaction_ref` is a path param, `client_id` is taken from the authenticated caller context.

**200 OK**
```json
{
  "status": "successful",
  "code": 200,
  "message": "<status message>",
  "data": { "...transaction detail fields..." }
}
```
`status` reflects the underlying transaction's current state (e.g. `pending`, `successful`, `failed`) as returned by `gp_transactions_service`'s `transactions.check_status` RPC.

**Error** — RPC failure returns a Go error to the caller (mapped to an error response by the handler layer, not shown in this file — not asserted here since the wrapping HTTP handler wasn't inspected in this pass).

> ⚠️ No real-time/WebSocket alternative exists. `gp_transactions_service` and `gp-payment-orchestration` both contain an unused Socket.IO instance (dead code, never wired to a route) — polling is the only working mechanism today.

---

## 4. Transaction History & Details

**Service:** `gp_transactions_service`
**Auth:** session JWT (merchant or admin claims) — `requireAny` at service level; gateway additionally applies `authorizeAdminFinancialFeature` permission check
**Gateway:** `api.Any("/transactions/*path", ...)` (`gp_gateway/internal/api/server.go:1039-1054`)
**Source:** `gp_transactions_service/internal/api/handlers/transactions.go`

### 4a. List — Transaction History

**Route:** `GET /transactions/list`
**Source:** `transactions.go:36-68`, filters parsed at `transactions.go:292-316`

### Query parameters (all optional)

| Param | Notes |
|---|---|
| `page`, `page_size` | default `page=1`, `page_size=10` |
| `status` | e.g. `successful`, `failed`, `pending` |
| `source` | `pos` or `online` only — anything else ignored |
| `is_from_pos` | bool |
| `pos_device_id` | scope to one POS terminal |
| `branch_id`, `user_id` | scope to branch/cashier |
| `amount`, `currency` | |
| `payment_channel_id`, `transaction_type_id`, `sub_transaction_type_id` | |
| `external_reference`, `transaction_reference` | |
| `customer` | |
| `settlement_status`, `settlement_id` | |
| date range (via `reporting.DateRangeFromQuery`) | |

### Response — 200 OK

```json
{
  "success": true,
  "message": "Transactions fetched successfully",
  "data": {
    "data": { "transaction": [ { "...transaction row fields..." } ], "total": 42 },
    "status_counts": { "successful": 30, "failed": 5, "pending": 7 },
    "cards": { "...summary tiles..." },
    "meta": { "page": 1, "page_size": 10, "total": 42, "returned": 10 }
  }
}
```
(`transactions.go:62-67`)

**500 Internal Server Error**
```json
{ "success": false, "message": "<error text>" }
```

### 4b. Details — Single Transaction

**Route:** `GET /transactions/get/:id`
**Source:** `transactions.go:318-330`

### Response — 200 OK
```json
{
  "success": true,
  "message": "Transaction fetched successfully",
  "data": { "data": { "...full transaction detail row..." } }
}
```

**400 Bad Request** — missing `id` path param
```json
{ "success": false, "message": "ID is required" }
```

**500 Internal Server Error**
```json
{ "success": false, "message": "<error text>" }
```

> No "cashier summary" aggregate endpoint exists in this service — only merchant-wide dashboard summaries (`/transactions/dashboard/summary`, `/dashboard/today`), which are not scoped to an individual agent/cashier.

---

## Open gaps for this mobile app (not covered above — flagged for follow-up)

- No dedicated POS-agent login endpoint (`api/pos/login`) exists anywhere; only `gp_auth-main`'s generic `/auth/login`.
- The Collections endpoints require a merchant API key/secret, which is a different credential than a cashier's session login token — needs a decision on how the app authenticates to this flow.
- Packages/vouchers flow has no backend implementation anywhere in the codebase.
