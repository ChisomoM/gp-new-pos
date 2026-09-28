import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/login/cubit/cubit.dart';
import 'package:geepay_pos/login/widgets/login_body.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_source/net_source.dart';

import '../helpers/pump_app.dart';

class _MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late _MockAuthRepo auth;

  setUp(() {
    auth = _MockAuthRepo();
    when(() => auth.login(any())).thenAnswer(
      (_) async => OpStatus(message: 'Invalid credentials', success: false),
    );
  });

  Future<void> pumpLogin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      BlocProvider(create: (_) => LoginCubit(auth), child: const LoginBody()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows an error under each empty field', (tester) async {
    await pumpLogin(tester);
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email address'), findsOne);
    expect(find.text('Enter your password'), findsOne);

    await tester.enterText(find.byType(TextField).first, 'a');
    await tester.pumpAndSettle();
    expect(find.text('Enter your email address'), findsNothing);
  });

  testWidgets('shows a server error as an alert', (tester) async {
    await pumpLogin(tester);
    await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid credentials'), findsOne);
  });
}
