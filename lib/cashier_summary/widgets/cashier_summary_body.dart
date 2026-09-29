import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/cashier_summary/cubit/cubit.dart';
import 'package:geepay_pos/export/export.dart';
import 'package:geepay_pos/widgets/widgets.dart';

/// Builds the export totals from the loaded summary — the same figures
/// [_Content] renders, kept in one place so the header export action and
/// the on-screen cards can't drift apart.
SummaryExportData? _exportData(CashierSummaryState state) {
  final transactions = state.summary?.transactions;
  if (transactions == null || transactions.isEmpty) return null;
  final showBreakdown = state.filter == CashierSummaryFilter.all;
  return SummaryExportData(
    periodLabel: 'Today',
    filterLabel: state.filter.label,
    currency: state.summary!.currency,
    totalAmount: transactions.fold<double>(0, (s, t) => s + t.amount),
    transactionCount: transactions.length,
    successfulAmount: showBreakdown
        ? transactions
              .where((t) => t.isSuccessful)
              .fold<double>(0, (s, t) => s + t.amount)
        : null,
    successfulCount: showBreakdown
        ? transactions.where((t) => t.isSuccessful).length
        : null,
    failedAmount: showBreakdown
        ? transactions
              .where((t) => t.isFailed)
              .fold<double>(0, (s, t) => s + t.amount)
        : null,
    failedCount: showBreakdown
        ? transactions.where((t) => t.isFailed).length
        : null,
  );
}

class CashierSummaryBody extends StatelessWidget {
  const CashierSummaryBody({super.key});

  Future<void> _export(BuildContext context, SummaryExportData data) {
    return showExportSheet(
      context,
      onPdf: () => TransactionExport.summaryToPdf(
        title: 'Cashier summary',
        summary: data,
      ),
      onExcel: () => TransactionExport.summaryToExcel(
        title: 'Cashier summary',
        summary: data,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CashierSummaryCubit, CashierSummaryState>(
      builder: (context, state) {
        final cubit = context.read<CashierSummaryCubit>();
        final data = _exportData(state);
        return Column(
          children: [
            AppHeader(
              title: 'Cashier summary',
              actions: [
                AppIconButton(
                  icon: AppIcons.export,
                  tooltip: 'Export',
                  onPressed: data == null ? null : () => _export(context, data),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: cubit.load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpace.gutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _FilterTrigger(
                            label: 'Today',
                            onTap: () => showToast(
                              context,
                              message: 'Custom date ranges are coming soon',
                            ),
                          ),
                          const SizedBox(width: AppSpace.x2),
                          _FilterTrigger(
                            label: state.filter.label,
                            onTap: () => _pickFilter(context, cubit, state),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.x4),
                      AnimatedSwitcher(
                        duration: AppMotion.of(context, AppMotion.base),
                        child: _Content(
                          key: ValueKey('${state.status}-${state.filter}'),
                          state: state,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const _Footer(),
          ],
        );
      },
    );
  }

  Future<void> _pickFilter(
    BuildContext context,
    CashierSummaryCubit cubit,
    CashierSummaryState state,
  ) async {
    final selected = await showAppSheet<CashierSummaryFilter>(
      context,
      title: 'Filter by status',
      child: ListGroup(
        children: [
          for (final filter in CashierSummaryFilter.values)
            AppListTile(
              title: filter.label,
              leading: Icon(
                filter == state.filter
                    ? AppIcons.successFilled
                    : AppIcons.chevronRight,
                size: AppIconSize.md,
                color: filter == state.filter
                    ? AppColors.gpCobalt
                    : Colors.transparent,
              ),
              showChevron: false,
              onTap: () => Navigator.of(context).pop(filter),
            ),
        ],
      ),
    );
    if (selected != null) await cubit.setFilter(selected);
  }
}

/// Bordered dropdown-style trigger for the date/status pickers, matching
/// the mockup's chevron buttons.
class _FilterTrigger extends StatelessWidget {
  const _FilterTrigger({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Pressable(
        onTap: onTap,
        color: AppColors.surfaceWhite,
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.x3,
            vertical: AppSpace.x3,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label,
                ),
              ),
              const SizedBox(width: AppSpace.x2),
              const Icon(
                AppIcons.chevronDown,
                size: AppIconSize.sm,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, super.key});

  final CashierSummaryState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.summary == null) {
      return const _SummarySkeleton();
    }
    if (state.status == CashierSummaryStatus.failure && state.summary == null) {
      return Center(
        child: ErrorState(
          title: "Couldn't load your summary",
          message: state.errorMessage,
          onRetry: () => context.read<CashierSummaryCubit>().load(),
        ),
      );
    }
    final summary = state.summary;
    final transactions = summary?.transactions ?? const [];
    if (summary == null || transactions.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: AppIcons.receipt,
          title: 'No transactions yet today',
          message: 'Collections you take today will show up here.',
        ),
      );
    }

    final totalAmount = transactions.fold<double>(0, (s, t) => s + t.amount);
    final showBreakdown = state.filter == CashierSummaryFilter.all;
    final successfulCount = transactions.where((t) => t.isSuccessful).length;
    final failedCount = transactions.where((t) => t.isFailed).length;
    final successfulAmount = transactions
        .where((t) => t.isSuccessful)
        .fold<double>(0, (s, t) => s + t.amount);
    final failedAmount = transactions
        .where((t) => t.isFailed)
        .fold<double>(0, (s, t) => s + t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpace.x5),
          decoration: const BoxDecoration(
            gradient: AppGradients.hero,
            borderRadius: AppRadius.brLg,
            boxShadow: AppShadows.brandGlow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL AMOUNT',
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.onBrandLow,
                ),
              ),
              const SizedBox(height: AppSpace.x1),
              MoneyText(
                totalAmount,
                currency: summary.currency,
                fontSize: AppTextStyles.numDisplay,
                fontWeight: FontWeight.w700,
                color: AppColors.onBrandHigh,
                mutedColor: AppColors.onBrandMid,
                muteDecimals: true,
              ),
              const SizedBox(height: AppSpace.x1),
              Text(
                'Across ${transactions.length} '
                '${transactions.length == 1 ? 'transaction' : 'transactions'} '
                'today',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onBrandMid,
                ),
              ),
            ],
          ),
        ),
        if (showBreakdown) ...[
          const SizedBox(height: AppSpace.x3),
          Row(
            children: [
              Expanded(
                child: _BreakdownCard(
                  label: 'Successful',
                  amount: successfulAmount,
                  count: successfulCount,
                  currency: summary.currency,
                  tone: BadgeTone.success,
                ),
              ),
              const SizedBox(width: AppSpace.x3),
              Expanded(
                child: _BreakdownCard(
                  label: 'Failed',
                  amount: failedAmount,
                  count: failedCount,
                  currency: summary.currency,
                  tone: BadgeTone.danger,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpace.x3),
        AppCard(
          child: Row(
            children: [
              const AppIconTile(icon: AppIcons.calendar),
              const SizedBox(width: AppSpace.x3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${transactions.length}', style: AppTextStyles.title3),
                  Text(
                    'Total transactions today',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.label,
    required this.amount,
    required this.count,
    required this.currency,
    required this.tone,
  });

  final String label;
  final double amount;
  final int count;
  final String currency;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, dot) = switch (tone) {
      BadgeTone.success => (
        AppColors.successText,
        AppColors.successFill,
        AppColors.successIcon,
      ),
      BadgeTone.danger => (
        AppColors.dangerText,
        AppColors.dangerFill,
        AppColors.dangerIcon,
      ),
      _ => (
        AppColors.textSecondary,
        AppColors.surfaceSubtle,
        AppColors.textMuted,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.brLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSpace.x2,
                height: AppSpace.x2,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpace.x2),
              Text(
                label,
                style: AppTextStyles.captionStrong.copyWith(color: fg),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.x2),
          MoneyText(
            amount,
            currency: currency,
            fontSize: AppTextStyles.numLg,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
          const SizedBox(height: AppSpace.x1),
          Text(
            '$count ${count == 1 ? 'transaction' : 'transactions'}',
            style: AppTextStyles.caption.copyWith(
              color: fg.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return const Skeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonBox(
            width: double.infinity,
            height: 128,
            borderRadius: AppRadius.brLg,
          ),
          SizedBox(height: AppSpace.x3),
          Row(
            children: [
              Expanded(
                child: SkeletonBox(
                  width: double.infinity,
                  height: 96,
                  borderRadius: AppRadius.brLg,
                ),
              ),
              SizedBox(width: AppSpace.x3),
              Expanded(
                child: SkeletonBox(
                  width: double.infinity,
                  height: 96,
                  borderRadius: AppRadius.brLg,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x3),
          SkeletonBox(
            width: double.infinity,
            height: 72,
            borderRadius: AppRadius.brLg,
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.gutter,
            AppSpace.x3,
            AppSpace.gutter,
            AppSpace.x4,
          ),
          child: AppButton(
            label: 'Print summary',
            icon: AppIcons.printer,
            onPressed: () {
              // TODO(anyone): wire to a working printer integration.
              showToast(context, message: 'Printing is coming soon');
            },
          ),
        ),
      ),
    );
  }
}
