import 'package:flutter/material.dart';

final navKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Registered on [MaterialApp.navigatorObservers] so a screen that stays
/// mounted underneath a pushed route (e.g. the Home tab underneath the
/// Collections flow) can be notified via [RouteAware.didPopNext] when it
/// becomes visible again, instead of showing whatever stale data it loaded
/// before the pushed route was ever opened.
final routeObserver = RouteObserver<PageRoute<dynamic>>();
