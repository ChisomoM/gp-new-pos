import 'package:flutter/material.dart';

const kAppCornerRadius = 12.0; // radius-xl — buttons, inputs
const kCardCornerRadius = 16.0; // radius-2xl — cards

final navKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Registered on [MaterialApp.navigatorObservers] so a screen that stays
/// mounted underneath a pushed route (e.g. the Home tab underneath the
/// Collections flow) can be notified via [RouteAware.didPopNext] when it
/// becomes visible again, instead of showing whatever stale data it loaded
/// before the pushed route was ever opened.
final routeObserver = RouteObserver<PageRoute<dynamic>>();
