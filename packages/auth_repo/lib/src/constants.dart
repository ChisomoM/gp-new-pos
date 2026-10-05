/// Shared constants for AuthRepo
class AuthConstants {
  static const String keyId = 'user_id';
  static const String keyAppVersion = 'app_version';
  static const String keyToken = 'token';
  static const String keyCurrentToken = 'refreshToken';
  static const String keyFCMToken = 'fcm_token';
  static const String keyLoggedIn = 'logged_in';
  static const String keyAppId = 'app_id';
  static const String keyDeviceId = 'device_id';
  static const String keyDeviceRegistered = 'device_registered';
  static const String keyKioskModeEnabled = 'kiosk_mode_enabled';

  /// The real `gp_pos_tms` device id returned by `POST /v1/pos/register`
  /// (`data.device_id`) — distinct from [keyDeviceId], which is a locally
  /// generated UUID used for request headers/fingerprint, not the
  /// server-assigned device record id needed for `GET`/`PUT
  /// /v1/pos/devices/:id`.
  static const String keyPosDeviceId = 'pos_device_id';
  static const String keyTheme = 'theme';

  static const String tblUsers = 'users';
  static const String tblUserDetails = 'user_details';
}
