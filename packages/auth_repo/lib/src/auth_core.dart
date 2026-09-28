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
  /// `gp_auth-main`'s `/auth/login` is a two-step, OTP-gated login: an
  /// email+password call with no `otp` in [body] returns
  /// `{ "mfa_required": true, "message": "..." }` (no tokens yet) and the
  /// caller must call this again with the `otp` field added once the
  /// cashier enters the code emailed to them. Only that second call
  /// returns the real `token`/`refresh_token`/`user` payload.
  ///
  /// This endpoint has no `{success, message, data}` envelope — success is
  /// a raw `AuthenticatedUser` object, failure is `{"error": "..."}"`, and
  /// the OTP step is `{"mfa_required": true}` — so it can't use
  /// `OpStatus.fromResponse`/`NetResponse.isSuccessful()` like every other
  /// route in this app; each shape is checked directly.
  Future<OpStatus> login(JsonMap body) async {
    try {
      final response = await _net.post('auth/login', body);
      final data = response.data;
      if (data is JsonMap && data['token'] != null) {
        await _getAndAuthUser(data);
        return OpStatus.success('Logged in', data: data);
      }
      if (data is JsonMap && data['mfa_required'] == true) {
        return OpStatus.success(
          (data['message'] as String?) ?? 'A verification code was sent',
          data: const {'mfaRequired': true},
        );
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
  /// management). This is unauthenticated and unrelated to user login/signup:
  /// it returns only a `device_id`, never tokens or a user.
  Future<OpStatus> registerDevice(JsonMap body) async {
    try {
      final response = await _net.post('v1/pos/register', body);
      if (response.isSuccessful()) {
        await _prefs.set(_keyDeviceRegistered, true);
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
