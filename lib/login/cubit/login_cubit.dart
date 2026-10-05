import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepo) : super(const LoginState());

  final AuthRepo _authRepo;

  /// Logs in via `POST /auth/pos/login` (see `pos_mobile_app_endpoints.md`
  /// §0a) — a single request, no OTP step — then resolves this device's
  /// branch/merchant assignment (flow steps 3-4) before landing on the
  /// Dashboard: if the device has no branch yet and the merchant has any
  /// branches to choose from, emits `needsBranchSelection` so the UI can
  /// show the picker; otherwise claims the device (if unassigned) and
  /// goes straight to `success`.
  Future<void> submit({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final emailError = trimmedEmail.isEmpty ? 'Enter your email address' : null;
    final passwordError = password.isEmpty ? 'Enter your password' : null;
    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(
          status: LoginStatus.initial,
          emailError: emailError,
          passwordError: passwordError,
        ),
      );
      return;
    }

    emit(const LoginState(status: LoginStatus.submitting));
    final result = await _authRepo.login({
      'email': trimmedEmail,
      'password': password,
    });

    if (isClosed) return;
    if (!result.success) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: result.message,
        ),
      );
      return;
    }

    await _resolveDeviceAssignment();
  }

  Future<void> _resolveDeviceAssignment() async {
    final deviceId = await _authRepo.getPosDeviceId();
    if (isClosed) return;
    if (deviceId == null) {
      emit(state.copyWith(status: LoginStatus.success));
      return;
    }

    final (merchantId, branchId) = await _authRepo.getPosDevice(deviceId);
    if (isClosed) return;

    if (branchId == null) {
      final branches = await _authRepo.getBranches();
      if (isClosed) return;
      if (branches.isNotEmpty) {
        emit(
          state.copyWith(
            status: LoginStatus.needsBranchSelection,
            deviceId: deviceId,
            branches: branches,
          ),
        );
        return;
      }
    }

    if (merchantId == null) {
      unawaited(_authRepo.claimPosDevice(deviceId));
    }
    emit(state.copyWith(status: LoginStatus.success));
  }

  /// The user edited a field: clear stale errors so they don't linger while
  /// the input is being corrected.
  void fieldChanged() {
    if (state.hasErrors) emit(state.copyWith());
  }
}
