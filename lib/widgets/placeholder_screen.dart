import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Minimal "not built yet" placeholder for destinations the design spec
/// covers but this pass doesn't implement (Collections, Packages, Cashier
/// Summary, Transaction History, Settings, ...).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.clock, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              '$title — coming soon',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
