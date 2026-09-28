import 'package:permission_handler/permission_handler.dart';

export 'package:permission_handler/permission_handler.dart'
    show PermissionStatus, PermissionStatusGetters;

/// {@template permission_client}
/// A client that handles requesting permissions on a device.
/// {@endtemplate}
class PermissionClient {
  /// {@macro permission_client}
  const PermissionClient();

  /// Request access to the device's notifications,
  /// if access hasn't been previously granted.
  Future<PermissionStatus> requestNotifications() =>
      Permission.notification.request();

  /// Returns a permission status for the device's notifications.
  Future<PermissionStatus> notificationsStatus() =>
      Permission.notification.status;

  /// Request access to the device's location,
  /// if access hasn't been previously granted.
  Future<PermissionStatus> requestLocation() => Permission.location.request();

  /// Request access to the device's location,
  /// if access hasn't been previously granted.
  Future<PermissionStatus> requestLocationAlways() =>
      Permission.locationAlways.request();

  /// Returns a permission status for the device's location.
  Future<PermissionStatus> locationStatus() => Permission.location.status;

  /// Returns a permission status for the device's location even when running
  /// in the background.
  Future<PermissionStatus> locationAlwaysStatus() =>
      Permission.locationAlways.status;

  /// Request access to connect to already-paired Bluetooth devices
  /// (Android 12+ runtime permission; a no-op grant on older OS versions
  /// where Bluetooth connect is a manifest-only permission).
  Future<PermissionStatus> requestBluetoothConnect() =>
      Permission.bluetoothConnect.request();

  /// Returns a permission status for connecting to Bluetooth devices.
  Future<PermissionStatus> bluetoothConnectStatus() =>
      Permission.bluetoothConnect.status;

  /// Opens the app settings page.
  ///
  /// Returns true if the settings could be opened, otherwise false.
  Future<bool> openPermissionSettings() => openAppSettings();
}
