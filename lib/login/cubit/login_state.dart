part of 'login_cubit.dart';

enum LoginStatus {
  initial,
  submitting,
  otpRequired,
  otpSubmitting,
  success,
  failure,
}

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.email = '',
    this.password = '',
  });

  final LoginStatus status;
  final String? errorMessage;

  /// Held in memory (never persisted) between the two `/auth/login` calls —
  /// the OTP-gated flow re-sends email+password alongside the code on the
  /// second call, per `pos_mobile_app_endpoints.md` §0.
  final String email;
  final String password;

  bool get isSubmitting => status == LoginStatus.submitting;
  bool get isOtpSubmitting => status == LoginStatus.otpSubmitting;
  bool get isAwaitingOtp =>
      status == LoginStatus.otpRequired || status == LoginStatus.otpSubmitting;

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    String? email,
    String? password,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, email, password];
}
