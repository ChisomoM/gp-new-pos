# POS Mobile App — Backend Endpoints Reference

Covers: Setup Screen, Update Screen, Collections flow, Transaction History / Details.
Grounded in source code (file:line cited); no endpoint here is assumed or guessed.

---

## Suggested end-to-end flow

This stitches the sections below into the order a POS app would actually call them. Each step names the section with the full request/response detail.

1. **First launch — register the device.** §1 `POST /v1/pos/register` — quick form (name, serial number, terminal type, optional phone), leaves the device **unassigned** (`merchant_id = null`). Safe to call again on relaunch — a duplicate serial/fingerprint just returns the existing device instead of erroring.
2. **Cashier logs in.** §0a `POST /auth/pos/login` — email + password, no OTP, returns a 16h token + `merchant_id`. This is the token used for every step below.
3. **Resolve the device's branch.** `GET /v1/pos/devices/:id` (bearer token from step 2) — not fully detailed in this doc, but returns the device's current `branch_id`. If `null`, call §0c `GET /merchants/branches` to populate a branch picker and let the cashier choose one; if already set, skip straight to step 5.
4. **Claim the device, if unassigned.** `PUT /v1/pos/devices/:id` (same bearer token) — only needed if step 1 registered the device without a `merchant_id`. Auto-assigns it to the logged-in merchant; also where the branch chosen in step 3 gets written.
5. **Check for a forced update.** §2 `POST /v1/apps/check-update` — call once after login (and optionally periodically) so a device isn't left on a stale build.
6. **Cashier picks a flow from Home/Mode screen** → either **Collections** (§3a name lookup → §3b submit collection → §3c poll status until `successful`/`failed` or timeout) or **Payment Link** (§5a create → show the QR the app renders from `checkout_url` → §5b poll until `paid`/`failed`/`expired`, while the customer pays on their own phone).
7. **Transaction History / Details** (§4) — available any time after login, independent of the collections/payment-link flows above.
8. **Background, no screen:** heartbeat/location pings (`POST /v1/pos/devices/heartbeat`, `POST /v1/pos/locations` — public, not detailed in this doc) keep the device's online status and location fresh regardless of which screen is active.

Token lifetime note: since §0a's token lasts 16h with no refresh, the app should treat token expiry as "return to Login screen," not "silently retry" — there's no background renewal path for POS sessions.

---

## 0. Login — how the POS app gets the session token

Every "session-token route" in this doc (§0c, §3a, §3b, §3c) needs a token from this endpoint first. There is now a **dedicated POS login endpoint** — use this one, not the generic one described further down.

### 0a. POS login ✅ use this one

**Service:** `gp_auth-main`
**Route:** `POST /auth/pos/login`
**Auth:** none (public)
**Gateway:** `POST /api/auth/pos/login` (listed in `isPublicGatewayRoute`)
**Source:** route `gp_auth-main/cmd/routes.go:52-53`, handler `HandleAuthHandler.LoginPOS` (`gp_auth-main/internal/modules/users/auth_handler.go`), service `AuthService.IssuePOSSession` / `GenerateMerchantPOSToken` (`gp_auth-main/internal/modules/users/auth_service.go`)

Same credential check as the generic login (email + password against a `gp_auth-main` user), but built specifically for a POS terminal:
- **No OTP.** Single request, no emailed code, no two-step round trip — matches how the old POS system worked.
- **One 16-hour access token, no refresh token.** The terminal logs in once per shift and stays authenticated for it; there's no silent background refresh like the merchant dashboard has. `refresh_token` will simply be absent from the response (see the caveat below).
- **Merchant-linked accounts only.** If the authenticated user has no merchant association at all, this endpoint returns `401` rather than issuing a token — a POS login has to resolve to a merchant, unlike the generic login which falls back to a bare user session.

**Request body**
```json
{ "email": "cashier@merchant.com", "password": "string" }
```

**200 OK (`AuthenticatedUser`, source: `gp_auth-main/internal/common/structs.go:19-34`)**
```json
{
  "user": { "...user record..." },
  "token": "eyJhbGciOi....<JWT access token, 16h>",
  "session_id": "string",
  "access_expiration": 1735142400,
  "account_type": "merchant",
  "merchant_id": "3e2f6b9a-....-uuid",
  "is_sandbox_enabled": false,
  "user_id": "string",
  "roles": {},
  "permissions": ["..."]
}
```
`refresh_token` and `refresh_expiration` are omitted (`omitempty`) — not an error, just not applicable to POS sessions. `token` is what goes in `Authorization: Bearer <token>` on every §3/§4 request in this doc; `merchant_id` is exactly what those routes resolve server-side from the token's claims, not something the app sends itself.

**401** — invalid credentials, account locked/suspended, or no merchant linked to this account
```json
{ "error": "<reason>", "error_code": "<code>" }
```

**400** — malformed request body
```json
{ "error": "invalid request", "error_code": "invalid_request" }
```

**Branch and device claiming are deliberately not part of this response** — per the earlier Option B decision, the app resolves those with two calls it already has everything for, right after login: `GET /v1/pos/devices/:id` (returns the device's current `branch_id`, or `null` if unset — show a branch picker in that case) and, if the device is unassigned, `PUT /v1/pos/devices/:id` (auto-claims it to the logged-in merchant). Both already exist and are covered by §3's session-token pattern; no `gp_pos_tms` changes were needed for this.

### 0b. Generic login (not for the POS app)

The original merchant/staff login still exists at `POST /auth/login` (gateway: `/api/auth/login`) and is what the POS-specific endpoint above was built from — kept here for reference, not because the app should use it.

**Source:** route `gp_auth-main/cmd/routes.go:52`, handler `gp_auth-main/internal/modules/users/auth_handler.go:71-172`

A cashier is a normal `gp_auth-main` user with `account_type = agent` (seeded example: `gp_auth-main/cmd/seed_merchants.go:74-76`) — there's no separate cashier identity system, just a user row scoped to a merchant. This route is a **two-step, OTP-gated login** by default (unless the email is in the `SKIP_OTP_EMAILS` allowlist, `auth_service.go:579-581`): a plain email+password call returns `{ "mfa_required": true, ... }` and sends an emailed code, and the client must resubmit with `"otp": "123456"` to get a token — the two-step friction the POS-specific endpoint above exists to avoid. It also returns both an access token (30 min) and a refresh token (24h), rather than POS's single 16h token.

**Companion:** `POST /auth/reset-password` (gateway: `/api/auth/reset-password`, also public) for the Reset Password screen — not detailed here since it wasn't part of this doc's original scope.

### 0c. Branch Picker — List Merchant Branches

**Service:** `gp_auth-main`
**Route:** `GET /merchants/branches`
**Auth:** session JWT from §0a — same token, same `MerchantAuthenticator` middleware as every other `/merchants/*` route. No separate credential.
**Gateway:** `GET /api/merchants/branches` (gateway rewrites `/merchants/*path` → `gp_auth-main`'s `/auth/merchants*path`, i.e. `/auth/merchants/branches`)
**Source:** route `gp_auth-main/cmd/routes.go:153-154`, handler `branches.Handler.List` (`gp_auth-main/internal/modules/branches/handler.go:46-59`), service `branches.Service.ListBranches` (`gp_auth-main/internal/modules/branches/services.go:94-101`), gateway wiring `gp_gateway/internal/api/server.go:691-693`, gateway permission gate `gp_gateway/internal/api/server.go:167-168`

**Scoping:** fully automatic — `merchant_id` is read out of the token claims by `MerchantAuthenticator` (`claims.MerchantID`, falling back to `claims.ID` for a merchant-owner token) and injected into the request context; the app never sends a `merchant_id` param. There is no `branch_id` filter — this always returns the full list for the caller's own merchant.

**Request:** no body, no query params required. Optional: `?limit=&offset=` (uint) to page, `?is_active=true` to filter to active branches only (`handler.go:346-366`). No `page`/`page_size` params — pagination here is raw limit/offset, not the `page`/`page_size` shape used elsewhere in this doc (§4a).

**Response shape — ⚠️ not the usual envelope.** Unlike every other route in this doc, this is `gp_auth-main`, and `common.WriteJSON` returns the branches array **directly as the response body** — no `{ "success": true, "data": [...] }` wrapper (`common/http.go:9-25`, `branches/handler.go:58`). The picker should parse a bare JSON array on 200.

**200 OK**
```json
[
  {
    "id": "3e2f6b9a-....-uuid",
    "merchant_id": "8a1c....-uuid",
    "name": "Cairo Road Branch",
    "code": "CR01",
    "description": "",
    "address": "Cairo Road, Lusaka",
    "latitude": -15.4167,
    "longitude": 28.2833,
    "is_active": true,
    "member_count": 4
  }
]
```
(`models.go:86-97`, `BranchSummary`) — `id` and `name` are the two fields a minimal picker needs; `code`, `address`, `latitude`/`longitude`, `member_count` are all `omitempty` and may be absent. No pagination metadata (no `total`) comes back with the list — if you pass `limit`, you get at most that many rows with no way to know how many more exist beyond calling again with `offset`.

**200 OK — merchant has zero branches**
```json
[]
```
An empty array, not a 404 or an error. **The Setup/post-login flow should treat this as "skip the picker" and leave the device unassigned to a branch** (`PUT /v1/pos/devices/:id` with no `branch_id`) rather than blocking login — nothing in `gp_pos_tms` requires a device to have a branch.

**401 Unauthorized** — missing/invalid/expired token, or an admin token used here (this route explicitly rejects `claims.Type == admin`)
```json
{ "error": "<reason>" }
```

**403 Forbidden — two independent causes, both real, both worth handling distinctly:**
1. **Onboarding not complete.** `OnboardingGate` runs on every `/merchants/*` route ahead of the branches handler and blocks any merchant not in `approved`/`active` onboarding state (`internal/api/middleware/onboarding_gate.go:38-49`):
   ```json
   { "status": 1, "message": "onboarding required", "data": { "state": "pending" } }
   ```
2. **Missing RBAC permission on the logged-in user's role.** Two separate layers each enforce their own permission string for this route, and they're spelled differently:
   - The **gateway** requires `merchant.branches.view` to be present in the session token's embedded `permissions` claim (`gp_gateway/internal/api/server.go:167-168`, `catalogCRUDPermission` maps `GET` → `.view`) — rejects with `{ "status": "failed", "message": "Required permission: merchant.branches.view" }` before the request even reaches `gp_auth-main`.
   - `gp_auth-main` itself separately requires `merchant.branches.read` (`cmd/routes.go:154`, `RequirePermissions`) — rejects with `{ "error": "forbidden" }` if somehow reached without the gateway's check (or when calling the service directly, bypassing the gateway).
   
   **⚠️ Flagging this now, not guessing at a fix:** whatever role gets assigned to a cashier/POS account needs *both* `merchant.branches.view` and `merchant.branches.read` granted, or the picker will 403 for some accounts and not others depending on which layer trips first. This isn't a POS-specific bug — every `/merchants/branches` caller hits the same two-permission-string requirement — but it's the kind of thing that's easy to miss when setting up a new role for POS cashiers specifically, since the POS login flow doesn't run through the same "someone manually clicked through the dashboard and already had a working role" path a normal merchant admin does.

**500 Internal Server Error** — DB failure
```json
{ "error": "<message>" }
```

---

## 1. Setup Screen → Device Registration

**Service:** `gp_pos_tms`
**Route:** `POST /v1/pos/register`
**Auth:** none (public, device-facing)
**Gateway:** `gp_gateway` proxies `/api/v1/*` → `gp_pos_tms` `/v1/*`
**Source:** `gp_pos_tms/internal/controllers/pos_devices/pos_devices_controller.go:19-61`, service `gp_pos_tms/internal/services/pos_services/pos_services.go:61-141`, DTO `gp_pos_tms/internal/models/dto.go:14-37`

Per the current planned flow: the Setup screen should stay quick — **Name, Serial Number, Terminal Type, and an optional Phone Number** are the only fields shown to the cashier/installer. The device's fingerprint is *not* a form field — it's collected by the app in the background (Android device ID/model/hardware fingerprint) and sent alongside the visible fields. No merchant context is collected here; the device is registered **unassigned** and gets claimed to a merchant later, during login (see §0a and the Suggested end-to-end flow above).

### What the app sends vs. what the backend actually enforces

| Field | Shown on Setup screen? | Backend requirement |
|---|---|---|
| `name` | ✅ | required |
| `serial_number` | ✅ | required |
| `terminal_type_id` | ✅ | **optional, unvalidated** — accepted even if blank or if it doesn't match any row in the terminal-types catalog |
| `phone_number_1` | ✅ (optional) | optional |
| `finger_print` | not shown — collected automatically | required |
| `merchant_id` / `merchant_email` / `merchant_name` | not sent | optional — omitting them is what leaves the device unassigned |
| everything else (`description`, `device_model`, `operating_system`, `device_identification_number`, `current_app_version`, `latitude`, `longitude`) | not part of this simplified form | all optional |

**⚠️ Gap worth flagging now that Terminal Type is a required-feeling field on the UI:** the backend does not actually require or validate `terminal_type_id` (`binding:"required"` is absent on that field, and unlike registration's terminal-type handling, no catalog lookup happens if it's blank — a catalog lookup only happens for `terminal_type_id` when it's non-empty, and *that* case does fail with a 400 if the ID doesn't exist). Two consequences: (1) if the app fails to send a terminal type for any reason, registration silently succeeds anyway rather than rejecting it — the UI's "required" framing isn't backed by the server; (2) the picker should be populated from the real catalog (`GET /v1/terminal-types`, public) rather than free text, so at least a *sent* value is guaranteed valid.

### Request body

```json
{
  "name": "string, required",
  "serial_number": "string, required",
  "terminal_type_id": "string (uuid), optional — validated only if non-empty",
  "phone_number_1": "string, optional",
  "finger_print": "string, required — collected by the app, not user-entered"
}
```
(Full DTO also accepts `description`, `device_model`, `operating_system`, `phone_number_2`, `device_identification_number`, `merchant_id`, `merchant_email`, `merchant_name`, `current_app_version`, `latitude`, `longitude` — all optional, all omittable for this simplified flow.)

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

**409 Conflict — serial number or fingerprint already registered (upsert path)**
```json
{
  "success": false,
  "message": "device already registered",
  "data": { "device_id": "3e2f6b9a-....-uuid" }
}
```
(`pos_devices_controller.go:50-57`) — safe to treat as success on relaunch: store the returned `device_id` and move on to Login, don't surface this as an error to the cashier.

**400 Bad Request** — missing `name`/`serial_number`/`finger_print`, or a **non-empty** `terminal_type_id` that doesn't exist in the catalog
```json
{ "success": false, "message": "<validation error text>" }
```

**500 Internal Server Error** — DB/registration failure
```json
{ "success": false, "message": "<error text>" }
```

**Companion (optional, for populating the Terminal Type picker):** `GET /v1/terminal-types` — public, returns the real catalog so the app isn't guessing at valid values. Not detailed further here.

---

## 2. Update Screen → OTA Check-Update

**Service:** `gp_pos_tms`
**Route:** `POST /v1/apps/check-update`
**Auth:** none (public, device-facing)
**Gateway:** `/api/v1/apps/check-update` → `gp_pos_tms` `/v1/apps/check-update`
**Source:** `gp_pos_tms/internal/controllers/apps/apps_controller.go`, service `gp_pos_tms/internal/services/app_services/app_services.go`, DTO `gp_pos_tms/internal/models/dto.go`

APK builds are stored in a self-hosted MinIO bucket (same pattern `gp_auth-main` uses for its own file storage); `download_url` is a short-lived (15 min) presigned link straight to that bucket, not proxied through `gp_pos_tms`. Version comparison is real semver (`1.10.0` > `1.9.0`), not exact-string matching.

There are now two independent signals in the response:
- **`update_available`** — a newer build exists than what the device reports. Informational; the app can nudge the user or silently prefetch.
- **`update_required`** — the device's version is below the app's `min_supported_version` (set via `PUT /v1/apps/:id`, see §1's sibling admin endpoint). This is a hard floor — treat it as blocking (force the update screen, don't let the cashier dismiss it) rather than a nudge.

A device can be `update_required: true` with `update_available: false` if there's no newer active/latest-stable version published yet but an admin has raised the minimum anyway (e.g. to kill a broken build) — the app should still block in that case, even though there's nothing new to download.

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

**200 OK — update available/required**
```json
{
  "success": true,
  "data": {
    "update_available": true,
    "update_required": false,
    "latest_version": "2.4.0",
    "download_url": "https://minio.example.com/pos-apks/app-versions/....apk?X-Amz-...(15min TTL)",
    "release_notes": "Bug fixes and performance improvements",
    "file_size_mbytes": 24.5,
    "check_sum": "a1b2c3...(sha256, hex)"
  }
}
```

**200 OK — already current**
```json
{
  "success": true,
  "data": { "update_available": false, "update_required": false }
}
```
`latest_version`, `download_url`, `release_notes`, `file_size_mbytes`, `check_sum` are all omitted (`omitempty`) when there's nothing to report for that field — e.g. `update_required` can be `true` alone (see the no-newer-build case above), with `download_url` still present pointing at the current latest-stable build.

**400 Bad Request** — missing `version`, or app/terminal-type lookup failure
```json
{ "success": false, "message": "<error text>" }
```

**500 Internal Server Error** — APK storage (MinIO) is unconfigured or unreachable when a download URL is needed
```json
{ "success": false, "message": "<error text>" }
```

### Admin: publishing a new version (context, not a POS-app call)

`POST /v1/app-versions` (bearer, admin/dashboard only) is now a **multipart upload** — `file` is the APK itself; `app_id`, `version_number`, `release_notes`, `is_active`, `is_latest_stable`, `terminal_type_id` are form fields alongside it. `file_size_mbytes` and `check_sum` are computed server-side from the upload and can no longer be supplied by the caller. Setting `min_supported_version` on the app (`PUT /v1/apps/:id`) is what turns on `update_required` for devices below it — publishing a version does not by itself force anyone to upgrade.

---

## 3. Collections Flow (Lookup → Confirm → Poll)

Two auth modes now exist side by side. Use the **session-token** routes for the POS mobile app — they were added specifically so a cashier's normal login token is enough, with no merchant API key/secret embedded in the app.

### 3a. Lookup — Name Lookup ✅ session-token route

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

### 3b. Confirm / Submit — Mobile Money Collection ✅ session-token route

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

### 3c. Poll — Check Collection Status ✅ session-token route

**Route:** `GET /api/mobile-money/check-status/:transaction_ref`
**Auth:** session JWT — gateway rewrites to `GET /api/v1/dashboard/mobile-money/check-status/:transaction_ref`
**Source:** handler `dashboard_handlers.go` (`HandleDashboardCollectionCheckStatusHandler`)

Request has no body; `transaction_ref` is a path param, `client_id` is resolved server-side from the session (same as §3b).

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

## 5. Payment Link (Hosted Checkout) — session-token route

**This already exists end to end — no new backend work was needed, only wiring the POS app to it.** Same session-token pattern as Collections (§3): the cashier's normal login token is enough, no merchant API key/secret in the app.

### 5a. Create — Generate Payment Link

**Route:** `POST /api/payment-links/create`
**Auth:** session JWT (the cashier's normal login token) — gateway rewrites to `POST /api/v1/dashboard/payment-links`
**Source:** handler `HandleDashboardCreatePaymentLinkHandler` (`gp-payment-orchestration/internal/api/handlers/merchant_api_handlers/dashboard_handlers.go:334-405`), route `merchant_api_routes.go:227`, service `merchantapis.CreateHostedCheckoutSessionForMerchant` (`gp-payment-orchestration/internal/modules/merchantapis/hosted_checkout.go`), gateway wiring `gp_gateway/internal/api/server.go:810-817`

Resolves `merchant_id` from the session (same `resolveSessionMerchantID` as every other §3/§5 route), then dispatches a `hosted_checkout.create` RabbitMQ RPC to `gp_transactions_service`, which persists a `HostedCheckoutSession` row and hands back a token + public URL.

**Request**

**Header:** `X-Transaction-Ref: <string, optional>` — if omitted, one is auto-generated as `POS-<first 8 chars of merchant_id>-<timestamp>`.

**Body:**
```json
{
  "amount": 150.00,
  "order_id": "string, optional (defaults to the transaction ref if omitted)",
  "expires_in_minutes": 60,
  "return_url": "string, optional — where the customer lands after paying",
  "callback_url": "string, optional — server-to-server webhook, not the customer redirect",
  "payment_form_id": "string, optional — use a pre-built payment form instead of a bare amount",
  "branch_id": "string, optional (POS attribution)",
  "pos_device_id": "string, optional (POS attribution)",
  "user_id": "string, optional (POS attribution — cashier)",
  "customer": { "email": "string, optional", "phone": "string, optional", "name": "string, optional" }
}
```
`amount` is the only required field. If `payment_form_id` is set, `amount` must match the form's fixed amount (if it has one) or the request is rejected.

### Responses

**200 OK**
```json
{
  "code": 200,
  "status": "success",
  "message": "Hosted checkout session created successfully",
  "data": {
    "checkout_url": "https://<frontend-domain>/checkout/3e2f6b9a-....-token",
    "token": "3e2f6b9a-....-uuid"
  }
}
```
`checkout_url` is a page on the merchant-facing **frontend** (not an API response) — it's a complete hosted checkout UI where the customer enters/confirms their phone number and submits. **There is no QR code in this response.** The dashboard renders its QR client-side from `checkout_url` (a `QRCodeCard` component wrapping the URL string) — the POS app needs to do the same: generate the QR locally on-device from `checkout_url`, don't expect a QR image from the API.

**Calling again with the same `X-Transaction-Ref`** (and the same amount/payment form) returns the **existing** session instead of creating a duplicate — safe to retry on a flaky connection.

**400 Bad Request** — missing/invalid `amount`, `payment_form_id` doesn't resolve to an active form for this merchant, amount mismatch against a fixed-amount form, or a duplicate `X-Transaction-Ref` reused with *different* amount/form details
```json
{ "code": 400, "status": "failed", "message": "<reason>" }
```

**401 Unauthorized** — session does not identify a merchant
```json
{ "message": "session does not identify a merchant" }
```

**⚠️ `cashier_id` attribution was broken until this change:** the orchestration handler was sending the cashier's `user_id` under the RPC payload key `"user_id"`, but `gp_transactions_service`'s consumer reads that field back out as `"cashier_id"` (`hosted_checkout/service.go:33`) — a key mismatch meant `HostedCheckoutSession.CashierID` silently stayed empty on every payment link ever created through this route, regardless of what the POS app sent as `user_id`. Fixed in `gp-payment-orchestration/internal/modules/merchantapis/hosted_checkout.go` (payload now sent as `"cashier_id"`) as part of this doc update — `branch_id` and `pos_device_id` were not affected, their keys already matched.

### 5b. Poll — Hosted Checkout Session Status (optional, for the cashier's own screen)

**Route:** `GET /api/hosted-checkout/sessions/:token`
**Auth:** none (public) — the token in the URL is the credential, same as the customer-facing checkout page uses
**Source:** handler `GetHostedCheckoutSessionHandler` (`gp_transactions_service/internal/api/handlers/hosted_checkout.go:59-78`), route `hosted_checkout.go:219`, gateway wiring `gp_gateway/internal/api/server.go:1187-1191` (public per `isPublicGatewayRoute`, `server.go:1339-1340`)

Not part of the create response's auth flow — this is a *separate*, unauthenticated route, callable with just the `token` from §5a's response. Useful if the cashier's own screen should auto-advance once the customer finishes paying on their phone, without needing another session-token round trip.

**200 OK**
```json
{
  "success": true,
  "message": "Hosted checkout session retrieved successfully",
  "data": {
    "id": "...", "token": "...", "merchant_id": "...",
    "amount": "150.00",
    "status": "pending",
    "expires_at": "2026-06-29T09:13:06Z",
    "created_at": "...", "updated_at": "...",
    "order_id": "...", "transaction_id": ""
  }
}
```
`status` progresses `pending` → `processing` (customer submitted, MNO dispatch in flight) → `paid` / `failed` / `cancelled` / `expired`. Poll this the same way §3c polls collections.

**400 Bad Request** — unknown/expired token
```json
{ "success": false, "message": "<error text>" }
```

> **Not built by this doc's flow, but exists and is worth knowing about:** `POST /api/hosted-checkout/sessions/process` is the route the *customer's* browser calls to actually submit payment on the hosted checkout page — the POS app doesn't call this itself, the customer does, on their own device, from the `checkout_url` page. Documented here only so it's clear the POS app's job stops at "create the link and poll/display its status," not "process the payment on the customer's behalf."

---

## Open gaps for this mobile app (not covered above — flagged for follow-up)

- **Terminal Type on the Setup screen is UI-required but backend-optional/unvalidated when blank** (see §1's gap note) — either loosen the UI's "required" framing to match reality, or tighten the backend to actually require it, so the two don't quietly disagree.
- Packages/vouchers flow has no backend implementation anywhere in the codebase.
- **§0c's RBAC permission split** (`merchant.branches.view` at the gateway vs. `merchant.branches.read` in `gp_auth-main`) needs to be accounted for when a POS-cashier role is defined, or the branch picker will 403 for accounts missing either one.
