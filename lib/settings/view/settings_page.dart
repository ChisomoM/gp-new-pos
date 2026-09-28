import 'package:flutter/material.dart';
import 'package:geepay_pos/settings/widgets/settings_body.dart';

/// {@template settings_page}
/// Standalone route wrapper for [SettingsBody] — used when Settings is
/// pushed rather than shown as a bottom-nav tab.
/// {@endtemplate}
class SettingsPage extends StatelessWidget {
  /// {@macro settings_page}
  const SettingsPage({super.key});

  /// The static route for SettingsPage.
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(builder: (_) => const SettingsPage());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SettingsBody());
  }
}
