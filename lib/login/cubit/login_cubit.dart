import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:net_source/net_source.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepo) : super(const LoginState());

  final AuthRepo _authRepo;

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

    emit(
      LoginState(
        status: LoginStatus.submitting,
        email: trimmedEmail,
        password: password,
      ),
    );
    final result = await _authRepo.login({
      'email': trimmedEmail,
      'password': password,
    });

    if (isClosed) return;
    if (result.success && _isMfaRequired(result)) {
      emit(state.copyWith(status: LoginStatus.otpRequired, errorMessage: ''));
      return;
    }
    emit(
      result.success
          ? state.copyWith(status: LoginStatus.success)
          : state.copyWith(
              status: LoginStatus.failure,
              errorMessage: result.message,
            ),
    );
  }

  /// Resubmits email+password with the emailed [otp] code — the second call
  /// of `gp_auth-main`'s two-step OTP-gated login (see
  /// `pos_mobile_app_endpoints.md` §0).
  Future<void> submitOtp(String otp) async {
    final trimmedOtp = otp.trim();
    if (trimmedOtp.isEmpty) {
      emit(state.copyWith(otpError: 'Enter the 6-digit code'));
      return;
    }

    emit(state.copyWith(status: LoginStatus.otpSubmitting, errorMessage: ''));
    final result = await _authRepo.login({
      'email': state.email,
      'password': state.password,
      'otp': trimmedOtp,
    });

    if (isClosed) return;
    emit(
      result.success
          ? state.copyWith(status: LoginStatus.success)
          : state.copyWith(
              status: LoginStatus.otpRequired,
              errorMessage: result.message,
            ),
    );
  }

  /// The user edited a field: clear stale errors so they don't linger while
  /// the input is being corrected.
  void fieldChanged() {
    if (state.hasErrors) emit(state.copyWith());
  }

  /// Drops back from the OTP step to the email/password form.
  void cancelOtp() {
    emit(state.copyWith(status: LoginStatus.initial, errorMessage: ''));
  }

  bool _isMfaRequired(OpStatus result) {
    final data = result.data;
    return data is Map && data['mfaRequired'] == true;
  }
}
