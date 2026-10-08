/// The outcome of the most recent kiosk-lock activation on this device, as
/// recorded by `AuthCore.setKioskStatus` right after `KioskHelper.enterKiosk`
/// reports back which native calls succeeded.
class KioskStatus {
  const KioskStatus({
    required this.vendor,
    required this.summary,
    required this.activatedAt,
  });

  /// `"topwise"`, `"trendit"` or `"baseline"` (no vendor hardware detected).
  final String vendor;

  /// A short pass/fail readout, e.g. `"6/6 checks passed"`.
  final String summary;

  /// When this activation happened, or `null` if the stored timestamp
  /// couldn't be parsed.
  final DateTime? activatedAt;
}
