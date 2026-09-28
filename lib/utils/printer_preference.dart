import 'package:local_data/local_data.dart';

/// Which printer backend(s) a receipt print action should use.
enum PrinterChoice { builtin, bluetooth, both }

/// When [PrinterChoice.both] is selected, whether the two backends print
/// one after the other or at the same time.
enum PrintBothMode { simultaneous, sequential }

/// Persists (via [SharedPrefs]) the user's chosen default printer backend,
/// the "both" ordering mode, and the selected Bluetooth device's MAC
/// address + name. Read from and written to by the Printer Settings screen
/// and consulted by [PrinterDispatch] on every print action.
class PrinterPreference {
  PrinterPreference._();

  static const _printerTypeKey = 'printerType';
  static const _bothModeKey = 'printBothMode';
  static const _bluetoothAddressKey = 'bluetoothPrinterAddress';
  static const _bluetoothNameKey = 'bluetoothPrinterName';

  static Future<SharedPrefs>? _prefsFuture;

  static Future<SharedPrefs> get _prefs => _prefsFuture ??= SharedPrefs.init();

  static Future<PrinterChoice> getDefault() async {
    final prefs = await _prefs;
    final value = await prefs.getString(_printerTypeKey);
    return PrinterChoice.values.firstWhere(
      (choice) => choice.name == value,
      orElse: () => PrinterChoice.builtin,
    );
  }

  static Future<void> setDefault(PrinterChoice choice) async {
    final prefs = await _prefs;
    await prefs.set(_printerTypeKey, choice.name);
  }

  static Future<PrintBothMode> getBothMode() async {
    final prefs = await _prefs;
    final value = await prefs.getString(_bothModeKey);
    return PrintBothMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => PrintBothMode.sequential,
    );
  }

  static Future<void> setBothMode(PrintBothMode mode) async {
    final prefs = await _prefs;
    await prefs.set(_bothModeKey, mode.name);
  }

  static Future<String?> getBluetoothAddress() async {
    final prefs = await _prefs;
    return prefs.getString(_bluetoothAddressKey);
  }

  static Future<String?> getBluetoothName() async {
    final prefs = await _prefs;
    return prefs.getString(_bluetoothNameKey);
  }

  static Future<void> setBluetoothDevice(String macAddress, String name) async {
    final prefs = await _prefs;
    await prefs.set(_bluetoothAddressKey, macAddress);
    await prefs.set(_bluetoothNameKey, name);
  }
}
