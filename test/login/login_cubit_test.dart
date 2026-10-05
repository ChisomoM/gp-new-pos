import 'package:auth_repo/auth_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/login/cubit/cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_source/net_source.dart';

class _MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late _MockAuthRepo auth;

  setUp(() {
    auth = _MockAuthRepo();
    when(() => auth.login(any())).thenAnswer(
      (_) async => OpStatus(message: 'Invalid credentials', success: false),
    );
  });

  test('flags each empty field without calling the API', () async {
    final cubit = LoginCubit(auth);
    await cubit.submit(email: '  ', password: '');
    expect(cubit.state.emailError, 'Enter your email address');
    expect(cubit.state.passwordError, 'Enter your password');
    verifyNever(() => auth.login(any()));
    await cubit.close();
  });

  test('flags only the missing field', () async {
    final cubit = LoginCubit(auth);
    await cubit.submit(email: 'a@b.com', password: '');
    expect(cubit.state.emailError, isNull);
    expect(cubit.state.passwordError, 'Enter your password');
    await cubit.close();
  });

  test('editing a field clears the errors', () async {
    final cubit = LoginCubit(auth);
    await cubit.submit(email: '', password: '');
    cubit.fieldChanged();
    expect(cubit.state.hasErrors, isFalse);
    await cubit.close();
  });

  test('a server failure is reported as the form error', () async {
    final cubit = LoginCubit(auth);
    await cubit.submit(email: 'a@b.com', password: 'secret');
    expect(cubit.state.status, LoginStatus.failure);
    expect(cubit.state.errorMessage, 'Invalid credentials');
    expect(cubit.state.emailError, isNull);
    await cubit.close();
  });

  test(
    'a successful login with no registered device goes straight to success',
    () async {
      when(() => auth.login(any())).thenAnswer(
        (_) async => OpStatus(message: 'Logged in', success: true),
      );
      when(auth.getPosDeviceId).thenAnswer((_) async => null);

      final cubit = LoginCubit(auth);
      await cubit.submit(email: 'a@b.com', password: 'secret');
      expect(cubit.state.status, LoginStatus.success);
      verifyNever(() => auth.getPosDevice(any()));
      await cubit.close();
    },
  );

  test(
    'an already-assigned device with a branch goes straight to success',
    () async {
      when(() => auth.login(any())).thenAnswer(
        (_) async => OpStatus(message: 'Logged in', success: true),
      );
      when(auth.getPosDeviceId).thenAnswer((_) async => 'device-1');
      when(
        () => auth.getPosDevice('device-1'),
      ).thenAnswer((_) async => ('merchant-1', 'branch-1'));

      final cubit = LoginCubit(auth);
      await cubit.submit(email: 'a@b.com', password: 'secret');
      expect(cubit.state.status, LoginStatus.success);
      verifyNever(() => auth.getBranches());
      verifyNever(() => auth.claimPosDevice(any()));
      await cubit.close();
    },
  );

  test(
    'an unbranched device shows the picker when branches exist',
    () async {
      when(() => auth.login(any())).thenAnswer(
        (_) async => OpStatus(message: 'Logged in', success: true),
      );
      when(auth.getPosDeviceId).thenAnswer((_) async => 'device-1');
      when(
        () => auth.getPosDevice('device-1'),
      ).thenAnswer((_) async => (null, null));
      when(
        auth.getBranches,
      ).thenAnswer((_) async => [('b1', 'Cairo Road Branch')]);

      final cubit = LoginCubit(auth);
      await cubit.submit(email: 'a@b.com', password: 'secret');
      expect(cubit.state.status, LoginStatus.needsBranchSelection);
      expect(cubit.state.deviceId, 'device-1');
      expect(cubit.state.branches, [('b1', 'Cairo Road Branch')]);
      verifyNever(() => auth.claimPosDevice(any()));
      await cubit.close();
    },
  );

  test(
    'an unassigned device with no branches to pick claims and succeeds',
    () async {
      when(() => auth.login(any())).thenAnswer(
        (_) async => OpStatus(message: 'Logged in', success: true),
      );
      when(auth.getPosDeviceId).thenAnswer((_) async => 'device-1');
      when(
        () => auth.getPosDevice('device-1'),
      ).thenAnswer((_) async => (null, null));
      when(auth.getBranches).thenAnswer((_) async => const []);
      when(
        () => auth.claimPosDevice('device-1'),
      ).thenAnswer((_) async => OpStatus(message: 'ok', success: true));

      final cubit = LoginCubit(auth);
      await cubit.submit(email: 'a@b.com', password: 'secret');
      expect(cubit.state.status, LoginStatus.success);
      await untilCalled(() => auth.claimPosDevice('device-1'));
      verify(() => auth.claimPosDevice('device-1')).called(1);
      await cubit.close();
    },
  );
}
