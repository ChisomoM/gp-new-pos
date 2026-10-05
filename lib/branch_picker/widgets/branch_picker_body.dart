import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/widgets/widgets.dart';

/// Body of [BranchPickerPage]: a list of the merchant's branches to
/// assign this device to, with a "Skip for now" fallback — a device
/// without a branch is a valid state, not an error (see
/// `pos_mobile_app_endpoints.md` §0c).
class BranchPickerBody extends StatefulWidget {
  const BranchPickerBody({
    required this.branches,
    required this.onSelected,
    required this.onSkip,
    super.key,
  });

  final List<(String id, String name)> branches;
  final Future<void> Function(String branchId) onSelected;
  final Future<void> Function() onSkip;

  @override
  State<BranchPickerBody> createState() => _BranchPickerBodyState();
}

class _BranchPickerBodyState extends State<BranchPickerBody> {
  bool _isSubmitting = false;
  String? _pendingBranchId;

  Future<void> _select(String branchId) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _pendingBranchId = branchId;
    });
    await widget.onSelected(branchId);
    if (mounted) setState(() => _isSubmitting = false);
  }

  Future<void> _skip() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    await widget.onSkip();
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppHeader(title: 'Select your branch', showBack: false),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpace.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Which branch is this?', style: AppTextStyles.title2),
                const SizedBox(height: AppSpace.x1),
                Text(
                  'This assigns the terminal to a branch so its '
                  'transactions are grouped correctly. You can change '
                  'this later.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpace.x6),
                ListGroup(
                  children: [
                    for (final branch in widget.branches)
                      AppListTile(
                        leading: const AppIconTile(icon: AppIcons.business),
                        title: branch.$2,
                        trailing: _isSubmitting && _pendingBranchId == branch.$1
                            ? const SizedBox.square(
                                dimension: AppIconSize.md,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : null,
                        onTap: _isSubmitting ? null : () => _select(branch.$1),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter,
                AppSpace.x3,
                AppSpace.gutter,
                AppSpace.x4,
              ),
              child: AppButton.tertiary(
                label: 'Skip for now',
                expand: true,
                onPressed: _isSubmitting ? null : _skip,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
