import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/transaction_history/cubit/cubit.dart';
import 'package:geepay_pos/transaction_history/widgets/widgets.dart';
import 'package:services_repo/services_repo.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const TransactionHistoryPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionHistoryCubit(
        context.read<ServicesRepo>(),
        context.read<AuthRepo>(),
      ),
      child: const Scaffold(
        backgroundColor: AppColors.surfacePage,
        body: TransactionHistoryBody(),
      ),
    );
  }
}
