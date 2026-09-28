import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/transaction_details/transaction_details.dart';
import 'package:geepay_pos/transaction_history/cubit/cubit.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:intl/intl.dart';

class TransactionHistoryBody extends StatelessWidget {
  const TransactionHistoryBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
      builder: (context, state) {
        final cubit = context.read<TransactionHistoryCubit>();
        return Column(
          children: [
            const BackHeader(title: 'Transaction history'),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
                child: Row(
                  children: [
                    for (final filter in TransactionHistoryFilter.values) ...[
                      if (filter != TransactionHistoryFilter.values.first)
                        const SizedBox(width: 8),
                      _FilterChip(
                        label: switch (filter) {
                          TransactionHistoryFilter.all => 'All',
                          TransactionHistoryFilter.successful => 'Successful',
                          TransactionHistoryFilter.failed => 'Failed',
                          TransactionHistoryFilter.pending => 'Pending',
                        },
                        selected: state.filter == filter,
                        onTap: () => cubit.setFilter(filter),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(child: _TransactionList(state: state)),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.infoFill : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.gpCobalt : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? const Color(0xFF141644) : const Color(0xFF3D4560),
          ),
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.state});

  final TransactionHistoryState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == TransactionHistoryStatus.failure) {
      return Center(
        child: Text(
          state.errorMessage ?? 'Unable to load transactions',
          style: const TextStyle(fontSize: 13, color: AppColors.dangerIcon),
        ),
      );
    }
    if (state.transactions.isEmpty) {
      return const Center(
        child: Text(
          'No transactions found',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final tx in state.transactions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TransactionRow(
              title: tx.phoneNumber,
              subtitle: [
                tx.channelLabel,
                'Collection',
                if (tx.processedAt != null)
                  DateFormat('h:mm a').format(tx.processedAt!),
              ].join(' · '),
              amountLabel: '${tx.currency} ${tx.amount.toStringAsFixed(2)}',
              status: tx.status,
              avatarLetter: tx.avatarLetter,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<dynamic>(
                  builder: (_) =>
                      TransactionDetailsPage(transactionId: tx.lookupId),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
