import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._authRepo) : super(const SplashState()) {
    _decide();
  }

  final AuthRepo _authRepo;

  // Device registration now happens outside the app (provisioned by the
  // system before the app is ever opened), so Splash no longer checks
  // AuthRepo.isDeviceRegistered()/routes to Setup — only auth status decides
  // where we land. The Setup screen and AuthRepo.registerDevice() are kept
  // in place, unused, in case device registration needs to move back into
  // the app later.
  Future<void> _decide() async {
    final status = await _authRepo.status.first;
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
