import 'package:geepay_pos/utils/database_scripts.dart';

enum AppEnv { development, staging, production }

/// {@template config}
/// Config description
/// {@endtemplate}
class Config {
  /// {@macro config}
  const Config({
    required this.baseUrl,
    // required this.socketUrl,
    required this.dbName,
    required this.host,
    required this.initScript,
    required this.kioskExitPin,
    this.environment = AppEnv.development,
    this.migrations = const [],
    this.uuid,
  });

  /// Creates a dev config
  factory Config.dev() => Config(
    baseUrl: 'https://uat.gateway.mygeepay.com/api/',
    // socketUrl: 'ws://155.138.220.54/api_socket/websocket?vsn=2.0.0',
    host: 'uat.gateway.mygeepay.com',
    dbName: 'geepay.pos.dev.db',
    initScript: initialScript,
    migrations: migrationScript,
    kioskExitPin: '0000',
  );

  /// Creates a staging config
  factory Config.staging() => Config(
    environment: AppEnv.staging,
    baseUrl: 'https://prod.gateway.mygeepay.com/api/',
    // socketUrl: 'ws://155.138.220.54/api_socket/websocket?vsn=2.0.0',
    host: 'prod.gateway.mygeepay.com',
    dbName: 'geepay.pos.stg.db',
    initScript: initialScript,
    migrations: migrationScript,
    kioskExitPin: '0000',
  );

  /// Creates a production config
  factory Config.prod() => Config(
    environment: AppEnv.production,
    baseUrl: 'https://prod.gateway.mygeepay.com/api/',
    // socketUrl: 'ws://155.138.220.54/api_socket/websocket?vsn=2.0.0',
    host: 'prod.gateway.mygeepay.com',
    dbName: 'geepay.pos.db',
    initScript: initialScript,
    migrations: migrationScript,
    kioskExitPin: '0000',
  );

  /// A description for baseUrl
  final String baseUrl;

  /// A description for socketUrl
  // final String socketUrl;

  /// A description for dbName
  final String dbName;

  /// A description for host
  final String host;

  /// A description for initScript
  final List<String> initScript;

  /// A description for migrations
  final List<String> migrations;

  /// A description for uuid
  final String? uuid;

  /// A description for environment
  final AppEnv environment;

  /// Admin PIN required to exit kiosk mode on this build flavor, entered via
  /// the hidden gesture on the Settings screen's app-version row.
  final String kioskExitPin;
}
