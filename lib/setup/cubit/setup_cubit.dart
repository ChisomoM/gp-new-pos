import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geepay_pos/utils/kiosk_helper.dart';

part 'setup_state.dart';

class SetupCubit extends Cubit<SetupState> {
  SetupCubit(this._authRepo) : super(const SetupState()) {
    _loadDeviceId();
    _loadTerminalTypes();
  }

  final AuthRepo _authRepo;

  Future<void> _loadDeviceId() async {
    final deviceId = await _authRepo.getDeviceId();
    if (isClosed) return;
    emit(state.copyWith(deviceId: deviceId));
  }

  Future<void> _loadTerminalTypes() async {
    final types = await _authRepo.getTerminalTypes();
    if (isClosed || types.isEmpty) return;
    emit(state.copyWith(terminalTypes: types));
  }

  /// The device/terminal name was edited: clear its validation error.
  void nameChanged() {
    if (state.nameError != null) emit(state.copyWith());
  }

  /// The serial number was edited: clear its validation error.
  void serialNumberChanged() {
    if (state.serialNumberError != null) emit(state.copyWith());
  }

  void selectTerminalType(String id, String name) {
    emit(
      state.copyWith(
        selectedTerminalTypeId: id,
        selectedTerminalTypeName: name,
      ),
    );
  }

  /// Registers this device with `gp_pos_tms`, per
  /// `pos_mobile_app_endpoints.md` §1's simplified Setup flow: only name,
  /// serial number, an optional terminal type and an optional phone number
  /// are collected here — no merchant fields, so the device is left
  /// unassigned and claimed to a merchant during login instead (see
  /// `AuthRepo.syncDeviceAssignment`). `finger_print` is collected
  /// automatically (this build has no hardware fingerprint capture wired
  /// in, so the app-generated device UUID stands in for it, same as
  /// before).
  Future<void> submit({
    required String name,
    required String serialNumber,
    String? phoneNumber,
  }) async {
    final trimmedName = name.trim();
    final trimmedSerial = serialNumber.trim();
    final nameError = trimmedName.isEmpty
        ? 'Enter a name for this device'
        : null;
    final serialError = trimmedSerial.isEmpty
        ? 'Enter the device serial number'
        : null;
    if (nameError != null || serialError != null) {
      emit(
        state.copyWith(nameError: nameError, serialNumberError: serialError),
      );
      return;
    }

    final deviceId = state.deviceId;
    if (deviceId == null) return;

    emit(state.copyWith(status: SetupStatus.submitting));
    final result = await _authRepo.registerDevice({
      'name': trimmedName,
      'serial_number': trimmedSerial,
      'finger_print': deviceId,
      if (state.selectedTerminalTypeId != null)
        'terminal_type_id': state.selectedTerminalTypeId,
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
        'phone_number_1': phoneNumber.trim(),
    });
    if (isClosed) return;
    if (result.success) {
      await _authRepo.setKioskModeEnabled(enabled: true);
      await KioskHelper.enterKiosk();
      if (isClosed) return;
    }
    emit(
      result.success
          ? state.copyWith(status: SetupStatus.success)
          : state.copyWith(
              status: SetupStatus.failure,
              errorMessage: result.message,
            ),
    );
  }
}
