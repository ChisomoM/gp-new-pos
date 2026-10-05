import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/payment_link/cubit/cubit.dart';
import 'package:geepay_pos/payment_link/view/payment_link_result_page.dart';
import 'package:geepay_pos/payment_link/widgets/widgets.dart';

class PaymentLinkQrPage extends StatelessWidget {
  const PaymentLinkQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentLinkCubit, PaymentLinkState>(
      listenWhen: (previous, current) => previous.step != current.step,
      listener: (context, state) {
        if (state.step == PaymentLinkStep.done) {
          final cubit = context.read<PaymentLinkCubit>();
          Navigator.of(context).push(
            MaterialPageRoute<dynamic>(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const PaymentLinkResultPage(),
              ),
            ),
          );
        }
      },
      child: const Scaffold(
        backgroundColor: AppColors.surfacePage,
        body: PaymentLinkQrBody(),
      ),
    );
  }
}
