part of 'transaction_history_cubit.dart';

enum TransactionHistoryStatus { initial, loading, success, failure }

enum TransactionHistoryFilter { all, successful, failed, pending }

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
    this.transactions = const [],
    this.errorMessage,
  });

  final TransactionHistoryStatus status;
  final TransactionHistoryFilter filter;
  final List<Transaction> transactions;
  final String? errorMessage;

  bool get isLoading => status == TransactionHistoryStatus.loading;

  TransactionHistoryState copyWith({
    TransactionHistoryStatus? status,
    TransactionHistoryFilter? filter,
    List<Transaction>? transactions,
    String? errorMessage,
  }) {
    return TransactionHistoryState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, filter, transactions, errorMessage];
}
