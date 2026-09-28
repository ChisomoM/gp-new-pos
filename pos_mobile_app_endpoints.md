# POS Mobile App — Backend Endpoints Reference

Covers: Setup Screen, Update Screen, Collections flow, Transaction History / Details.
Grounded in source code (file:line cited); no endpoint here is assumed or guessed.

---

## 0. Login — how the POS app gets the session token

Every "session-token route" in this doc (§2a, §2b, §2c) needs a token from this endpoint first. **There is no dedicated POS/agent login endpoint** (`api/pos/login` does not exist anywhere in the backend) — the POS app must authenticate through `gp_auth-main`'s generic user login, the same one merchants and other staff use.

**Service:** `gp_auth-main`
**Route:** `POST /auth/login`
**Auth:** none (public)
**Gateway:** `POST /api/auth/login` (listed in `isPublicGatewayRoute`, so the gateway does not require a session for this call — obviously, since it's what issues one)
**Source:** route `gp_auth-main/cmd/routes.go:52`, handler `gp_auth-main/internal/modules/users/auth_handler.go:71-172`

A cashier is a normal `gp_auth-main` user with `account_type = agent` (seeded example: `gp_auth-main/cmd/seed_merchants.go:74-76`) — there's no separate cashier identity system, just a user row scoped to a merchant.

### ⚠️ This is a two-step, OTP-gated login by default

Unless the email is in the `SKIP_OTP_EMAILS` env allowlist (`auth_service.go:579-581`), a plain email+password call does **not** return a token — it triggers an emailed one-time code, and the client must call the same endpoint again with that code. A mobile POS app has to implement this two-step flow (or the merchant's cashier emails must be added to `SKIP_OTP_EMAILS` to skip it, which is an environment/ops decision, not a code one).

**Step 1 — Request body**
```json
{ "email": "cashier@merchant.com", "password": "string" }
```

**Step 1 — Response, 200 OK (OTP sent, no token yet)**
```json
{ "mfa_required": true, "message": "verification code sent to your email" }
```

**Step 2 — Request body (resubmit with the code from the email)**
```json
{ "email": "cashier@merchant.com", "password": "string", "otp": "123456" }
```

**Step 2 — Response, 200 OK (`AuthenticatedUser`, source: `gp_auth-main/internal/common/structs.go:19-34`)**
```json
{
  "user": { "...user record..." },
  "token": "eyJhbGciOi....<JWT access token>",
  "refresh_token": "eyJhbGciOi....<JWT refresh token>",
  "session_id": "string",
  "access_expiration": 1735142400,
  "refresh_expiration": 1737734400,
  "account_type": "agent",
  "merchant_id": "3e2f6b9a-....-uuid",
  "is_sandbox_enabled": false,
  "user_id": "string",
  "roles": {},
  "permissions": ["..."]
}
```
`token` is the session JWT — send it as `Authorization: Bearer <token>` on every §2/§3 request in this doc. `merchant_id` in this response is exactly what `resolveSessionMerchantID` later reads back out of the token's claims server-side for collect/check-status/name-lookup (§2b/§2c/§2a) — it is not something the app needs to send itself.

**400/401** — invalid credentials, bad/expired OTP
```json
{ "error": "<reason>" }
```
(exact shape from `writeLoginError`/`writeOTPDeliveryError`, not fully traced in this pass)

**Companion:** `POST /auth/reset-password` (gateway: `/api/auth/reset-password`, also public) for the Reset Password screen — not detailed here since it wasn't part of this doc's original scope.

---

## 1. Update Screen → OTA Check-Update

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

## 2. Collections Flow (Lookup → Confirm → Poll)

Two auth modes now exist side by side. Use the **session-token** routes for the POS mobile app — they were added specifically so a cashier's normal login token is enough, with no merchant API key/secret embedded in the app.

### 2a. Lookup — Name Lookup ✅ session-token route

**Route:** `GET /api/name-lookup/:phone`
**Auth:** session JWT (the cashier's normal login token) — gateway rewrites to `GET /api/v1/dashboard/name-lookup/:phone`
**Source:** handler `gp-payment-orchestration/internal/api/handlers/merchant_api_handlers/dashboard_handlers.go` (`HandleDashboardNameLookupHandler`), route `merchant_api_routes.go` (`/api/v1/dashboard` group), gateway wiring `gp_gateway/internal/api/server.go:776-786`

Same pattern as collect/check-status: `merchant_id` is resolved from the session claims (never from a client-supplied field), then the merchant's live API `client_id` is resolved server-side before the lookup runs. This route pre-dates the collections work — it was originally built for the admin dashboard's "look up a name before a manual disbursement" flow, but is equally usable by the POS app since it's already session-gated end to end.

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

**400 Bad Request** — invalid phone format / unsupported provider / merchant not found / no live API key on the merchant
```json
{ "code": 400, "status": "error", "message": "Invalid phone number format. Phone number must be at least 12 digits long (e.g., 260XXXXXXXXX)." }
```

**401 Unauthorized** — session does not identify a merchant
```json
{ "message": "session does not identify a merchant" }
```

**500** — MNO service unreachable or response unparseable
```json
{ "code": 500, "status": "error", "message": "Failed to contact MNO service: <detail>" }
```

> A merchant-API-key variant of this same operation also exists at `GET /api/v1/name-lookup/:phone` (`gp-payment-orchestration/internal/modules/merchantapis/lookup.go:41-148`), used by non-POS integrators. The POS app should use the session route above, not this one.

### 2b. Confirm / Submit — Mobile Money Collection ✅ session-token route

**Route:** `POST /api/mobile-money/collect`
**Auth:** session JWT (the cashier's normal login token) — gateway rewrites to `POST /api/v1/dashboard/mobile-money/collect`
**Source:** handler `gp-payment-orchestration/internal/api/handlers/merchant_api_handlers/dashboard_handlers.go` (`HandleDashboardCollectionHandler`), route `merchant_api_routes.go` (`/api/v1/dashboard` group), gateway wiring `gp_gateway/internal/api/server.go` (added next to the existing name-lookup rewrite)

Resolves the caller's `merchant_id` from their verified session claims (never from a client-supplied field), then resolves that merchant's live API `client_id` server-side and runs the same fee-calculation → transaction-create → MNO-dispatch logic as the merchant-API-key path.

### Request

**Header:** `X-Transaction-Ref: <string, required, unique>`

**Body:**
```json
{
  "phone_number": "260956587842",
  "amount": 100.00,
  "branch_id": "string, optional (POS attribution)",
  "pos_device_id": "string, optional (POS attribution)",
  "user_id": "string, optional (POS attribution — cashier)",
  "simulate_result": "string, sandbox-only, optional"
}
```
`phone_number` must be exactly 12 digits.

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
This is not a failure — the transaction stays pending for later resolution.

**400 Bad Request** — missing `X-Transaction-Ref`, invalid phone, amount ≤ 0, no live API key on the merchant, fee-calculation rejection, or unsupported provider
```json
{ "code": 400, "status": "failed", "message": "<reason>" }
```

**401 Unauthorized** — session does not identify a merchant
```json
{ "code": 401, "message": "session does not identify a merchant" }
```

### 2c. Poll — Check Collection Status ✅ session-token route

**Route:** `GET /api/mobile-money/check-status/:transaction_ref`
**Auth:** session JWT — gateway rewrites to `GET /api/v1/dashboard/mobile-money/check-status/:transaction_ref`
**Source:** handler `dashboard_handlers.go` (`HandleDashboardCollectionCheckStatusHandler`)

Request has no body; `transaction_ref` is a path param, `client_id` is resolved server-side from the session (same as §2b).

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

**400 Bad Request** / **422** — missing `transaction_ref`, or RPC failure
```json
{ "code": 400, "status": "failed", "message": "<error text>" }
```

> ⚠️ No real-time/WebSocket alternative exists. `gp_transactions_service` and `gp-payment-orchestration` both contain an unused Socket.IO instance (dead code, never wired to a route) — polling is the only working mechanism today.

**Precondition carried over from disbursement:** the merchant must already have a live API key provisioned (`merchantapikeys.ResolveLiveClientID` — the session route resolves it server-side, but the key row itself still has to exist). If disbursement already works for a merchant today, collections now works the same way.

---

## 3. Transaction History & Details

**Service:** `gp_transactions_service`
**Auth:** session JWT (merchant or admin claims) — `requireAny` at service level; gateway additionally applies `authorizeAdminFinancialFeature` permission check
**Gateway:** `api.Any("/transactions/*path", ...)` (`gp_gateway/internal/api/server.go:1039-1054`)
**Source:** `gp_transactions_service/internal/api/handlers/transactions.go`

### 3a. List — Transaction History

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

### 3b. Details — Single Transaction

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
- ~~Collections requires a merchant API key/secret~~ — **resolved**: `POST /api/mobile-money/collect` and `GET /api/mobile-money/check-status/:transaction_ref` now accept the caller's login session token directly (see §3b/3c).
- Packages/vouchers flow has no backend implementation anywhere in the codebase.
