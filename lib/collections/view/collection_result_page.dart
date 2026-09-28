import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/collections/widgets/widgets.dart';

class CollectionResultPage extends StatelessWidget {
  const CollectionResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: CollectionResultBody(),
    );
  }
}
