import 'dart:developer';

import 'package:geepay_pos/app/app.dart';
import 'package:geepay_pos/auth/auth.dart';
import 'package:geepay_pos/bootstrap.dart';
import 'package:geepay_pos/firebase_config.dart';
import 'package:geepay_pos/utils/config.dart';
import 'package:geepay_pos/utils/deep_link_service.dart';
import 'package:geepay_pos/utils/utils.dart';
import 'package:local_data/local_data.dart';
import 'package:net_source/net_source.dart';
import 'package:notifications_repo/notifications_repo.dart';
import 'package:permission_client/permission_client.dart';
import 'package:services_repo/services_repo.dart';

void main() {
  final config = Config.staging();
  baseUrl = 'http://${config.host}';
  bootstrap((
    prefs,
    analyticsRepository,
    auth,
    googleSignIn,
    signInWithApple,
  ) async {
    // Initialize Firebase
    await FirebaseConfig.initialize(
      environment: 'staging',
      enableFirestore: true, // Enable/disable as needed
      enableMessaging: true,
    );

    // Initialize Deep Link Service
    final deepLinkService = DeepLinkService();
    await deepLinkService.init();

    final db = await LocalData.init(
      dbName: config.dbName,
      initialScript: config.initScript,
      migrations: config.migrations,
    );
    final token = await prefs.getString('token');
    log(' user Token $token');
    final net = NetSource(
      baseUrl: config.baseUrl,
      host: config.host,
      token: token,
    );
    final authRepo = AuthRepo(
      signInWithApple: signInWithApple,
      googleSignIn: googleSignIn,
      auth: auth,
      isDev: false,
      prefs: prefs,
      db: db,
      net: net,
    );
    final servicesRepo = ServicesRepo(
      prefs: prefs,
      db: db,
      net: net,
      firestore: FirebaseConfig.firestore,
    );
    const permissionClient = PermissionClient();
    final notificationsRepo = NotificationsRepo(
      prefs: prefs,
      net: net,
      permissionClient: permissionClient,
    );
    return App(
      authRepo: authRepo,
      servicesRepo: servicesRepo,
      analyticsRepo: analyticsRepository,
      notificationsRepo: notificationsRepo,
      loggedIn: token != null,
      deepLinkService: deepLinkService,
    );
  });
}
