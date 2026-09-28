import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/home/cubit/cubit.dart';
import 'package:geepay_pos/home/widgets/home_body.dart';
import 'package:geepay_pos/utils/constants.dart';
import 'package:services_repo/services_repo.dart';

/// {@template home_page}
/// A description for HomePage
/// {@endtemplate}
class HomePage extends StatefulWidget {
  /// {@macro home_page}
  const HomePage({super.key});

  /// The static route for HomePage
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(builder: (_) => const HomePage());
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  late final HomeCubit _cubit = HomeCubit(
    context.read<ServicesRepo>(),
    context.read<AuthRepo>(),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _cubit.close();
    super.dispose();
  }

  /// Called when a route pushed on top of this one (e.g. the Collections
  /// flow) is popped and this tab becomes visible again. Home's data was
  /// fetched once when this page first mounted and otherwise never
  /// refreshes, so without this a just-completed collection wouldn't show
  /// up until the user pulled to refresh.
  @override
  void didPopNext() {
    _cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: const Scaffold(
        backgroundColor: AppColors.surfacePage,
        body: HomeView(),
      ),
    );
  }
}

/// {@template home_view}
/// Displays the Body of HomeView
/// {@endtemplate}
class HomeView extends StatelessWidget {
  /// {@macro home_view}
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeBody();
  }
}
