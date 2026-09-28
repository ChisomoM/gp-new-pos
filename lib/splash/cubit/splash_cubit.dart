import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

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

  // Device registration now happens outside the app (provisioned by the
  // system before the app is ever opened), so Splash no longer checks
  // AuthRepo.isDeviceRegistered()/routes to Setup — only auth status decides
  // where we land. The Setup screen and AuthRepo.registerDevice() are kept
  // in place, unused, in case device registration needs to move back into
  // the app later.
  Future<void> _decide() async {
    final (status, _) = await (
      _authRepo.status.first,
      Future<void>.delayed(minimumDisplay),
    ).wait;
    if (isClosed) return;
    emit(
      SplashState(
        destination: status == AuthStatus.authenticated
            ? SplashDestination.main
            : SplashDestination.login,
      ),
    );
  }
}
