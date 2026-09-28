import 'package:auth_repo/auth_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/collections/cubit/cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_source/net_source.dart';
import 'package:services_repo/services_repo.dart';

class _MockServicesRepo extends Mock implements ServicesRepo {}

class _MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late _MockServicesRepo services;
  late _MockAuthRepo auth;

  setUp(() {
    services = _MockServicesRepo();
    auth = _MockAuthRepo();
    when(auth.getDeviceId).thenAnswer((_) async => 'device-1');
    when(
      () => services.collect(
        phoneNumber: any(named: 'phoneNumber'),
        amount: any(named: 'amount'),
        transactionRef: any(named: 'transactionRef'),
        posDeviceId: any(named: 'posDeviceId'),
      ),
      // A failed request stops submit() before polling starts.
    ).thenAnswer((_) async => OpStatus(message: 'stop', success: false));
  });

  Future<String?> submittedNumber(String typed) async {
    final cubit = CollectionsCubit(services, auth)
      ..setPhoneNumber(typed)
      ..pickAmount(20);
    await cubit.submit();
    await cubit.close();
    final calls = verify(
      () => services.collect(
        phoneNumber: captureAny(named: 'phoneNumber'),
        amount: any(named: 'amount'),
        transactionRef: any(named: 'transactionRef'),
        posDeviceId: any(named: 'posDeviceId'),
      ),
    ).captured;
    return calls.single as String;
  }

  group('CollectionsCubit.submit phone number', () {
    test('adds the country prefix to a local number', () async {
      expect(await submittedNumber('0973042237'), '260973042237');
    });

    test('sends an international number unchanged', () async {
      expect(await submittedNumber('260973042237'), '260973042237');
    });

    test('trims whitespace', () async {
      expect(await submittedNumber(' 0973042237 '), '260973042237');
    });

    test('rejects an empty number without calling the API', () async {
      final cubit = CollectionsCubit(services, auth)
        ..setPhoneNumber('   ')
        ..pickAmount(20);
      await cubit.submit();
      expect(cubit.state.errorMessage, 'Enter a customer phone number');
      verifyNever(
        () => services.collect(
          phoneNumber: any(named: 'phoneNumber'),
          amount: any(named: 'amount'),
          transactionRef: any(named: 'transactionRef'),
          posDeviceId: any(named: 'posDeviceId'),
        ),
      );
      await cubit.close();
    });
  });
}
