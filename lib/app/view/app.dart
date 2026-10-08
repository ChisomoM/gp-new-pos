import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/theme.dart';
import 'package:geepay_pos/auth/auth.dart';
import 'package:geepay_pos/splash/view/splash_page.dart';
import 'package:geepay_pos/utils/constants.dart';
import 'package:geepay_pos/utils/deep_link_service.dart';
import 'package:geepay_pos/utils/screen_size.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:services_repo/services_repo.dart';

class App extends StatelessWidget {
  const App({
    required this.authRepo,
    required this.servicesRepo,
    required this.notificationsRepo,
    required this.analyticsRepo,
    required this.loggedIn,
    this.deepLinkService,
    super.key,
  });

  final AuthRepo authRepo;
  final ServicesRepo servicesRepo;
  final dynamic notificationsRepo;
  final dynamic analyticsRepo;
  final bool loggedIn;
  final DeepLinkService? deepLinkService;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepo>.value(value: authRepo),
        RepositoryProvider<ServicesRepo>.value(value: servicesRepo),
      ],
      child: BlocProvider(
        create: (_) => AuthBloc(authRepo, servicesRepo),
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.status == AuthStatus.authenticated &&
              current.status == AuthStatus.expired,
          listener: (context, state) => _onSessionExpired(),
          child: MaterialApp(
            navigatorKey: navKey,
            theme: const AppTheme().themeData,
            scaffoldMessengerKey: scaffoldMessengerKey,
            navigatorObservers: [routeObserver],
            builder: (context, child) {
              SizeConfig().init(context);
              return child!;
            },
            home: SplashPage(deepLinkService: deepLinkService),
          ),
        ),
      ),
    );
  }

  /// A request came back `401` mid-session — the token is dead with no
  /// refresh path (see `pos_mobile_app_endpoints.md`'s token-lifetime
  /// note), so the only correct move is back to Login, from wherever the
  /// cashier currently is, with an explanation for why they landed there.
  Future<void> _onSessionExpired() async {
    final nav = navKey.currentState;
    if (nav == null) return;
    await nav.pushAndRemoveUntil(SplashPage.route(), (route) => false);
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      showToastOn(
        messenger,
        message: 'Your session has expired. Please log in again.',
        tone: ToastTone.warning,
      );
    }
  }
}
