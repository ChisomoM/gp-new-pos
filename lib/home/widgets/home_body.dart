import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/auth/auth.dart';
import 'package:geepay_pos/collections/collections.dart';
import 'package:geepay_pos/home/cubit/cubit.dart';
import 'package:geepay_pos/models/transaction.dart';
import 'package:geepay_pos/transaction_details/transaction_details.dart';
import 'package:geepay_pos/transaction_history/transaction_history.dart';
import 'package:geepay_pos/utils/screen_size.dart';
import 'package:geepay_pos/widgets/widgets.dart';

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// {@template home_body}
/// Body of the HomePage — the Dashboard.
/// {@endtemplate}
class HomeBody extends StatelessWidget {
  /// {@macro home_body}
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = context.select<AuthBloc, String>(
      (bloc) => bloc.state.user.name ?? '',
    );
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().load(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Hero(userName: userName, state: state),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  AppSpace.x12,
                  AppSpace.gutter,
                  AppSpace.x4,
                ),
                sliver: SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GroupedToolbarCard(
                          items: [
                            GroupedToolbarItem(
                              icon: AppIcons.receive,
                              label: 'Collections',
                              onTap: () => Navigator.of(
                                context,
                              ).push(CollectionsPage.route()),
                            ),
                            GroupedToolbarItem(
                              icon: AppIcons.summary,
                              label: 'Summary',
                              onTap: () => _openPlaceholder(
                                context,
                                'Cashier Summary',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.section),
                        SectionHeader(
                          title: 'Recent transactions',
                          actionLabel: 'View all',
                          onAction: () => Navigator.of(
                            context,
                          ).push(TransactionHistoryPage.route()),
                        ),
                        const SizedBox(height: AppSpace.x2),
                        _RecentTransactions(state: state),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPlaceholder(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlaceholderScreen(title: title),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.userName, required this.state});

  final String userName;
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final counts = state.data?.statusCounts;
    final amount = state.data?.totalSuccessfulAmount ?? 0;
    final currency = state.data?.currency ?? 'ZMW';
    // Only show the skeleton on first load; refreshes keep the last value
    // on screen and count up to the new one.
    final showSkeleton = state.isLoading && state.data == null;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -75,
            top: 125,
            child: Opacity(
              opacity: 0.10,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  AppColors.onBrandHigh,
                  BlendMode.srcIn,
                ),
                child: Image.asset(AppLogos.gMark, width: wp(265)),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter,
                AppSpace.x6,
                AppSpace.gutter,
                AppSpace.x6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.onBrandMid,
                    ),
                  ),
                  Text(
                    userName.isEmpty ? 'Cashier' : userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title2.copyWith(
                      color: AppColors.onBrandHigh,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: AppSpace.x5),
                    padding: const EdgeInsets.only(top: AppSpace.x4),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.onBrandStroke),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TODAY'S COLLECTIONS",
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.onBrandLow,
                          ),
                        ),
                        const SizedBox(height: AppSpace.x1),
                        SizedBox(
                          height: 40,
                          child: AnimatedSwitcher(
                            duration: AppMotion.of(context, AppMotion.base),
                            layoutBuilder: (current, previous) => Stack(
                              alignment: Alignment.centerLeft,
                              children: [...previous, ?current],
                            ),
                            child: showSkeleton
                                ? const Skeleton(
                                    key: ValueKey('skeleton'),
                                    onBrand: true,
                                    child: SkeletonBox(
                                      width: 180,
                                      height: AppSpace.x8,
                                      borderRadius: AppRadius.brSm,
                                    ),
                                  )
                                : MoneyText(
                                    amount,
                                    key: const ValueKey('amount'),
                                    currency: currency,
                                    fontSize: AppTextStyles.numDisplay,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onBrandHigh,
                                    mutedColor: AppColors.onBrandMid,
                                    muteDecimals: true,
                                    animate: true,
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppSpace.x2),
                        Row(
                          children: [
                            _Dot(
                              color: AppColors.successOnBrand,
                              label: '${counts?.successful ?? 0} successful',
                            ),
                            const SizedBox(width: AppSpace.x4),
                            _Dot(
                              color: AppColors.dangerOnBrand,
                              label: '${counts?.failed ?? 0} failed',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSpace.x2,
          height: AppSpace.x2,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpace.x2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.onBrandMid),
        ),
      ],
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final transactions = state.data?.transactions ?? const <Transaction>[];
    final Widget child;
    if (state.isLoading && state.data == null) {
      child = const SkeletonTransactionList(
        key: ValueKey('loading'),
        count: 3,
      );
    } else if (state.status == HomeStatus.failure && state.data == null) {
      child = ErrorState(
        key: const ValueKey('error'),
        title: "Couldn't load transactions",
        message: state.errorMessage,
        onRetry: () => context.read<HomeCubit>().load(),
      );
    } else if (transactions.isEmpty) {
      child = EmptyState(
        key: const ValueKey('empty'),
        icon: AppIcons.receipt,
        title: 'No transactions yet today',
        message: 'Collections you take today will show up here.',
        action: AppButton.secondary(
          label: 'New collection',
          icon: AppIcons.receive,
          size: AppButtonSize.md,
          expand: false,
          onPressed: () => Navigator.of(context).push(CollectionsPage.route()),
        ),
      );
    } else {
      child = Column(
        key: const ValueKey('list'),
        children: [
          for (final tx in transactions.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.x2),
              child: TransactionRow(
                title: tx.phoneNumber,
                subtitle: '${tx.channelLabel} · Collection',
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
              ),
            ),
        ],
      );
    }
    return AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.base),
      child: child,
    );
  }
}
