part of 'transaction_history_cubit.dart';

enum TransactionHistoryStatus { initial, loading, success, failure }

enum TransactionHistoryFilter { all, successful, failed, pending }

enum TransactionHistoryDatePreset {
  anyTime,
  today,
  yesterday,
  last7Days,
  custom,
}

extension on TransactionHistoryFilter {
  String? get apiValue => switch (this) {
    TransactionHistoryFilter.all => null,
    TransactionHistoryFilter.successful => 'successful',
    TransactionHistoryFilter.failed => 'failed',
    TransactionHistoryFilter.pending => 'pending',
  };
}

class TransactionHistoryState extends Equatable {
  const TransactionHistoryState({
    this.status = TransactionHistoryStatus.initial,
    this.filter = TransactionHistoryFilter.all,
    this.datePreset = TransactionHistoryDatePreset.anyTime,
    this.dateRange,
    this.transactions = const [],
    this.errorMessage,
  });

  final TransactionHistoryStatus status;
  final TransactionHistoryFilter filter;
  final TransactionHistoryDatePreset datePreset;

  /// Inclusive day range for the active preset; null for any time.
  final DateTimeRange? dateRange;
  final List<Transaction> transactions;
  final String? errorMessage;

  bool get hasActiveFilter =>
      filter != TransactionHistoryFilter.all || dateRange != null;

  bool get isLoading => status == TransactionHistoryStatus.loading;

  TransactionHistoryState copyWith({
    TransactionHistoryStatus? status,
    TransactionHistoryFilter? filter,
    TransactionHistoryDatePreset? datePreset,
    DateTimeRange? Function()? dateRange,
    List<Transaction>? transactions,
    String? errorMessage,
  }) {
    return TransactionHistoryState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      datePreset: datePreset ?? this.datePreset,
      dateRange: dateRange != null ? dateRange() : this.dateRange,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, filter, datePreset, dateRange, transactions, errorMessage];
}
