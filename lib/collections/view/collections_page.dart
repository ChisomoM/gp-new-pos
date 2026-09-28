import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/collections/cubit/cubit.dart';
import 'package:geepay_pos/collections/view/collection_status_page.dart';
import 'package:geepay_pos/collections/widgets/widgets.dart';
import 'package:services_repo/services_repo.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      settings: const RouteSettings(name: '/collections'),
      builder: (_) => const CollectionsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollectionsCubit(
        context.read<ServicesRepo>(),
        context.read<AuthRepo>(),
      ),
      child: BlocListener<CollectionsCubit, CollectionsState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == CollectionsStep.polling) {
            final cubit = context.read<CollectionsCubit>();
            Navigator.of(context).push(
              MaterialPageRoute<dynamic>(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: const CollectionStatusPage(),
                ),
              ),
            );
          }
        },
        child: const Scaffold(
          backgroundColor: AppColors.surfacePage,
          body: CollectionsBody(),
        ),
      ),
    );
  }
}
