import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
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
        final canPop = Navigator.of(context).canPop();
        return Column(
          children: [
            if (canPop)
              const AppHeader(title: 'Transaction history')
            else
              const AppHeader.large(title: 'Transaction history'),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  AppSpace.x2,
                  AppSpace.gutter,
                  AppSpace.x3,
                ),
                child: Row(
                  children: [
                    for (final filter in TransactionHistoryFilter.values) ...[
                      if (filter != TransactionHistoryFilter.values.first)
                        const SizedBox(width: AppSpace.x2),
                      AppChoiceChip(
                        label: _filterLabel(filter),
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

String _filterLabel(TransactionHistoryFilter filter) => switch (filter) {
  TransactionHistoryFilter.all => 'All',
  TransactionHistoryFilter.successful => 'Successful',
  TransactionHistoryFilter.failed => 'Failed',
  TransactionHistoryFilter.pending => 'Pending',
};

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.state});

  final TransactionHistoryState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionHistoryCubit>();
    final Widget child;
    if (state.isLoading) {
      child = const SingleChildScrollView(
        key: ValueKey('loading'),
        padding: EdgeInsets.all(AppSpace.gutter),
        child: SkeletonTransactionList(count: 6),
      );
    } else if (state.status == TransactionHistoryStatus.failure) {
      child = Center(
        key: const ValueKey('error'),
        child: SingleChildScrollView(
          child: ErrorState(
            title: "Couldn't load transactions",
            message: state.errorMessage,
            onRetry: cubit.load,
          ),
        ),
      );
    } else if (state.transactions.isEmpty) {
      final filtered = state.filter != TransactionHistoryFilter.all;
      child = Center(
        key: ValueKey('empty-${state.filter}'),
        child: SingleChildScrollView(
          child: EmptyState(
            icon: AppIcons.receipt,
            title: filtered
                ? 'No ${_filterLabel(state.filter).toLowerCase()} '
                      'transactions'
                : 'No transactions yet',
            message: filtered
                ? 'Try another filter.'
                : 'Collections you take will show up here.',
          ),
        ),
      );
    } else {
      child = ListView.separated(
        key: ValueKey('list-${state.filter}'),
        padding: const EdgeInsets.all(AppSpace.gutter),
        itemCount: state.transactions.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpace.x2),
        itemBuilder: (context, index) {
          final tx = state.transactions[index];
          return TransactionRow(
            title: tx.phoneNumber,
            subtitle: [
              tx.channelLabel,
              'Collection',
              if (tx.processedAt != null)
                DateFormat('h:mm a').format(tx.processedAt!),
            ].join(' · '),
            amount: tx.amount,
            currency: tx.currency,
            status: tx.status,
            avatarLetter: tx.avatarLetter,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<dynamic>(
                builder: (_) =>
                    TransactionDetailsPage(transactionId: tx.lookupId),
              ),
            ),
          );
        },
      );
    }
    return AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.base),
      child: child,
    );
  }
}
