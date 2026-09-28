import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/app_header.dart';
import 'package:geepay_pos/widgets/empty_state.dart';
import 'package:geepay_pos/widgets/status_badge.dart';

/// "Not built yet" destination for entry points kept visible on purpose
/// (Cashier summary, Company profile).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: Column(
        children: [
          AppHeader(title: title),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: EmptyState(
                  icon: AppIcons.comingSoon,
                  badge: const StatusBadge(
                    label: 'Coming soon',
                    tone: BadgeTone.info,
                  ),
                  title: title,
                  message:
                      "We're still building this. It will appear here "
                      'in a future update.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
