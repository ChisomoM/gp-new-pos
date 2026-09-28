/// A single transaction row, shared by Dashboard, Transaction History,
/// Transaction Details, and the Collections result screen.
///
/// ASSUMPTION: `pos_mobile_app_endpoints.md` documents the response envelope
/// for `GET /transactions/list` and `GET /transactions/get/:id`
/// (`data.data.transaction`, `data.status_counts`, ...) but explicitly
/// redacts the actual field names of a transaction row
/// (`"...transaction row fields..."`). [Transaction.fromJson] therefore
/// checks a short list of plausible key names per field (e.g.
/// `phone_number`/`msisdn`/`customer_phone`, `amount` as either a number or
/// a numeric string) instead of assuming one exact shape, so a row still
/// renders even if the live API's naming differs from the doc's best guess
/// — narrow this back down once the real shape is confirmed.
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
      phoneNumber: ((json['phone_number'] ??
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
      provider: (json['provider'] ??
              json['channel'] ??
              json['payment_channel'] ??
              json['network'])
          ?.toString(),
      processedAt: DateTime.tryParse(
        ((json['processed_at'] ??
                json['completed_at'] ??
                json['created_at'] ??
                json['date_created'] ??
                '') as Object)
            .toString(),
      ),
    );
  }

  /// Parses the single-object envelope of `GET /transactions/get/:id`
  /// (`data.data` as an object, not `data.data.transaction` as an array,
  /// per `pos_mobile_app_endpoints.md` §4b).
  factory Transaction.fromDetailResponse(dynamic data) {
    final map = data as Map<String, dynamic>;
    final inner = map['data'] as Map<String, dynamic>? ?? const {};
    return Transaction.fromJson(inner);
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

  /// Display label for the provider (e.g. `airtel` -> `Airtel Money`).
  String get channelLabel {
    switch (provider?.toLowerCase()) {
      case 'airtel':
        return 'Airtel Money';
      case 'mtn':
        return 'MTN Money';
      case 'zamtel':
        return 'Zamtel Money';
      default:
        return 'Mobile Money';
    }
  }

  /// Avatar initial, colored per channel in [TransactionRow].
  String get avatarLetter {
    switch (provider?.toLowerCase()) {
      case 'mtn':
        return 'M';
      case 'zamtel':
        return 'Z';
      default:
        return 'A';
    }
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
class TransactionList {
  const TransactionList({
    required this.transactions,
    required this.statusCounts,
    required this.totalSuccessfulAmount,
    required this.currency,
  });

  factory TransactionList.fromResponseData(dynamic data) {
    final map = data as Map<String, dynamic>;
    final inner = map['data'] as Map<String, dynamic>? ?? const {};
    final rows = (inner['transaction'] as List<dynamic>? ?? const [])
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
