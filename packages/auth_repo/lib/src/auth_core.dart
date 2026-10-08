import 'dart:async';
import 'dart:developer';

import 'package:auth_repo/auth_repo.dart';
import 'package:auth_repo/src/constants.dart';
import 'package:auth_repo/src/models/models.dart';
import 'package:local_data/local_data.dart';
import 'package:net_source/net_source.dart';

/// Core authentication operations
class AuthCore {
  AuthCore(this._net, this._prefs, this._db, this._controller);

  final NetSource _net;
  final SharedPrefs _prefs;
  final LocalData _db;
  final StreamController<AuthStatus> _controller;

  static const String _keyId = AuthConstants.keyId;
  static const String _keyToken = AuthConstants.keyToken;
  static const String _keyLoggedIn = AuthConstants.keyLoggedIn;
  static const String _keyDeviceRegistered = AuthConstants.keyDeviceRegistered;
  static const String _keyKioskModeEnabled = AuthConstants.keyKioskModeEnabled;
  static const String _keyKioskStatusVendor =
      AuthConstants.keyKioskStatusVendor;
  static const String _keyKioskStatusSummary =
      AuthConstants.keyKioskStatusSummary;
  static const String _keyKioskStatusAt = AuthConstants.keyKioskStatusAt;
  static const String _tblUsers = AuthConstants.tblUsers;

  Future<void> _initNetworkApi({String? token, String? refreshToken}) async {
    token ??= await _prefs.getString(_keyToken);
    refreshToken ??= await _prefs.getString(AuthConstants.keyCurrentToken);
    final deviceId = await _prefs.getString(AuthConstants.keyDeviceId);
    final appId = await _prefs.getString(AuthConstants.keyAppId);
    _net.init(
      deviceId: deviceId,
      appId: appId,
      token: token,
      refreshToken: refreshToken,
    );
  }

  /// User Registration
  Future<OpStatus> signup(JsonMap body) async {
    try {
      final response = await _net.post('registration', body);
      if (response.isSuccessful()) {
        await _getAndAuthUser(response.data as JsonMap);
      }
      return OpStatus.fromResponse(response);
    } catch (e) {
      log('Error in registration: $e');
      _controller.add(AuthStatus.unauthenticated);
      return OpStatus.unexpected(e.toString());
    }
  }

  /// User Login.
  ///
  /// Uses `gp_auth-main`'s POS-specific login (`POST /auth/pos/login`, see
  /// `pos_mobile_app_endpoints.md` §0a) — a single request, no OTP round
  /// trip, that only succeeds for a merchant-linked account and returns a
  /// 16h access token with no refresh token.
  ///
  /// This endpoint has no `{success, message, data}` envelope — success is
  /// a raw `AuthenticatedUser` object, failure is `{"error": "..."}` — so
  /// it can't use `OpStatus.fromResponse`/`NetResponse.isSuccessful()` like
  /// every other route in this app; the shape is checked directly.
  Future<OpStatus> login(JsonMap body) async {
    try {
      final response = await _net.post('auth/pos/login', body);
      final data = response.data;
      if (data is JsonMap && data['token'] != null) {
        await _getAndAuthUser(data);
        return OpStatus.success('Logged in', data: data);
      }
      final serverError = data is JsonMap ? data['error'] as String? : null;
      return OpStatus.error(
        serverError ?? response.message ?? 'Invalid email or password',
      );
    } catch (e) {
      log('Error in login: $e');
      _controller.add(AuthStatus.unauthenticated);
      return OpStatus.unexpected(e.toString());
    }
  }

  /// Registers this physical device against `gp_pos_tms` (POS terminal
  /// management, see `pos_mobile_app_endpoints.md` §1). Unauthenticated;
  /// the device is registered **unassigned** (no merchant fields sent) and
  /// gets claimed to a merchant during login instead (see [claimPosDevice]).
  ///
  /// Both the `201` (new) and `409` (already registered — safe to treat as
  /// success on relaunch) responses carry `data.device_id`, which is
  /// persisted for the later `GET`/`PUT /v1/pos/devices/:id` calls.
  ///
  /// Seen in practice: the server has echoed the request's own
  /// `finger_print` back under the `device_id` key instead of the real
  /// server-assigned id — the same class of field mix-up already flagged
  /// for Payment Link's `cashier_id`/`user_id` in
  /// `pos_mobile_app_endpoints.md`. A real device id can never equal the
  /// fingerprint we just sent (they're generated independently), so that
  /// value is refused rather than persisted — better to keep whatever was
  /// stored before (or nothing) than to silently poison every later call
  /// that depends on this id, which is exactly what caused transaction
  /// filtering to come up empty: the filter used the fingerprint, but
  /// every transaction was actually tagged with the real device id.
  Future<OpStatus> registerDevice(JsonMap body) async {
    try {
      final response = await _net.post('v1/pos/register', body);
      if (response.isSuccessful()) {
        await _prefs.set(_keyDeviceRegistered, true);
        final data = response.data;
        final fingerprint = body['finger_print']?.toString();
        final candidate = data is JsonMap
            ? (data['device_id'] ?? data['id'])?.toString()
            : null;
        if (candidate != null && candidate != fingerprint) {
          await _prefs.set(AuthConstants.keyPosDeviceId, candidate);
        } else if (candidate != null) {
          log(
            'Register device: server returned the fingerprint as '
            'device_id ($candidate) — refusing to persist it',
          );
        }
      }
      return OpStatus.fromResponse(response);
    } catch (e) {
      log('Error in device registration: $e');
      return OpStatus.unexpected(e.toString());
    }
  }

  /// Whether this device has already completed registration with
  /// `gp_pos_tms`.
  Future<bool> isDeviceRegistered() async {
    return await _prefs.getBool(_keyDeviceRegistered, defaultValue: false) ??
        false;
  }

  /// The `gp_pos_tms` device id returned by [registerDevice], or `null` if
  /// this device has never registered.
  ///
  /// Self-heals a device stuck with the fingerprint/device_id mix-up
  /// described on [registerDevice]: a value that exactly matches this
  /// device's local fingerprint can't be a real server-assigned id, so
  /// it's cleared here rather than kept — every caller already treats
  /// `null` as "this device's id/assignment isn't known yet" correctly
  /// (skip the filter, skip branch resolution), which is a safe
  /// degradation from the alternative of filtering forever against a
  /// value no transaction will ever carry.
  Future<String?> getPosDeviceId() async {
    final stored = await _prefs.getString(AuthConstants.keyPosDeviceId);
    if (stored == null) return null;
    final fingerprint = await _prefs.getString(AuthConstants.keyDeviceId);
    if (stored == fingerprint) {
      log('pos_device_id was poisoned with the device fingerprint — '
          'clearing it');
      await _prefs.deleteValue(AuthConstants.keyPosDeviceId);
      return null;
    }
    return stored;
  }

  /// Persists whether this device should be kiosk-locked. Set to `true`
  /// right after a successful [registerDevice] call; checked on every app
  /// launch (see `SplashCubit`) to re-engage the native lock, including
  /// after a reboot or after an admin's temporary PIN-exit lapses.
  Future<void> setKioskModeEnabled({required bool enabled}) async {
    await _prefs.set(_keyKioskModeEnabled, enabled);
  }

  /// Whether this device should be kiosk-locked on launch.
  Future<bool> isKioskModeEnabled() async {
    return await _prefs.getBool(_keyKioskModeEnabled, defaultValue: false) ??
        false;
  }

  /// Records the outcome of the most recent kiosk-lock activation (see
  /// `KioskHelper.enterKiosk`) -- which vendor hardware was detected and a
  /// short pass/fail summary -- so it can be shown later (e.g. in the
  /// kiosk-exit PIN dialog) instead of only appearing in a one-off snackbar.
  Future<void> setKioskStatus({
    required String vendor,
    required String summary,
  }) async {
    await _prefs.set(_keyKioskStatusVendor, vendor);
    await _prefs.set(_keyKioskStatusSummary, summary);
    await _prefs.set(_keyKioskStatusAt, DateTime.now().toIso8601String());
  }

  /// The most recent kiosk activation recorded by [setKioskStatus], or
  /// `null` if kiosk mode has never been activated on this device.
  Future<KioskStatus?> getKioskStatus() async {
    final vendor = await _prefs.getString(_keyKioskStatusVendor);
    final summary = await _prefs.getString(_keyKioskStatusSummary);
    final at = await _prefs.getString(_keyKioskStatusAt);
    if (vendor == null || summary == null || at == null) return null;
    return KioskStatus(
      vendor: vendor,
      summary: summary,
      activatedAt: DateTime.tryParse(at),
    );
  }

  /// Public catalog for the Setup screen's Terminal Type picker
  /// (`GET /v1/terminal-types`, see `pos_mobile_app_endpoints.md` §1) —
  /// `{ "success": true, "data": [ { "id", "name", "terminal_model", ... } ] }`
  /// ordered by name. An empty list means the field just shows no options
  /// (the backend already treats it as optional when blank).
  Future<List<(String id, String name)>> getTerminalTypes() async {
    try {
      final response = await _net.get('v1/terminal-types');
      if (!response.isSuccessful()) return const [];
      final list = response.data;
      if (list is! List) return const [];
      return [
        for (final row in list)
          if (row is JsonMap)
            ((row['id'] ?? '').toString(), (row['name'] ?? '').toString()),
      ].where((t) => t.$1.isNotEmpty && t.$2.isNotEmpty).toList();
    } catch (e) {
      log('Error fetching terminal types: $e');
      return const [];
    }
  }

  /// Reads this device's current assignment (`GET /v1/pos/devices/:id`,
  /// referenced by `pos_mobile_app_endpoints.md`'s Suggested end-to-end
  /// flow step 3 — not independently detailed there beyond "returns the
  /// device's current `branch_id`"). Returns `(merchantId, branchId)`,
  /// either of which may be null.
  Future<(String?, String?)> getPosDevice(String deviceId) async {
    try {
      final response = await _net.get('v1/pos/devices/$deviceId');
      final data = response.data;
      final row = data is JsonMap
          ? (data['data'] is JsonMap ? data['data'] as JsonMap : data)
          : null;
      if (row == null) return (null, null);
      return (
        row['merchant_id'] as String?,
        row['branch_id'] as String?,
      );
    } catch (e) {
      log('Error fetching device: $e');
      return (null, null);
    }
  }

  /// Lists the logged-in merchant's branches for the post-login branch
  /// picker (`GET /merchants/branches`, session JWT, see
  /// `pos_mobile_app_endpoints.md` §0c). The doc describes this as a bare
  /// JSON array, but the live backend actually wraps it in the standard
  /// `{status, message, data}` envelope — confirmed from a real response
  /// log — so this goes through the normal [NetSource.get] envelope parsing
  /// like every other route, not the bare-array path.
  ///
  /// Returns an empty list both when the merchant genuinely has zero
  /// branches (itself a valid `200 []`) and when the call fails (401
  /// unauthenticated, 403 onboarding-incomplete/missing-permission — see
  /// the doc's flagged RBAC gap — or 500). Every one of those cases has
  /// the same result for the caller: skip the picker and leave the device
  /// unassigned to a branch, so there's no need to distinguish them here.
  Future<List<(String id, String name)>> getBranches() async {
    try {
      final response = await _net.get('merchants/branches');
      if (!response.isSuccessful()) return const [];
      final list = response.data;
      if (list is! List) return const [];
      return [
        for (final row in list)
          if (row is JsonMap)
            ((row['id'] ?? '').toString(), (row['name'] ?? '').toString()),
      ].where((b) => b.$1.isNotEmpty && b.$2.isNotEmpty).toList();
    } catch (e) {
      log('Error fetching branches: $e');
      return const [];
    }
  }

  /// Claims an unassigned device to the logged-in merchant, and/or writes
  /// the branch chosen in the post-login picker (`PUT /v1/pos/devices/:id`,
  /// flow step 4) — the merchant is resolved server-side from the bearer
  /// token, not sent by the app. [branchId] is included when a branch has
  /// been chosen; omitted when the picker was skipped (no branches to
  /// choose from, or the fetch failed).
  Future<OpStatus> claimPosDevice(String deviceId, {String? branchId}) async {
    try {
      final response = await _net.put('v1/pos/devices/$deviceId', {
        if (branchId != null) 'branch_id': branchId,
      });
      return OpStatus.fromResponse(response);
    } catch (e) {
      log('Error claiming device: $e');
      return OpStatus.unexpected(e.toString());
    }
  }

  /// Function to logout
  Future<void> logOut() async {
    await _prefs.deleteValue(_keyId);
    await _prefs.deleteValue(_keyLoggedIn);
    await _db.deleteAll(_tblUsers);
    await _prefs.deleteValue(_keyToken);
    _controller.add(AuthStatus.unauthenticated);
  }

  Future<void> _getAndAuthUser(JsonMap responseData) async {
    final accessToken =
        (responseData['token'] ?? responseData['accessToken']) as String?;
    final refreshToken = (responseData['refresh_token'] ??
        responseData['refreshToken']) as String?;
    await _prefs.set(_keyLoggedIn, true);
    await _prefs.set(_keyToken, accessToken);
    await _prefs.set(AuthConstants.keyCurrentToken, refreshToken);
    await _initNetworkApi(token: accessToken);
    final userMap = responseData['user'] as JsonMap;
    log('User map from API: $userMap');
    final user = User.fromJson(userMap);
    log('User after fromJson: $user');
    await _db.insertOne(_tblUsers, user.toJsonDb());
    await _prefs.set(_keyId, user.id);
    _controller.add(AuthStatus.authenticated);
  }
}
