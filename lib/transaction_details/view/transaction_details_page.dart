import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/transaction_details/cubit/cubit.dart';
import 'package:geepay_pos/transaction_details/widgets/widgets.dart';
import 'package:services_repo/services_repo.dart';

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({required this.transactionId, super.key});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionDetailsCubit(
        context.read<ServicesRepo>(),
        transactionId,
      ),
      child: const Scaffold(
        backgroundColor: AppColors.surfacePage,
        body: TransactionDetailsBody(),
      ),
    );
  }
}
