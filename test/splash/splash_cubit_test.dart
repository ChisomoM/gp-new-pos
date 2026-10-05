import 'package:auth_repo/auth_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/splash/cubit/cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late _MockAuthRepo auth;

  setUp(() {
    auth = _MockAuthRepo();
    when(auth.isKioskModeEnabled).thenAnswer((_) async => false);
  });

  test('waits for the minimum display time before routing', () async {
    when(
      () => auth.status,
    ).thenAnswer((_) => Stream.value(AuthStatus.authenticated));
    when(auth.isDeviceRegistered).thenAnswer((_) async => true);
    final cubit = SplashCubit(
      auth,
      minimumDisplay: const Duration(milliseconds: 200),
    );

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(cubit.state.destination, SplashDestination.none);

    await Future<void>.delayed(const Duration(milliseconds: 250));
    expect(cubit.state.destination, SplashDestination.main);
    await cubit.close();
  });

  test('routes to login when not authenticated', () async {
    when(
      () => auth.status,
    ).thenAnswer((_) => Stream.value(AuthStatus.unauthenticated));
    when(auth.isDeviceRegistered).thenAnswer((_) async => true);
    final cubit = SplashCubit(auth, minimumDisplay: Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state.destination, SplashDestination.login);
    await cubit.close();
  });

  test('routes to setup when the device is not registered', () async {
    when(
      () => auth.status,
    ).thenAnswer((_) => Stream.value(AuthStatus.authenticated));
    when(auth.isDeviceRegistered).thenAnswer((_) async => false);
    final cubit = SplashCubit(auth, minimumDisplay: Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state.destination, SplashDestination.setup);
    await cubit.close();
  });

  test(
    'still routes normally when kiosk mode is enabled for this device',
    () async {
      when(
        () => auth.status,
      ).thenAnswer((_) => Stream.value(AuthStatus.authenticated));
      when(auth.isDeviceRegistered).thenAnswer((_) async => true);
      when(auth.isKioskModeEnabled).thenAnswer((_) async => true);
      final cubit = SplashCubit(auth, minimumDisplay: Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(cubit.state.destination, SplashDestination.main);
      await cubit.close();
    },
  );
}
