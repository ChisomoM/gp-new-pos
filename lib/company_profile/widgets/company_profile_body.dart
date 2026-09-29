import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/auth/auth.dart';
import 'package:geepay_pos/widgets/widgets.dart';

/// Read-only "Company profile" screen: the merchant/business fields the
/// design calls for aren't returned anywhere in the backend today (no
/// `pos_mobile_app_endpoints.md` route, no field on the login response's
/// user record beyond identity/contact info), so this shows what the app
/// actually has from the signed-in session rather than inventing business
/// details that don't exist yet.
class CompanyProfileBody extends StatelessWidget {
  const CompanyProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, User>((bloc) => bloc.state.user);
    final name = (user.name?.isNotEmpty ?? false) ? user.name! : 'Cashier';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';
    final accountType = _titleCase(user.accountType);

    return Column(
      children: [
        const AppHeader(title: 'Company profile'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpace.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpace.x4),
                  decoration: const BoxDecoration(
                    gradient: AppGradients.hero,
                    borderRadius: AppRadius.brLg,
                    boxShadow: AppShadows.brandGlow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: AppSpace.x12,
                        height: AppSpace.x12,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.onBrandStroke,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.onBrandLow,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          initial,
                          style: AppTextStyles.title3.copyWith(
                            color: AppColors.onBrandHigh,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpace.x4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.headline.copyWith(
                                color: AppColors.onBrandHigh,
                              ),
                            ),
                            if (accountType.isNotEmpty)
                              Text(
                                accountType,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.onBrandMid,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.section),
                const SectionHeader(title: 'Account details', overline: true),
                const SizedBox(height: AppSpace.x2),
                KeyValueList(
                  items: [
                    KeyValueItem('Account holder', name),
                    if (accountType.isNotEmpty)
                      KeyValueItem('Account type', accountType),
                    KeyValueItem(
                      'Email',
                      (user.email?.isNotEmpty ?? false) ? user.email! : '-',
                    ),
                    KeyValueItem(
                      'Phone',
                      (user.phone?.isNotEmpty ?? false) ? user.phone! : '-',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.x3),
                Text(
                  'Business details (registration name, address, tax ID) '
                  "aren't available from Geepay yet. This screen will show "
                  'them once that data is added to your account.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _titleCase(String? value) {
    if (value == null || value.isEmpty) return '';
    return value
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }
}
