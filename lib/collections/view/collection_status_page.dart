import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/collections/cubit/cubit.dart';
import 'package:geepay_pos/collections/view/collection_result_page.dart';
import 'package:geepay_pos/collections/widgets/widgets.dart';

class CollectionStatusPage extends StatelessWidget {
  const CollectionStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollectionsCubit, CollectionsState>(
      listenWhen: (previous, current) => previous.step != current.step,
      listener: (context, state) {
        if (state.step == CollectionsStep.done) {
          final cubit = context.read<CollectionsCubit>();
          Navigator.of(context).push(
            MaterialPageRoute<dynamic>(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const CollectionResultPage(),
              ),
            ),
          );
        }
      },
      child: const Scaffold(
        backgroundColor: AppColors.surfacePage,
        body: CollectionStatusBody(),
      ),
    );
  }
}
