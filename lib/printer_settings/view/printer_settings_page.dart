import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geepay_pos/app/theme/design_system.dart';
import 'package:geepay_pos/utils/bluetooth_printer_helper.dart';
import 'package:geepay_pos/utils/print_helper.dart';
import 'package:geepay_pos/utils/printer_dispatch.dart';
import 'package:geepay_pos/utils/printer_preference.dart';
import 'package:geepay_pos/widgets/widgets.dart';
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
      body: Column(
        children: [
          const AppHeader(title: 'Printer settings'),
          Expanded(
            child: _loading
                // Reading the saved preference takes milliseconds; show the
                // empty page rather than flashing a spinner.
                ? const SizedBox.shrink()
                : ListView(
                    padding: const EdgeInsets.all(AppSpace.gutter),
                    children: [
                      const SectionHeader(title: 'Print mode', overline: true),
                      const SizedBox(height: AppSpace.x2),
                      _PrintModeOption(
                        icon: AppIcons.printer,
                        title: 'Built-in printer',
                        subtitle: "Uses the device's internal thermal printer",
                        selected: _choice == PrinterChoice.builtin,
                        onTap: () => _onChoiceSelected(PrinterChoice.builtin),
                      ),
                      const SizedBox(height: AppSpace.x2),
                      _PrintModeOption(
                        icon: AppIcons.bluetooth,
                        title: 'Bluetooth printer',
                        subtitle: 'Connect a paired external receipt printer',
                        selected: _choice == PrinterChoice.bluetooth,
                        onTap: () => _onChoiceSelected(PrinterChoice.bluetooth),
                      ),
                      AnimatedSize(
                        duration: AppMotion.of(context, AppMotion.base),
                        curve: AppMotion.enter,
                        alignment: Alignment.topCenter,
                        child: _choice == PrinterChoice.bluetooth
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpace.section,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SectionHeader(
                                      title: 'Bluetooth devices',
                                      overline: true,
                                      actionLabel: _loadingDevices
                                          ? 'Scanning'
                                          : 'Scan',
                                      actionLoading: _loadingDevices,
                                      onAction: _loadPairedDevices,
                                    ),
                                    const SizedBox(height: AppSpace.x2),
                                    _DeviceList(
                                      loading: _loadingDevices,
                                      devices: _pairedDevices,
                                      connectedMac: _connectedMac,
                                      onSelect: _onDeviceSelected,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  AppSpace.x3,
                  AppSpace.gutter,
                  AppSpace.x4,
                ),
                child: AppButton(
                  label: 'Run test print',
                  icon: AppIcons.printer,
                  isLoading: _testPrinting,
                  onPressed: _loading || _testPrinting ? null : _runTestPrint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Radio-style choice card for the print mode.
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
    final duration = AppMotion.of(context, AppMotion.fast);
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: AppCard(
        selected: selected,
        onTap: onTap,
        child: Row(
          children: [
            AppIconTile(
              icon: icon,
              color: selected ? AppColors.gpCobalt : AppColors.textTertiary,
              background: selected
                  ? AppColors.surfaceWhite
                  : AppColors.surfaceSubtle,
            ),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyStrong),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.x3),
            AnimatedContainer(
              duration: duration,
              width: AppSpace.x5,
              height: AppSpace.x5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.gpCobalt : AppColors.surfaceWhite,
                border: Border.all(
                  color: selected ? AppColors.gpCobalt : AppColors.borderMedium,
                  width: 1.5,
                ),
              ),
              child: AnimatedScale(
                scale: selected ? 1 : 0,
                duration: duration,
                curve: AppMotion.emphasized,
                child: Center(
                  child: Container(
                    width: AppSpace.x2,
                    height: AppSpace.x2,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceWhite,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
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
    required this.connectedMac,
    required this.onSelect,
  });

  final bool loading;
  final List<BluetoothInfo> devices;
  final String? connectedMac;
  final void Function(BluetoothInfo) onSelect;

  @override
  Widget build(BuildContext context) {
    if (loading && devices.isEmpty) {
      return const SkeletonTransactionList(count: 2);
    }
    if (devices.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            const AppIconTile(
              icon: AppIcons.bluetooth,
              color: AppColors.textTertiary,
              background: AppColors.surfaceSubtle,
            ),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: Text(
                'No paired Bluetooth printers found. Pair a printer in your '
                "device's Bluetooth settings first, then tap Scan.",
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return ListGroup(
      elevation: AppCardElevation.flat,
      children: [
        for (final device in devices)
          _DeviceRow(
            device: device,
            connected: device.macAdress == connectedMac,
            onTap: () => onSelect(device),
          ),
      ],
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.device,
    required this.connected,
    required this.onTap,
  });

  final BluetoothInfo device;
  final bool connected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: AppIconTile(
        icon: AppIcons.printer,
        color: connected ? AppColors.gpCobalt : AppColors.textTertiary,
        background: connected ? AppColors.infoFill : AppColors.surfaceSubtle,
      ),
      title: device.name,
      subtitle: connected ? device.macAdress : 'Paired',
      onTap: connected ? null : onTap,
      trailing: connected
          ? const StatusBadge(
              label: 'Connected',
              tone: BadgeTone.success,
              showDot: true,
            )
          : AppButton.tertiary(label: 'Connect', onPressed: onTap),
    );
  }
}
