import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/setup/cubit/cubit.dart';
import 'package:geepay_pos/widgets/widgets.dart';

class SetupBody extends StatefulWidget {
  const SetupBody({super.key});

  @override
  State<SetupBody> createState() => _SetupBodyState();
}

class _SetupBodyState extends State<SetupBody> {
  final _name = TextEditingController();
  final _serialNumber = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _serialNumber.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit(SetupCubit cubit) {
    cubit.submit(
      name: _name.text,
      serialNumber: _serialNumber.text,
      phoneNumber: _phone.text,
    );
  }

  Future<void> _pickTerminalType(BuildContext context, SetupState state) {
    return showAppSheet<void>(
      context,
      title: 'Terminal type',
      child: ListGroup(
        children: [
          for (final type in state.terminalTypes)
            AppListTile(
              title: type.$2,
              leading: Icon(
                type.$1 == state.selectedTerminalTypeId
                    ? AppIcons.successFilled
                    : null,
                size: AppIconSize.md,
                color: AppColors.gpCobalt,
              ),
              showChevron: false,
              onTap: () {
                context.read<SetupCubit>().selectTerminalType(
                  type.$1,
                  type.$2,
                );
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupCubit, SetupState>(
      builder: (context, state) {
        final deviceId = state.deviceId;
        final deviceCode = deviceId == null
            ? null
            : 'GP-POS-${deviceId.substring(0, 6).toUpperCase()}';
        return Column(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppGradients.hero,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.xl),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.gutter,
                    AppSpace.x8,
                    AppSpace.gutter,
                    AppSpace.x6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(AppLogos.wordmarkWhite, width: 135),
                      const SizedBox(height: AppSpace.x6),
                      Text(
                        'Set up this device',
                        style: AppTextStyles.title1.copyWith(
                          color: AppColors.onBrandHigh,
                        ),
                      ),
                      const SizedBox(height: AppSpace.x1),
                      Text(
                        'Register this terminal so it can be assigned to '
                        'your business at login.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.onBrandMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  AppSpace.x6,
                  AppSpace.gutter,
                  AppSpace.x4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Device name',
                      controller: _name,
                      hintText: 'e.g. Front counter terminal',
                      textInputAction: TextInputAction.next,
                      errorText: state.nameError,
                      onChanged: (_) =>
                          context.read<SetupCubit>().nameChanged(),
                    ),
                    const SizedBox(height: AppSpace.field),
                    AppTextField(
                      label: 'Serial number',
                      controller: _serialNumber,
                      hintText: 'Printed on the device',
                      textInputAction: TextInputAction.next,
                      errorText: state.serialNumberError,
                      onChanged: (_) =>
                          context.read<SetupCubit>().serialNumberChanged(),
                    ),
                    const SizedBox(height: AppSpace.field),
                    _TerminalTypeField(
                      value: state.selectedTerminalTypeName,
                      enabled: state.terminalTypes.isNotEmpty,
                      onTap: () => _pickTerminalType(context, state),
                    ),
                    const SizedBox(height: AppSpace.field),
                    AppTextField(
                      label: 'Phone number',
                      controller: _phone,
                      hintText: '0973 042 237',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      helperText: 'Optional',
                    ),
                    const SizedBox(height: AppSpace.field),
                    AppCard(
                      child: Row(
                        children: [
                          const AppIconTile(icon: AppIcons.device),
                          const SizedBox(width: AppSpace.x3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Device fingerprint',
                                  style: AppTextStyles.bodyStrong,
                                ),
                                AnimatedSwitcher(
                                  duration: AppMotion.of(
                                    context,
                                    AppMotion.base,
                                  ),
                                  child: deviceCode == null
                                      ? const Padding(
                                          padding: EdgeInsets.only(
                                            top: AppSpace.x1,
                                          ),
                                          child: Skeleton(
                                            child: SkeletonBox(width: 104),
                                          ),
                                        )
                                      : Text(
                                          deviceCode,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                          if (deviceId != null)
                            const StatusBadge(
                              label: 'Detected',
                              tone: BadgeTone.success,
                              showDot: true,
                            )
                          else
                            const StatusBadge(label: 'Detecting'),
                        ],
                      ),
                    ),
                    AnimatedAlert(
                      message: state.status == SetupStatus.failure
                          ? state.errorMessage
                          : null,
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
                  child: AppButton(
                    label: 'Complete setup',
                    isLoading: state.isSubmitting,
                    onPressed: state.deviceId == null
                        ? null
                        : () => _submit(context.read<SetupCubit>()),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TerminalTypeField extends StatelessWidget {
  const _TerminalTypeField({
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final String? value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Terminal type', style: AppTextStyles.label),
            const SizedBox(width: AppSpace.x1),
            Text(
              'Optional',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.label),
        Pressable(
          onTap: enabled ? onTap : null,
          border: Border.all(color: AppColors.borderMedium, width: 1.5),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.x4,
              vertical: AppSpace.x4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ??
                        (enabled ? 'Select a terminal type' : 'None available'),
                    style: AppTextStyles.bodyLg.copyWith(
                      color: value == null
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  AppIcons.chevronDown,
                  size: AppIconSize.sm,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
