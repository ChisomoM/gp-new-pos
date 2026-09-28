import 'package:geepay_pos/utils/printer_preference.dart';

/// Decides which printer backend(s) a print action should use, based on the
/// persisted default (or a one-off [override]). Each closure is exactly what a
/// call site already does for that backend today -- this only decides which
/// one(s) to invoke and, for [PrinterChoice.both], in what order/concurrency.
class PrinterDispatch {
  static Future<void> run({
    required Future<void> Function() printBuiltin,
    required Future<void> Function() printBluetooth,
    PrinterChoice? override,
  }) async {
    final choice = override ?? await PrinterPreference.getDefault();
    switch (choice) {
      case PrinterChoice.builtin:
        await printBuiltin();
      case PrinterChoice.bluetooth:
        await printBluetooth();
      case PrinterChoice.both:
        if (await PrinterPreference.getBothMode() ==
            PrintBothMode.simultaneous) {
          await Future.wait([printBuiltin(), printBluetooth()]);
        } else {
          await printBuiltin();
          await printBluetooth();
        }
    }
  }
}
