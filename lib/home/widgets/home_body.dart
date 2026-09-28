import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/app/theme/app_gradients.dart';
import 'package:geepay_pos/app/theme/app_logos.dart';
import 'package:geepay_pos/app/theme/app_text_styles.dart';
import 'package:geepay_pos/auth/auth.dart';
import 'package:geepay_pos/collections/collections.dart';
import 'package:geepay_pos/home/cubit/cubit.dart';
import 'package:geepay_pos/models/transaction.dart';
import 'package:geepay_pos/transaction_details/transaction_details.dart';
import 'package:geepay_pos/transaction_history/transaction_history.dart';
import 'package:geepay_pos/utils/screen_size.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

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
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GroupedToolbarCard(
                          items: [
                            GroupedToolbarItem(
                              icon: Iconsax.send_2,
                              label: 'Collections',
                              onTap: () => Navigator.of(
                                context,
                              ).push(CollectionsPage.route()),
                            ),
                            // GroupedToolbarItem(
                            //   icon: Iconsax.box_1,
                            //   label: 'Packages',
                            //   onTap: () =>
                            //       _openPlaceholder(context, 'Packages'),
                            // ),
                            GroupedToolbarItem(
                              icon: Iconsax.chart_21,
                              label: 'Summary',
                              onTap: () => _openPlaceholder(
                                context,
                                'Cashier Summary',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent transactions',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => Navigator.of(
                                  context,
                                ).push(TransactionHistoryPage.route()),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    'View all',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gpCobalt,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
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
                  Colors.white,
                  BlendMode.srcIn,
                ),
                child: Image.asset(AppLogos.gMark, width: wp(265)),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color.fromRGBO(255, 255, 255, 0.68),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName.isEmpty ? 'Cashier' : userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 21,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromRGBO(255, 255, 255, 0.16),
                          ),
                          color: const Color.fromRGBO(255, 255, 255, 0.08),
                        ),
                        child: const Icon(
                          Iconsax.notification,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.only(top: 18),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color.fromRGBO(255, 255, 255, 0.12),
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "TODAY'S COLLECTIONS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(255, 255, 255, 0.6),
                            letterSpacing: 0.6,
                          ),
                        ),
                        // const SizedBox(height: ),
                        if (state.isLoading) const SizedBox(
                                height: 32,
                                width: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              ) else Text(
                                '$currency ${amount.toStringAsFixed(2)}',
                                style: AppTextStyles.gpNum(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 32,
                                  color: Colors.white,
                                ),
                              ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _Dot(
                              color: const Color(0xFF6EE7B7),
                              label: '${counts?.successful ?? 0} successful',
                            ),
                            const SizedBox(width: 16),
                            _Dot(
                              color: const Color(0xFFFCA5A5),
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
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color.fromRGBO(255, 255, 255, 0.78),
          ),
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
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.status == HomeStatus.failure) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          state.errorMessage ?? 'Unable to load transactions',
          style: const TextStyle(fontSize: 13, color: AppColors.dangerIcon),
        ),
      );
    }
    final transactions = state.data?.transactions ?? const <Transaction>[];
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No transactions yet today',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final tx in transactions.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TransactionRow(
              title: tx.phoneNumber,
              subtitle: '${tx.channelLabel} · Collection',
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
