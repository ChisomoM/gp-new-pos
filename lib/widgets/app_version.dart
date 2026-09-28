import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geepay_pos/auth/auth.dart';

/// "Version 1.2.3" in the surrounding [DefaultTextStyle]. Renders nothing
/// until the version is known.
class AppVersion extends StatelessWidget {
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    final appVersion = context.select<AuthBloc, String>(
      (bloc) => bloc.state.appVersion,
    );
    if (appVersion.isEmpty) return const SizedBox.shrink();
    return Text(
      'Version $appVersion',
      semanticsLabel: 'App version $appVersion',
    );
  }
}
