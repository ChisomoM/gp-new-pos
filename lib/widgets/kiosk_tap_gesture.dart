import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geepay_pos/settings/widgets/kiosk_exit_dialog.dart';
import 'package:geepay_pos/utils/kiosk_helper.dart';

/// Checks the kiosk lock's current state and either shows the PIN-exit
/// dialog (if locked) or re-locks immediately with no PIN (if already
/// unlocked -- locking down is always the safe direction, so only exiting
/// needs the PIN gate). Shared by every tap-to-toggle entry point: the
/// Settings app-version row and the Login screen's footer row.
Future<void> triggerKioskToggle(BuildContext context) async {
  final authRepo = context.read<AuthRepo>();
  final active = await KioskHelper.isKioskActive();
  if (!context.mounted) return;
  if (!active) {
    await KioskHelper.enterKiosk(authRepo);
    return;
  }
  final status = await authRepo.getKioskStatus();
  if (!context.mounted) return;
  await showKioskExitDialog(
    context,
    expectedPin: authRepo.kioskExitPin,
    status: status,
  );
}

/// Wraps [child] with a hidden tap gesture: 7 taps within 2 seconds (the
/// common "tap version to unlock" convention) triggers [triggerKioskToggle].
/// Deliberately not a visible button -- see the kiosk-lock implementation
/// plan.
class KioskTapGesture extends StatefulWidget {
  const KioskTapGesture({required this.child, super.key});

  final Widget child;

  @override
  State<KioskTapGesture> createState() => _KioskTapGestureState();
}

class _KioskTapGestureState extends State<KioskTapGesture> {
  static const _tapsToUnlock = 7;
  static const _tapWindow = Duration(seconds: 2);

  int _tapCount = 0;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    _resetTimer?.cancel();
    _tapCount++;
    if (_tapCount < _tapsToUnlock) {
      _resetTimer = Timer(_tapWindow, () => _tapCount = 0);
      return;
    }
    _tapCount = 0;
    unawaited(triggerKioskToggle(context));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: widget.child,
    );
  }
}
