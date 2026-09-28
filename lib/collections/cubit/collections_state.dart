part of 'collections_cubit.dart';

enum CollectionsStep { form, polling, done }

/// Sentinel so [CollectionsState.copyWith] can tell "clear this field to
/// null" (the amount field being edited down to empty) apart from "leave it
/// as-is" (every other field update, e.g. typing the phone number).
const _unset = Object();

class CollectionsState extends Equatable {
  const CollectionsState({
    this.step = CollectionsStep.form,
    this.phoneNumber = '',
    this.amount,
    this.transactionRef,
    this.errorMessage,
    this.isSuccessful,
    this.resultTransaction,
    this.pollAttempts = 0,
  });

  final CollectionsStep step;
  final String phoneNumber;
  final double? amount;
  final String? transactionRef;
  final String? errorMessage;
  final bool? isSuccessful;
  final Transaction? resultTransaction;
  final int pollAttempts;

  CollectionsState copyWith({
    CollectionsStep? step,
    String? phoneNumber,
    Object? amount = _unset,
    String? transactionRef,
    String? errorMessage,
    bool? isSuccessful,
    Transaction? resultTransaction,
    int? pollAttempts,
  }) {
    return CollectionsState(
      step: step ?? this.step,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      amount: identical(amount, _unset) ? this.amount : amount as double?,
      transactionRef: transactionRef ?? this.transactionRef,
      errorMessage: errorMessage,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      resultTransaction: resultTransaction ?? this.resultTransaction,
      pollAttempts: pollAttempts ?? this.pollAttempts,
    );
  }

  @override
  List<Object?> get props => [
    step,
    phoneNumber,
    amount,
    transactionRef,
    errorMessage,
    isSuccessful,
    resultTransaction,
    pollAttempts,
  ];
}
