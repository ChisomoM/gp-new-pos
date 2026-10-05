part of 'setup_cubit.dart';

enum SetupStatus { initial, submitting, success, failure }

class SetupState extends Equatable {
  const SetupState({
    this.status = SetupStatus.initial,
    this.deviceId,
    this.errorMessage,
    this.nameError,
    this.serialNumberError,
    this.terminalTypes = const [],
    this.selectedTerminalTypeId,
    this.selectedTerminalTypeName,
  });

  final SetupStatus status;
  final String? deviceId;

  /// Registration (server) error, shown as an alert.
  final String? errorMessage;

  /// Field-level validation errors, shown under the matching field. Not
  /// carried over by [copyWith].
  final String? nameError;
  final String? serialNumberError;

  /// `GET /v1/terminal-types` catalog, as `(id, name)` — empty if the
  /// endpoint returned nothing usable, in which case the field is just
  /// left blank/optional (the backend doesn't require it either way).
  final List<(String id, String name)> terminalTypes;
  final String? selectedTerminalTypeId;
  final String? selectedTerminalTypeName;

  bool get isSubmitting => status == SetupStatus.submitting;

  SetupState copyWith({
    SetupStatus? status,
    String? deviceId,
    String? errorMessage,
    String? nameError,
    String? serialNumberError,
    List<(String id, String name)>? terminalTypes,
    String? selectedTerminalTypeId,
    String? selectedTerminalTypeName,
  }) {
    return SetupState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      errorMessage: errorMessage ?? this.errorMessage,
      nameError: nameError,
      serialNumberError: serialNumberError,
      terminalTypes: terminalTypes ?? this.terminalTypes,
      selectedTerminalTypeId:
          selectedTerminalTypeId ?? this.selectedTerminalTypeId,
      selectedTerminalTypeName:
          selectedTerminalTypeName ?? this.selectedTerminalTypeName,
    );
  }

  @override
  List<Object?> get props => [
    status,
    deviceId,
    errorMessage,
    nameError,
    serialNumberError,
    terminalTypes,
    selectedTerminalTypeId,
    selectedTerminalTypeName,
  ];
}
