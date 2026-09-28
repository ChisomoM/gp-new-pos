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
    this.emailError,
    this.passwordError,
    this.otpError,
    this.email = '',
    this.password = '',
  });

  final LoginStatus status;

  /// Server / request error, shown as an alert above the submit button.
  final String? errorMessage;

  /// Field-level validation errors, shown under the matching field.
  final String? emailError;
  final String? passwordError;
  final String? otpError;

  bool get hasErrors =>
      (errorMessage?.isNotEmpty ?? false) ||
      emailError != null ||
      passwordError != null ||
      otpError != null;

  /// Held in memory (never persisted) between the two `/auth/login` calls —
  /// the OTP-gated flow re-sends email+password alongside the code on the
  /// second call, per `pos_mobile_app_endpoints.md` §0.
  final String email;
  final String password;

  bool get isSubmitting => status == LoginStatus.submitting;
  bool get isOtpSubmitting => status == LoginStatus.otpSubmitting;
  bool get isAwaitingOtp =>
      status == LoginStatus.otpRequired || status == LoginStatus.otpSubmitting;

  /// Errors are not carried over: every emission shows only the errors
  /// passed to it.
  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    String? emailError,
    String? passwordError,
    String? otpError,
    String? email,
    String? password,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      emailError: emailError,
      passwordError: passwordError,
      otpError: otpError,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    emailError,
    passwordError,
    otpError,
    email,
    password,
  ];
}
