/// A single transaction row, shared by Dashboard, Transaction History,
/// Transaction Details, and the Collections result screen.
///
/// Field names confirmed against a live `GET /transactions/list` response
/// (logged at `net_source.dart`'s `Response @ transactions/list`): the
/// customer's number is `customer` (not `phone_number`), the channel is a
/// ready-to-display `payment_channel_name` (e.g. `"Airtel (Collection)"`,
/// not a bare `"airtel"` code), and the completion time is `resolved_at`
/// (`created_at` is when the request was made, not when it settled).
/// [Transaction.fromJson] tries the confirmed key first for each field,
/// then falls back to the doc's originally-guessed key names, since
/// `pos_mobile_app_endpoints.md` redacts the full row shape and other
/// endpoints (or future backend changes) may still use them.
class Transaction {
  const Transaction({
    required this.id,
    required this.reference,
    required this.phoneNumber,
    required this.amount,
    required this.currency,
    required this.status,
    required this.provider,
    required this.processedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    final amountValue =
        json['amount'] ?? json['transaction_amount'] ?? json['value'];
    return Transaction(
      id: (json['id'] ?? json['transaction_id'])?.toString(),
      reference: ((json['transaction_reference'] ??
                  json['external_reference'] ??
                  json['reference'] ??
                  '') as Object)
              .toString(),
      phoneNumber: ((json['customer'] ??
                  json['phone_number'] ??
                  json['msisdn'] ??
                  json['customer_phone'] ??
                  json['phone'] ??
                  '') as Object)
              .toString(),
      amount: parseAmount(amountValue),
      currency: ((json['currency'] ?? 'ZMW') as Object).toString(),
      status: ((json['status'] ?? json['transaction_status'] ?? 'pending')
              as Object)
          .toString(),
      provider: (json['payment_channel_name'] ??
              json['provider'] ??
              json['channel'] ??
              json['payment_channel'] ??
              json['network'])
          ?.toString(),
      processedAt: DateTime.tryParse(
        ((json['resolved_at'] ??
                json['processed_at'] ??
                json['completed_at'] ??
                json['created_at'] ??
                json['date_created'] ??
                '') as Object)
            .toString(),
      ),
    );
  }

  /// Parses the response of `GET /transactions/get/:id`.
  ///
  /// `OpStatus.data` (passed in as `data`) is already `NetResponse.data` —
  /// i.e. the raw response body's top-level `data` object, which here *is*
  /// the transaction row directly. There's no second `data` layer to
  /// unwrap (confirmed against a live response logged at
  /// `net_source.dart`'s `Response @ transactions/get/:id`).
  factory Transaction.fromDetailResponse(dynamic data) {
    return Transaction.fromJson(data as Map<String, dynamic>);
  }

  final String? id;
  final String reference;
  final String phoneNumber;
  final double amount;
  final String currency;
  final String status;
  final String? provider;
  final DateTime? processedAt;

  /// The best identifier to use for `GET /transactions/get/:id` — prefer
  /// the row's own `id`, fall back to the reference if that's all we have.
  String get lookupId => id ?? reference;

  bool get isSuccessful => status.toLowerCase() == 'successful';
  bool get isFailed =>
      status.toLowerCase() == 'failed' || status.toLowerCase() == 'failure';

  /// Display label for the provider. `provider` is already a
  /// ready-to-display name from the live API (e.g. `"Airtel (Collection)"`
  /// for `payment_channel_name`), so this matches by substring rather than
  /// an exact code like `"airtel"`.
  String get channelLabel {
    final p = provider?.toLowerCase() ?? '';
    if (p.contains('airtel')) return 'Airtel Money';
    if (p.contains('mtn')) return 'MTN Money';
    if (p.contains('zamtel')) return 'Zamtel Money';
    return 'Mobile Money';
  }

  /// Avatar initial, colored per channel in [TransactionRow].
  String get avatarLetter {
    final p = provider?.toLowerCase() ?? '';
    if (p.contains('mtn')) return 'M';
    if (p.contains('zamtel')) return 'Z';
    return 'A';
  }
}

/// `data.status_counts` from `GET /transactions/list`.
class TransactionStatusCounts {
  const TransactionStatusCounts({
    this.successful = 0,
    this.failed = 0,
    this.pending = 0,
  });

  factory TransactionStatusCounts.fromJson(Map<String, dynamic> json) {
    return TransactionStatusCounts(
      successful: (json['successful'] as num?)?.toInt() ?? 0,
      failed: (json['failed'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
    );
  }

  final int successful;
  final int failed;
  final int pending;
}

/// Parsed result of a `GET /transactions/list` fetch.
///
/// `OpStatus.data` (passed in as `fromResponseData`'s `data`) is already
/// `NetResponse.data` — i.e. the raw response body's top-level `data`
/// object, which holds `transaction`, `status_counts`, etc. directly.
/// There's no second `data` layer to unwrap here (that nesting only
/// applies to `Transaction.fromDetailResponse`'s single-object envelope).
class TransactionList {
  const TransactionList({
    required this.transactions,
    required this.statusCounts,
    required this.totalSuccessfulAmount,
    required this.currency,
  });

  factory TransactionList.fromResponseData(dynamic data) {
    final map = data as Map<String, dynamic>;
    final rows = (map['transaction'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Transaction.fromJson)
        .toList();
    final counts = TransactionStatusCounts.fromJson(
      map['status_counts'] as Map<String, dynamic>? ?? const {},
    );
    final successfulAmount = rows
        .where((t) => t.isSuccessful)
        .fold<double>(0, (sum, t) => sum + t.amount);
    return TransactionList(
      transactions: rows,
      statusCounts: counts,
      totalSuccessfulAmount: successfulAmount,
      currency: rows.isEmpty ? 'ZMW' : rows.first.currency,
    );
  }

  final List<Transaction> transactions;
  final TransactionStatusCounts statusCounts;
  final double totalSuccessfulAmount;
  final String currency;
}
