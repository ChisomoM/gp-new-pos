import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geepay_pos/app/theme/theme.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside a themed [MaterialApp] and [Scaffold].
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        theme: const AppTheme().themeData,
        home: Scaffold(body: widget),
      ),
    );
  }
}
