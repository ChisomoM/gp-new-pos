part of 'login_cubit.dart';

enum LoginStatus {
  initial,
  submitting,
  needsBranchSelection,
  success,
  failure,
}

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.emailError,
    this.passwordError,
    this.deviceId,
    this.branches = const [],
  });

  final LoginStatus status;

  /// Server / request error, shown as an alert above the submit button.
  final String? errorMessage;

  /// Field-level validation errors, shown under the matching field.
  final String? emailError;
  final String? passwordError;

  /// The `gp_pos_tms` device id, set once login succeeds and this device
  /// needs branch resolution (`LoginStatus.needsBranchSelection`) — the
  /// branch picker needs it for `AuthRepo.claimPosDevice`.
  final String? deviceId;

  /// `GET /merchants/branches` result, as `(id, name)` — only populated
  /// when [status] is `needsBranchSelection`.
  final List<(String id, String name)> branches;

  bool get hasErrors =>
      (errorMessage?.isNotEmpty ?? false) ||
      emailError != null ||
      passwordError != null;

  bool get isSubmitting =>
      status == LoginStatus.submitting ||
      status == LoginStatus.needsBranchSelection;

  /// Errors are not carried over: every emission shows only the errors
  /// passed to it.
  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    String? emailError,
    String? passwordError,
    String? deviceId,
    List<(String id, String name)>? branches,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      emailError: emailError,
      passwordError: passwordError,
      deviceId: deviceId ?? this.deviceId,
      branches: branches ?? this.branches,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    emailError,
    passwordError,
    deviceId,
    branches,
  ];
}
