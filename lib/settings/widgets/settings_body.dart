import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/auth/auth.dart';
import 'package:geepay_pos/company_profile/company_profile.dart';
import 'package:geepay_pos/printer_settings/view/printer_settings_page.dart';
import 'package:geepay_pos/widgets/widgets.dart';

/// {@template settings_body}
/// Body of the Settings tab: a large tab header, a gradient profile
/// summary card, grouped "Business" / "App" rows and a log out button.
/// {@endtemplate}
class SettingsBody extends StatelessWidget {
  /// {@macro settings_body}
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppHeader.large(title: 'Settings'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpace.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ProfileCard(),
                const SizedBox(height: AppSpace.section),
                const SectionHeader(title: 'Business', overline: true),
                const SizedBox(height: AppSpace.x2),
                ListGroup(
                  children: [
                    AppListTile(
                      leading: const AppIconTile(icon: AppIcons.business),
                      title: 'Company profile',
                      onTap: () => Navigator.of(
                        context,
                      ).push(CompanyProfilePage.route()),
                    ),
                    AppListTile(
                      leading: const AppIconTile(icon: AppIcons.printer),
                      title: 'Printer settings',
                      subtitle: 'Choose your default receipt printer',
                      onTap: () => Navigator.of(
                        context,
                      ).push(PrinterSettingsPage.route()),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.section),
                const SectionHeader(title: 'App', overline: true),
                const SizedBox(height: AppSpace.x2),
                const ListGroup(
                  children: [
                    AppListTile(
                      leading: AppIconTile(
                        icon: AppIcons.refresh,
                        color: AppColors.successIcon,
                        background: AppColors.successFill,
                      ),
                      title: 'Updates',
                      trailing: StatusBadge(
                        label: 'Up to date',
                        tone: BadgeTone.success,
                      ),
                    ),
                    _AppVersionTile(),
                  ],
                ),
                const SizedBox(height: AppSpace.section),
                const _LogoutButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, User>((bloc) => bloc.state.user);
    final name = (user.name?.isNotEmpty ?? false) ? user.name! : 'Cashier';
    final subtitle = (user.email?.isNotEmpty ?? false)
        ? user.email!
        : (user.phone ?? '');
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';
    return Container(
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
              border: Border.all(color: AppColors.onBrandLow, width: 1.5),
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
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
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
    );
  }
}

class _AppVersionTile extends StatelessWidget {
  const _AppVersionTile();

  @override
  Widget build(BuildContext context) {
    final appVersion = context.select<AuthBloc, String>(
      (bloc) => bloc.state.appVersion,
    );
    return AppListTile(
      leading: const AppIconTile(icon: AppIcons.info),
      title: 'App version',
      trailing: Text(
        appVersion.isEmpty ? '-' : appVersion,
        style: AppTextStyles.bodyStrong.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showAppDialog(
      context,
      title: 'Log out',
      message: 'Are you sure you want to log out of this device?',
      yesText: 'Log out',
      noText: 'Cancel',
      destructive: true,
      icon: AppIcons.logout,
    );
    if (confirmed != true || !context.mounted) return;
    // Navigation to the login screen is handled by the AuthBloc listener in
    // App once the session has actually been cleared.
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return AppButton.destructive(
      label: 'Log out',
      icon: AppIcons.logout,
      onPressed: () => _confirmLogout(context),
    );
  }
}
