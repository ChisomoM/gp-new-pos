import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'setup_state.dart';

class SetupCubit extends Cubit<SetupState> {
  SetupCubit(this._authRepo) : super(const SetupState()) {
    _loadDeviceId();
  }

  final AuthRepo _authRepo;

  Future<void> _loadDeviceId() async {
    final deviceId = await _authRepo.getDeviceId();
    if (isClosed) return;
    emit(state.copyWith(deviceId: deviceId));
  }

  /// Registers this device with `gp_pos_tms`.
  ///
  /// `serial_number`/`finger_print` fall back to the app-generated device
  /// UUID (see [AuthRepo.getDeviceId]) since this build has no hardware
  /// serial/fingerprint capture wired in yet. `name` (the required
  /// device/terminal label) and `merchant_name` both take [businessName] —
  /// the mockup only collects one business-name field, so it doubles for
  /// both until a dedicated device-name input exists.
  Future<void> submit({
    required String businessName,
    required String businessEmail,
    required String businessPhone,
  }) async {
    final name = businessName.trim();
    if (name.isEmpty) {
      emit(state.copyWith(errorMessage: 'Business name is required'));
      return;
    }

    final deviceId = state.deviceId;
    if (deviceId == null) return;

    emit(SetupState(status: SetupStatus.submitting, deviceId: deviceId));
    final result = await _authRepo.registerDevice({
      'serial_number': deviceId,
      'name': name,
      'finger_print': deviceId,
      'merchant_name': name,
      'merchant_email': businessEmail.trim(),
      'phone_number_1': businessPhone.trim(),
    });
    if (isClosed) return;
    emit(
      result.success
          ? SetupState(status: SetupStatus.success, deviceId: deviceId)
          : SetupState(
              status: SetupStatus.failure,
              deviceId: deviceId,
              errorMessage: result.message,
            ),
    );
  }
}
