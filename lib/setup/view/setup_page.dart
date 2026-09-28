import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/login/login.dart';
import 'package:geepay_pos/setup/cubit/cubit.dart';
import 'package:geepay_pos/setup/widgets/setup_body.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(builder: (_) => const SetupPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SetupCubit(context.read<AuthRepo>()),
      child: BlocListener<SetupCubit, SetupState>(
        listener: (context, state) {
          if (state.status == SetupStatus.success) {
            Navigator.of(context).pushReplacement(LoginPage.route());
          }
        },
        child: const Scaffold(
          backgroundColor: AppColors.surfacePage,
          body: SetupBody(),
        ),
      ),
    );
  }
}
