import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/home/cubit/cubit.dart';
import 'package:geepay_pos/home/view/home_page.dart';
import 'package:geepay_pos/main/cubit/main_cubit.dart';
import 'package:geepay_pos/settings/widgets/settings_body.dart';
import 'package:geepay_pos/transaction_history/transaction_history.dart';
import 'package:geepay_pos/widgets/app_nav_bar.dart';
import 'package:services_repo/services_repo.dart';

/// {@template main_body}
/// Body of the MainPage: bottom nav per the design spec (Home / History /
/// Settings).
///
/// Tabs are built the first time they are visited and then kept alive,
/// so scroll position and filters survive switching. Switching cross-fades
/// between tabs, and returning to Home or History refreshes their data
/// without dropping what is already on screen.
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

class _MainBodyState extends State<MainBody> {
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

  final Set<int> _visited = {MainBody.homeTabIndex};

  void _onTabSelected(BuildContext context, int index) {
    final current = context.read<MainCubit>().state.currentIndex;
    if (index != current && _visited.contains(index)) {
      switch (index) {
        case MainBody.homeTabIndex:
          unawaited(context.read<HomeCubit>().load());
        case MainBody.historyTabIndex:
          unawaited(context.read<TransactionHistoryCubit>().load());
      }
    }
    setState(() => _visited.add(index));
    context.read<MainCubit>().changeTab(index);
  }

  Widget _buildTab(int index) {
    return switch (index) {
      MainBody.homeTabIndex => const HomeView(),
      MainBody.historyTabIndex => const TransactionHistoryBody(),
      _ => const SettingsBody(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeCubit(
            context.read<ServicesRepo>(),
            context.read<AuthRepo>(),
          ),
        ),
        // Created on first visit to the History tab; the cubit loads in its
        // constructor.
        BlocProvider(
          create: (context) => TransactionHistoryCubit(
            context.read<ServicesRepo>(),
            context.read<AuthRepo>(),
          ),
        ),
      ],
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          return PopScope(
            canPop: state.currentIndex == MainBody.homeTabIndex,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && state.currentIndex != MainBody.homeTabIndex) {
                _onTabSelected(context, MainBody.homeTabIndex);
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.surfacePage,
              body: _FadeIndexedStack(
                index: state.currentIndex,
                visited: _visited,
                builder: _buildTab,
                length: _items.length,
              ),
              bottomNavigationBar: AppNavBar(
                items: _items,
                currentIndex: state.currentIndex,
                onTap: (index) => _onTabSelected(context, index),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Like [IndexedStack], but children are built lazily on first visit and
/// the active child fades in. Inactive children keep their state but are
/// hidden from hit testing, semantics and tickers.
class _FadeIndexedStack extends StatelessWidget {
  const _FadeIndexedStack({
    required this.index,
    required this.visited,
    required this.builder,
    required this.length,
  });

  final int index;
  final Set<int> visited;
  final Widget Function(int index) builder;
  final int length;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.base);
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < length; i++)
          if (visited.contains(i))
            _TabSlot(
              key: ValueKey(i),
              active: i == index,
              duration: duration,
              child: builder(i),
            )
          else
            const SizedBox.shrink(),
      ],
    );
  }
}

class _TabSlot extends StatelessWidget {
  const _TabSlot({
    required this.active,
    required this.duration,
    required this.child,
    super.key,
  });

  final bool active;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !active,
      child: ExcludeSemantics(
        excluding: !active,
        child: TickerMode(
          enabled: active,
          child: AnimatedOpacity(
            opacity: active ? 1 : 0,
            duration: duration,
            curve: active ? AppMotion.enter : AppMotion.exit,
            child: child,
          ),
        ),
      ),
    );
  }
}
