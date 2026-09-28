import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/theme.dart';
import 'package:geepay_pos/auth/auth.dart';
import 'package:geepay_pos/splash/view/splash_page.dart';
import 'package:geepay_pos/utils/constants.dart';
import 'package:geepay_pos/utils/deep_link_service.dart';
import 'package:geepay_pos/utils/screen_size.dart';
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
        child: MaterialApp(
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
    );
  }
}
