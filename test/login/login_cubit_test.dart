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

  test('an empty OTP is flagged on the code field', () async {
    final cubit = LoginCubit(auth);
    await cubit.submitOtp('  ');
    expect(cubit.state.otpError, 'Enter the 6-digit code');
    verifyNever(() => auth.login(any()));
    await cubit.close();
  });
}
