import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geepay_pos/utils/kiosk_helper.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._authRepo, {
    this.minimumDisplay = const Duration(milliseconds: 600),
  }) : super(const SplashState()) {
    _decide();
  }

  final AuthRepo _authRepo;

  /// Splash stays up at least this long so a fast session check doesn't
  /// flash the brand screen for a single frame.
  final Duration minimumDisplay;

  // Per `pos_mobile_app_endpoints.md`'s Suggested end-to-end flow: an
  // unregistered device goes to Setup first (§1); a registered device with
  // no active session goes to Login (§0a); an authenticated session goes
  // straight to Main. Device registration is a real prerequisite for the
  // post-login branch/device-claim step (`AuthRepo.syncDeviceAssignment`),
  // which needs the `gp_pos_tms` device id Setup obtains.
  Future<void> _decide() async {
    final (status, isRegistered, kioskEnabled, _) = await (
      _authRepo.status.first,
      _authRepo.isDeviceRegistered(),
      _authRepo.isKioskModeEnabled(),
      Future<void>.delayed(minimumDisplay),
    ).wait;
    if (isClosed) return;
    if (kioskEnabled) {
      await KioskHelper.enterKiosk();
      if (isClosed) return;
    }
    emit(
      SplashState(
        destination: !isRegistered
            ? SplashDestination.setup
            : status == AuthStatus.authenticated
            ? SplashDestination.main
            : SplashDestination.login,
      ),
    );
  }
}
