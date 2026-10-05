import 'package:auth_repo/auth_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/setup/cubit/cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_source/net_source.dart';

class _MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late _MockAuthRepo auth;

  setUp(() {
    auth = _MockAuthRepo();
    when(auth.getDeviceId).thenAnswer((_) async => 'abcdef123456');
    when(auth.getTerminalTypes).thenAnswer((_) async => const []);
  });

  test(
    'an empty name and serial number are flagged and cleared on edit',
    () async {
      final cubit = SetupCubit(auth);
      await Future<void>.delayed(Duration.zero);

      await cubit.submit(name: ' ', serialNumber: ' ');
      expect(cubit.state.nameError, 'Enter a name for this device');
      expect(cubit.state.serialNumberError, 'Enter the device serial number');
      verifyNever(() => auth.registerDevice(any()));

      cubit.nameChanged();
      cubit.serialNumberChanged();
      expect(cubit.state.nameError, isNull);
      expect(cubit.state.serialNumberError, isNull);
      await cubit.close();
    },
  );

  test('submits name/serial/fingerprint with no merchant fields', () async {
    when(() => auth.registerDevice(any())).thenAnswer(
      (_) async => OpStatus(message: 'created', success: true),
    );
    when(
      () => auth.setKioskModeEnabled(enabled: true),
    ).thenAnswer((_) async {});
    final cubit = SetupCubit(auth);
    await Future<void>.delayed(Duration.zero);

    await cubit.submit(name: 'Front counter', serialNumber: 'SN-1');
    expect(cubit.state.status, SetupStatus.success);
    final body =
        verify(() => auth.registerDevice(captureAny())).captured.single
            as Map<String, dynamic>;
    expect(body['name'], 'Front counter');
    expect(body['serial_number'], 'SN-1');
    expect(body['finger_print'], 'abcdef123456');
    expect(body.containsKey('merchant_name'), isFalse);
    expect(body.containsKey('merchant_email'), isFalse);
    verify(() => auth.setKioskModeEnabled(enabled: true)).called(1);
    await cubit.close();
  });
}
