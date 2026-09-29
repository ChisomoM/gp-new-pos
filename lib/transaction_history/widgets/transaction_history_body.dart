import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/export/export.dart';
import 'package:geepay_pos/transaction_details/transaction_details.dart';
import 'package:geepay_pos/transaction_history/cubit/cubit.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:intl/intl.dart';

class TransactionHistoryBody extends StatelessWidget {
  const TransactionHistoryBody({super.key});

  Future<void> _export(BuildContext context, TransactionHistoryState state) {
    return showExportSheet(
      context,
      onPdf: () => TransactionExport.transactionsToPdf(
        title: 'Transaction history',
        transactions: state.transactions,
      ),
      onExcel: () => TransactionExport.transactionsToExcel(
        title: 'Transaction history',
        transactions: state.transactions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
      builder: (context, state) {
        final cubit = context.read<TransactionHistoryCubit>();
        final canPop = Navigator.of(context).canPop();
        final exportAction = AppIconButton(
          icon: AppIcons.export,
          tooltip: 'Export',
          onPressed: state.transactions.isEmpty
              ? null
              : () => _export(context, state),
        );
        return Column(
          children: [
            if (canPop)
              AppHeader(title: 'Transaction history', actions: [exportAction])
            else
              AppHeader.large(
                title: 'Transaction history',
                actions: [exportAction],
              ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                children: [
                  _ChipRow(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.gutter,
                      AppSpace.x2,
                      AppSpace.gutter,
                      AppSpace.x2,
                    ),
                    children: [
                      for (final filter in TransactionHistoryFilter.values)
                        AppChoiceChip(
                          label: _filterLabel(filter),
                          selected: state.filter == filter,
                          onTap: () => cubit.setFilter(filter),
                        ),
                    ],
                  ),
                  _ChipRow(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.gutter,
                      0,
                      AppSpace.gutter,
                      AppSpace.x3,
                    ),
                    children: [
                      for (final preset in TransactionHistoryDatePreset.values)
                        AppChoiceChip(
                          label: _dateLabel(state, preset),
                          selected: state.datePreset == preset,
                          onTap: () =>
                              preset == TransactionHistoryDatePreset.custom
                              ? _pickRange(context, state)
                              : cubit.setDatePreset(preset),
                        ),
                    ],
                  ),
                ],
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

String _dateLabel(
  TransactionHistoryState state,
  TransactionHistoryDatePreset preset,
) {
  switch (preset) {
    case TransactionHistoryDatePreset.anyTime:
      return 'Any time';
    case TransactionHistoryDatePreset.today:
      return 'Today';
    case TransactionHistoryDatePreset.yesterday:
      return 'Yesterday';
    case TransactionHistoryDatePreset.last7Days:
      return 'Last 7 days';
    case TransactionHistoryDatePreset.custom:
      final range = state.dateRange;
      if (state.datePreset != preset || range == null) return 'Custom range';
      final fmt = DateFormat('d MMM');
      return '${fmt.format(range.start)} - ${fmt.format(range.end)}';
  }
}

Future<void> _pickRange(
  BuildContext context,
  TransactionHistoryState state,
) async {
  final cubit = context.read<TransactionHistoryCubit>();
  final now = DateTime.now();
  final picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(now.year - 3),
    lastDate: DateTime(now.year, now.month, now.day),
    initialDateRange: state.datePreset == TransactionHistoryDatePreset.custom
        ? state.dateRange
        : null,
  );
  if (picked != null) await cubit.setCustomDateRange(picked);
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.padding, required this.children});

  final EdgeInsets padding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpace.x2),
            children[i],
          ],
        ],
      ),
    );
  }
}

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
      final filtered = state.hasActiveFilter;
      child = Center(
        key: ValueKey('empty-${state.filter}-${state.dateRange}'),
        child: SingleChildScrollView(
          child: EmptyState(
            icon: AppIcons.receipt,
            title: filtered
                ? 'No matching transactions'
                : 'No transactions yet',
            message: filtered
                ? 'Try another filter or date range.'
                : 'Collections you take will show up here.',
          ),
        ),
      );
    } else {
      child = ListView.separated(
        key: ValueKey('list-${state.filter}-${state.dateRange}'),
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
