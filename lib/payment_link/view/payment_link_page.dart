import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/payment_link/cubit/cubit.dart';
import 'package:geepay_pos/payment_link/view/payment_link_qr_page.dart';
import 'package:geepay_pos/payment_link/widgets/widgets.dart';
import 'package:services_repo/services_repo.dart';

class PaymentLinkPage extends StatelessWidget {
  const PaymentLinkPage({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      settings: const RouteSettings(name: '/payment-link'),
      builder: (_) => const PaymentLinkPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentLinkCubit(
        context.read<ServicesRepo>(),
        context.read<AuthRepo>(),
      ),
      child: BlocListener<PaymentLinkCubit, PaymentLinkState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == PaymentLinkStep.active) {
            final cubit = context.read<PaymentLinkCubit>();
            Navigator.of(context).push(
              MaterialPageRoute<dynamic>(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: const PaymentLinkQrPage(),
                ),
              ),
            );
          }
        },
        child: const Scaffold(
          backgroundColor: AppColors.surfacePage,
          body: PaymentLinkBody(),
        ),
      ),
    );
  }
}
