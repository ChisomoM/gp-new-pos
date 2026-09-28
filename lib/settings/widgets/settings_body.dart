import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/app/theme/app_gradients.dart';
import 'package:geepay_pos/auth/auth.dart';
import 'package:geepay_pos/printer_settings/view/printer_settings_page.dart';
import 'package:geepay_pos/splash/view/splash_page.dart';
import 'package:geepay_pos/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// {@template settings_body}
/// Body of the Settings tab: a flat white [BackHeader], a gradient profile
/// summary card (the same brand gradient/shadow tokens used for hero
/// sections and CTA buttons — see [AppGradients.hero]), grouped
/// "Business"/"App" setting tiles with elevated cards, and a logout button.
/// {@endtemplate}
class SettingsBody extends StatelessWidget {
  /// {@macro settings_body}
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BackHeader(title: 'Settings'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ProfileCard(),
                const SizedBox(height: 22),
                const _SectionLabel('Business'),
                const SizedBox(height: 8),
                const _SettingsCard(
                  children: [
                    _CompanyProfileTile(),
                    _SettingsTileDivider(),
                    _PrinterSettingsTile(),
                  ],
                ),
                const SizedBox(height: 22),
                const _SectionLabel('App'),
                const SizedBox(height: 8),
                const _SettingsCard(
                  children: [
                    _UpdatesTile(),
                    _SettingsTileDivider(),
                    _AppVersionTile(),
                  ],
                ),
                const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppGradients.gradientButton,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Text(
              initial,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.5,
                    color: Colors.white,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppGradients.card,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTileDivider extends StatelessWidget {
  const _SettingsTileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.divider);
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.gpCobalt,
    this.iconBackground = AppColors.infoFill,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

class _CompanyProfileTile extends StatelessWidget {
  const _CompanyProfileTile();

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: Iconsax.building,
      title: 'Company profile',
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const PlaceholderScreen(title: 'Company profile'),
        ),
      ),
    );
  }
}

class _PrinterSettingsTile extends StatelessWidget {
  const _PrinterSettingsTile();

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: Iconsax.printer,
      title: 'Printer settings',
      subtitle: 'Choose your default receipt printer',
      onTap: () => Navigator.of(context).push(PrinterSettingsPage.route()),
    );
  }
}

class _UpdatesTile extends StatelessWidget {
  const _UpdatesTile();

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: Iconsax.refresh_circle,
      title: 'Updates',
      iconColor: AppColors.successIcon,
      iconBackground: AppColors.successFill,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.successFill,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'UP TO DATE',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.successText,
            letterSpacing: 0.3,
          ),
        ),
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
    return _SettingsTile(
      icon: Iconsax.info_circle,
      title: 'App version',
      trailing: Text(
        appVersion.isEmpty ? '—' : appVersion,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
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
    );
    if (confirmed != true || !context.mounted) return;
    context.read<AuthBloc>().add(AuthLogoutRequested());
    await Navigator.of(context).pushAndRemoveUntil(
      SplashPage.route(),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.dangerFillAlt),
          backgroundColor: AppColors.dangerFill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(
          Iconsax.logout,
          size: 18,
          color: AppColors.dangerText,
        ),
        label: const Text(
          'Log out',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.dangerText,
          ),
        ),
      ),
    );
  }
}
