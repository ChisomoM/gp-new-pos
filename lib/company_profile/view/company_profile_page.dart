import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/company_profile/widgets/widgets.dart';

class CompanyProfilePage extends StatelessWidget {
  const CompanyProfilePage({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const CompanyProfilePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: CompanyProfileBody(),
    );
  }
}
