import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/app_colors.dart';
import 'package:geepay_pos/utils/bluetooth_printer_helper.dart';
import 'package:geepay_pos/utils/print_helper.dart';
import 'package:geepay_pos/utils/printer_dispatch.dart';
import 'package:geepay_pos/utils/printer_preference.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

/// Lets the user pick a default receipt-printer backend (the device's
/// built-in thermal printer, or a paired external Bluetooth printer) and,
/// for the Bluetooth backend, which paired device to use.
class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  /// The static route for PrinterSettingsPage.
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const PrinterSettingsPage(),
    );
  }

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  PrinterChoice _choice = PrinterChoice.builtin;
  String? _selectedMac;
  List<BluetoothInfo> _pairedDevices = [];
  bool _loading = true;
  bool _loadingDevices = false;
  bool _testPrinting = false;
  String? _connectedMac;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final choice = await PrinterPreference.getDefault();
    final mac = await PrinterPreference.getBluetoothAddress();
    if (!mounted) return;
    setState(() {
      _choice = choice;
      _selectedMac = mac;
      _loading = false;
    });
    if (choice == PrinterChoice.bluetooth) {
      await _loadPairedDevices();
    }
  }

  Future<void> _loadPairedDevices() async {
    setState(() => _loadingDevices = true);
    final devices = await BluetoothPrinterHelper.getPairedDevices();
    final connected = await BluetoothPrinterHelper.isConnected();
    if (!mounted) return;
    setState(() {
      _pairedDevices = devices;
      _connectedMac = connected ? _selectedMac : null;
      _loadingDevices = false;
    });
  }

  Future<void> _onChoiceSelected(PrinterChoice choice) async {
    setState(() => _choice = choice);
    await PrinterPreference.setDefault(choice);
    if (choice == PrinterChoice.bluetooth && _pairedDevices.isEmpty) {
      await _loadPairedDevices();
    }
  }

  Future<void> _onDeviceSelected(BluetoothInfo device) async {
    final connected = await BluetoothPrinterHelper.connect(device.macAdress);
    if (!mounted) return;
    setState(() {
      _selectedMac = device.macAdress;
      _connectedMac = connected ? device.macAdress : null;
    });
    await PrinterPreference.setBluetoothDevice(device.macAdress, device.name);
  }

  Future<void> _runTestPrint() async {
    setState(() => _testPrinting = true);
    final now = DateTime.now().toIso8601String();
    await PrinterDispatch.run(
      override: _choice,
      printBuiltin: () => PrintHelper.printReceipt(const {
        'businessName': 'Geepay',
        'branchName': 'Test Branch',
        'username': 'Test Cashier',
        'amount': '10.00',
        'phone': '0000000000',
        'paymentChannel': 'Test',
        'transactionId': 'TEST-0001',
        'date': '',
        'status': 'successful',
        'isReprint': 'false',
        'reprintCount': '1',
      }),
      printBluetooth: () => BluetoothPrinterHelper.printReceipt({
        'businessName': 'Geepay',
        'branchName': 'Test Branch',
        'username': 'Test Cashier',
        'amount': '10.00',
        'phone': '0000000000',
        'paymentChannel': 'Test',
        'transactionId': 'TEST-0001',
        'date': now,
        'status': 'successful',
        'isReprint': 'false',
        'reprintCount': '1',
      }),
    );
    if (!mounted) return;
    setState(() => _testPrinting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const _Header(title: 'Printer settings'),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const _SectionLabel('Print mode'),
                        const SizedBox(height: 8),
                        _PrintModeOption(
                          icon: Icons.print_outlined,
                          title: 'Built-in printer',
                          subtitle:
                              "Uses the device's internal thermal printer",
                          selected: _choice == PrinterChoice.builtin,
                          onTap: () => _onChoiceSelected(PrinterChoice.builtin),
                        ),
                        const SizedBox(height: 8),
                        _PrintModeOption(
                          icon: Icons.bluetooth,
                          title: 'Bluetooth printer',
                          subtitle: 'Connect a paired external receipt printer',
                          selected: _choice == PrinterChoice.bluetooth,
                          onTap: () =>
                              _onChoiceSelected(PrinterChoice.bluetooth),
                        ),
                        if (_choice == PrinterChoice.bluetooth) ...[
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const _SectionLabel('Bluetooth devices'),
                              TextButton(
                                onPressed: _loadingDevices
                                    ? null
                                    : _loadPairedDevices,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  _loadingDevices ? 'Scanning...' : 'Scan',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gpCobalt,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _DeviceList(
                            loading: _loadingDevices,
                            devices: _pairedDevices,
                            selectedMac: _selectedMac,
                            connectedMac: _connectedMac,
                            onSelect: _onDeviceSelected,
                          ),
                        ],
                      ],
                    ),
                  ),
                  _TestPrintButton(
                    loading: _testPrinting,
                    onPressed: _testPrinting ? null : _runTestPrint,
                  ),
                ],
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _PrintModeOption extends StatelessWidget {
  const _PrintModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.infoFill : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.gpCobalt : AppColors.borderLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected ? AppColors.gpCobalt : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.gpNavy
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: selected
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.gpCobalt : Colors.transparent,
                border: selected
                    ? null
                    : Border.all(color: AppColors.borderMedium, width: 1.5),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({
    required this.loading,
    required this.devices,
    required this.selectedMac,
    required this.connectedMac,
    required this.onSelect,
  });

  final bool loading;
  final List<BluetoothInfo> devices;
  final String? selectedMac;
  final String? connectedMac;
  final void Function(BluetoothInfo) onSelect;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (devices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Text(
          'No paired Bluetooth devices found. Pair a printer in your '
          'device Bluetooth settings first, then tap Scan.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          for (var i = 0; i < devices.length; i++)
            _DeviceRow(
              device: devices[i],
              isLast: i == devices.length - 1,
              connected: devices[i].macAdress == connectedMac,
              onTap: () => onSelect(devices[i]),
            ),
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.device,
    required this.isLast,
    required this.connected,
    required this.onTap,
  });

  final BluetoothInfo device;
  final bool isLast;
  final bool connected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: connected ? AppColors.infoFill : const Color(0xFFF7F8FA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.print_outlined,
              size: 16,
              color: connected ? AppColors.gpCobalt : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  connected ? 'Connected · ${device.macAdress}' : 'Paired',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (connected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successFill,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'CONNECTED',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.successText,
                  letterSpacing: 0.3,
                ),
              ),
            )
          else
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Connect',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gpCobalt,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TestPrintButton extends StatelessWidget {
  const _TestPrintButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [
                AppColors.gpCobalt,
                Color(0xFF2B6FC2),
                AppColors.gpSky,
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Run test print',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
