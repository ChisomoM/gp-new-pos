part of 'setup_cubit.dart';

enum SetupStatus { initial, submitting, success, failure }

class SetupState extends Equatable {
  const SetupState({
    this.status = SetupStatus.initial,
    this.deviceId,
    this.errorMessage,
    this.nameError,
  });

  final SetupStatus status;
  final String? deviceId;

  /// Registration (server) error, shown as an alert.
  final String? errorMessage;

  /// Business name validation error, shown under the field. Not carried
  /// over by [copyWith].
  final String? nameError;

  bool get isSubmitting => status == SetupStatus.submitting;

  SetupState copyWith({
    SetupStatus? status,
    String? deviceId,
    String? errorMessage,
    String? nameError,
  }) {
    return SetupState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      errorMessage: errorMessage ?? this.errorMessage,
      nameError: nameError,
    );
  }

  @override
  List<Object?> get props => [status, deviceId, errorMessage, nameError];
}
