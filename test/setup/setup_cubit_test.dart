import 'package:auth_repo/auth_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/setup/cubit/cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  test('an empty business name is flagged and cleared on edit', () async {
    final auth = _MockAuthRepo();
    when(auth.getDeviceId).thenAnswer((_) async => 'abcdef123456');
    final cubit = SetupCubit(auth);
    await Future<void>.delayed(Duration.zero);

    await cubit.submit(
      businessName: ' ',
      businessEmail: '',
      businessPhone: '',
    );
    expect(cubit.state.nameError, 'Enter your business name');
    verifyNever(() => auth.registerDevice(any()));

    cubit.nameChanged();
    expect(cubit.state.nameError, isNull);
    await cubit.close();
  });
}
