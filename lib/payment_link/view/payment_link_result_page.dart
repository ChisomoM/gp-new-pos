import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/payment_link/widgets/widgets.dart';

class PaymentLinkResultPage extends StatelessWidget {
  const PaymentLinkResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: PaymentLinkResultBody(),
    );
  }
}
