import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/home/view/home_page.dart';
import 'package:geepay_pos/main/cubit/main_cubit.dart';
import 'package:geepay_pos/settings/widgets/settings_body.dart';
import 'package:geepay_pos/transaction_history/transaction_history.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:services_repo/services_repo.dart';

/// {@template main_body}
/// Body of the MainPage — bottom nav per the design spec: Home / History /
/// Settings.
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        return PopScope(
          canPop: state.currentIndex == MainBody.homeTabIndex,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && state.currentIndex != MainBody.homeTabIndex) {
              context.read<MainCubit>().changeTab(MainBody.homeTabIndex);
            }
          },
          child: Scaffold(
            body: _buildBody(state.currentIndex),
            bottomNavigationBar: BottomNavigationBar(
              elevation: 2,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              currentIndex: state.currentIndex,
              onTap: (index) => context.read<MainCubit>().changeTab(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.surfaceWhite,
              selectedItemColor: AppColors.gpCobalt,
              unselectedItemColor: AppColors.textMuted,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.clock),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.setting_2),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case MainBody.homeTabIndex:
        return const HomePage();
      case MainBody.historyTabIndex:
        return BlocProvider(
          create: (context) => TransactionHistoryCubit(
            context.read<ServicesRepo>(),
            context.read<AuthRepo>(),
          ),
          child: const TransactionHistoryBody(),
        );
      case MainBody.settingsTabIndex:
        return const SettingsBody();
      default:
        return const HomePage();
    }
  }
}
