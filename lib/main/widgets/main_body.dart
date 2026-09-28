import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/home/cubit/cubit.dart';
import 'package:geepay_pos/home/view/home_page.dart';
import 'package:geepay_pos/main/cubit/main_cubit.dart';
import 'package:geepay_pos/settings/widgets/settings_body.dart';
import 'package:geepay_pos/transaction_history/transaction_history.dart';
import 'package:geepay_pos/utils/constants.dart';
import 'package:geepay_pos/widgets/app_nav_bar.dart';
import 'package:geepay_pos/widgets/fade_indexed_stack.dart';
import 'package:services_repo/services_repo.dart';

/// {@template main_body}
/// Body of the MainPage: bottom nav per the design spec (Home / History /
/// Settings).
///
/// Tabs are built the first time they are visited and then kept alive,
/// so scroll position and filters survive switching. Home and History
/// refresh without dropping what is on screen when you switch back to
/// them, and when a pushed screen (for example the Collections flow) pops
/// back to the dashboard.
/// {@endtemplate}
class MainBody extends StatefulWidget {
  /// {@macro main_body}
  const MainBody({super.key});
  static const int homeTabIndex = 0;
  static const int historyTabIndex = 1;
  static const int settingsTabIndex = 2;

  @override
  State<MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> with RouteAware {
  static const _items = [
    AppNavItem(
      icon: AppIcons.home,
      activeIcon: AppIcons.homeActive,
      label: 'Home',
    ),
    AppNavItem(
      icon: AppIcons.history,
      activeIcon: AppIcons.historyActive,
      label: 'History',
    ),
    AppNavItem(
      icon: AppIcons.settings,
      activeIcon: AppIcons.settingsActive,
      label: 'Settings',
    ),
  ];

  late final HomeCubit _home = HomeCubit(
    context.read<ServicesRepo>(),
    context.read<AuthRepo>(),
  );

  /// Created on the first visit to the History tab; it loads in its
  /// constructor.
  TransactionHistoryCubit? _history;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    unawaited(_home.close());
    unawaited(_history?.close());
    super.dispose();
  }

  /// A route pushed on top of the dashboard was popped: refresh whichever
  /// tab is showing so, for example, a just-completed collection appears.
  @override
  void didPopNext() => _refresh(context.read<MainCubit>().state.currentIndex);

  void _refresh(int index) {
    switch (index) {
      case MainBody.homeTabIndex:
        unawaited(_home.load());
      case MainBody.historyTabIndex:
        unawaited(_history?.load());
    }
  }

  void _onTabSelected(int index) {
    final cubit = context.read<MainCubit>();
    if (index == cubit.state.currentIndex) return;
    if (index == MainBody.historyTabIndex && _history == null) {
      _history = TransactionHistoryCubit(
        context.read<ServicesRepo>(),
        context.read<AuthRepo>(),
      );
    } else {
      _refresh(index);
    }
    cubit.changeTab(index);
  }

  Widget _buildTab(BuildContext context, int index) {
    return switch (index) {
      MainBody.homeTabIndex => BlocProvider.value(
        value: _home,
        child: const HomeView(),
      ),
      MainBody.historyTabIndex => BlocProvider.value(
        value: _history!,
        child: const TransactionHistoryBody(),
      ),
      _ => const SettingsBody(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        return PopScope(
          canPop: state.currentIndex == MainBody.homeTabIndex,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && state.currentIndex != MainBody.homeTabIndex) {
              _onTabSelected(MainBody.homeTabIndex);
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.surfacePage,
            body: FadeIndexedStack(
              index: state.currentIndex,
              itemCount: _items.length,
              itemBuilder: _buildTab,
            ),
            bottomNavigationBar: AppNavBar(
              items: _items,
              currentIndex: state.currentIndex,
              onTap: _onTabSelected,
            ),
          ),
        );
      },
    );
  }
}
