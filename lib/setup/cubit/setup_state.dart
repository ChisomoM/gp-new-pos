part of 'setup_cubit.dart';

enum SetupStatus { initial, submitting, success, failure }

class SetupState extends Equatable {
  const SetupState({
    this.status = SetupStatus.initial,
    this.deviceId,
    this.errorMessage,
  });

  final SetupStatus status;
  final String? deviceId;
  final String? errorMessage;

  bool get isSubmitting => status == SetupStatus.submitting;

  SetupState copyWith({
    SetupStatus? status,
    String? deviceId,
    String? errorMessage,
  }) {
    return SetupState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, deviceId, errorMessage];
}
