part of 'transaction_details_cubit.dart';

enum TransactionDetailsStatus { loading, success, failure }

class TransactionDetailsState extends Equatable {
  const TransactionDetailsState({
    this.status = TransactionDetailsStatus.loading,
    this.transaction,
    this.errorMessage,
  });

  final TransactionDetailsStatus status;
  final Transaction? transaction;
  final String? errorMessage;

  TransactionDetailsState copyWith({
    TransactionDetailsStatus? status,
    Transaction? transaction,
    String? errorMessage,
  }) {
    return TransactionDetailsState(
      status: status ?? this.status,
      transaction: transaction ?? this.transaction,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transaction, errorMessage];
}
