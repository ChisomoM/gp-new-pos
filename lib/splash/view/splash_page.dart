import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:geepay_pos/login/login.dart';
import 'package:geepay_pos/main/view/main_page.dart';
import 'package:geepay_pos/setup/setup.dart';
import 'package:geepay_pos/splash/cubit/cubit.dart';
import 'package:geepay_pos/splash/widgets/splash_body.dart';
import 'package:geepay_pos/utils/deep_link_service.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({this.deepLinkService, super.key});

  final DeepLinkService? deepLinkService;

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(builder: (_) => const SplashPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(context.read<AuthRepo>()),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          switch (state.destination) {
            case SplashDestination.none:
              break;
            case SplashDestination.setup:
              Navigator.of(context).pushReplacement(SetupPage.route());
            case SplashDestination.login:
              Navigator.of(context).pushReplacement(LoginPage.route());
            case SplashDestination.main:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<dynamic>(
                  settings: const RouteSettings(name: '/dashboard'),
                  builder: (_) => MainPage(deepLinkService: deepLinkService),
                ),
              );
          }
        },
        child: const Scaffold(body: SplashBody()),
      ),
    );
  }
}
