import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geepay_pos/branch_picker/widgets/branch_picker_body.dart';
import 'package:geepay_pos/main/view/main_page.dart';

/// Shown right after a successful login when this device has no branch
/// yet and the merchant has branches to choose from (flow step 3, see
/// `pos_mobile_app_endpoints.md` §0c). Picking one — or skipping — claims
/// the device (`PUT /v1/pos/devices/:id`) and lands on the Dashboard.
class BranchPickerPage extends StatelessWidget {
  const BranchPickerPage({
    required this.deviceId,
    required this.branches,
    super.key,
  });

  final String deviceId;
  final List<(String id, String name)> branches;

  static Route<dynamic> route({
    required String deviceId,
    required List<(String id, String name)> branches,
  }) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => BranchPickerPage(deviceId: deviceId, branches: branches),
    );
  }

  Future<void> _finish(BuildContext context, String? branchId) async {
    await context.read<AuthRepo>().claimPosDevice(deviceId, branchId: branchId);
    if (!context.mounted) return;
    await Navigator.of(context).pushReplacement(MainPage.route());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BranchPickerBody(
        branches: branches,
        onSelected: (branchId) => _finish(context, branchId),
        onSkip: () => _finish(context, null),
      ),
    );
  }
}
