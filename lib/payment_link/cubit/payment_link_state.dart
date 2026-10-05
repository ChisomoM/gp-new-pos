part of 'payment_link_cubit.dart';

enum PaymentLinkStep { form, active, done }

/// Sentinel so [PaymentLinkState.copyWith] can tell "clear this field to
/// null" (the amount field being edited down to empty) apart from "leave it
/// as-is" (every other field update).
const _unset = Object();

class PaymentLinkState extends Equatable {
  const PaymentLinkState({
    this.step = PaymentLinkStep.form,
    this.amount,
    this.errorMessage,
    this.isSubmitting = false,
    this.checkoutUrl,
    this.token,
    this.status,
    this.pollAttempts = 0,
  });

  final PaymentLinkStep step;
  final double? amount;
  final String? errorMessage;
  final bool isSubmitting;

  /// The hosted-checkout page URL — the app renders its QR locally from
  /// this string, the API never returns a QR image.
  final String? checkoutUrl;

  /// The hosted-checkout session token, used to poll §5b and as the
  /// customer-facing credential embedded in [checkoutUrl].
  final String? token;

  /// Raw status string from §5b: `pending`, `processing`, `paid`, `failed`,
  /// `cancelled` or `expired`.
  final String? status;
  final int pollAttempts;

  bool get isPaid => status == 'paid';

  PaymentLinkState copyWith({
    PaymentLinkStep? step,
    Object? amount = _unset,
    String? errorMessage,
    bool? isSubmitting,
    String? checkoutUrl,
    String? token,
    String? status,
    int? pollAttempts,
  }) {
    return PaymentLinkState(
      step: step ?? this.step,
      amount: identical(amount, _unset) ? this.amount : amount as double?,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      token: token ?? this.token,
      status: status ?? this.status,
      pollAttempts: pollAttempts ?? this.pollAttempts,
    );
  }

  @override
  List<Object?> get props => [
    step,
    amount,
    errorMessage,
    isSubmitting,
    checkoutUrl,
    token,
    status,
    pollAttempts,
  ];
}
