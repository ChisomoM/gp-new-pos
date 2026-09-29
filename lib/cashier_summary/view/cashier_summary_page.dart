import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/cashier_summary/cubit/cubit.dart';
import 'package:geepay_pos/cashier_summary/widgets/widgets.dart';
import 'package:services_repo/services_repo.dart';

class CashierSummaryPage extends StatelessWidget {
  const CashierSummaryPage({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const CashierSummaryPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CashierSummaryCubit(
        context.read<ServicesRepo>(),
        context.read<AuthRepo>(),
      ),
      child: const Scaffold(
        backgroundColor: AppColors.surfacePage,
        body: CashierSummaryBody(),
      ),
    );
  }
}
