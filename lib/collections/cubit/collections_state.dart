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
    this.isSubmitting = false,
    this.resolvedName,
    this.isLookingUpName = false,
  });

  final CollectionsStep step;
  final String phoneNumber;
  final double? amount;
  final String? transactionRef;
  final String? errorMessage;
  final bool? isSuccessful;
  final Transaction? resultTransaction;
  final int pollAttempts;
  final bool isSubmitting;

  /// The account name resolved for [phoneNumber] via the name-lookup route
  /// (`pos_mobile_app_endpoints.md` §3a) — shown as a confidence check
  /// before the cashier confirms the amount. Null means "not resolved",
  /// which is never treated as an error: the lookup is a convenience, not
  /// a requirement, and never blocks [CollectionsCubit.submit].
  final String? resolvedName;
  final bool isLookingUpName;

  CollectionsState copyWith({
    CollectionsStep? step,
    String? phoneNumber,
    Object? amount = _unset,
    String? transactionRef,
    String? errorMessage,
    bool? isSuccessful,
    Transaction? resultTransaction,
    int? pollAttempts,
    bool? isSubmitting,
    Object? resolvedName = _unset,
    bool? isLookingUpName,
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
      isSubmitting: isSubmitting ?? this.isSubmitting,
      resolvedName: identical(resolvedName, _unset)
          ? this.resolvedName
          : resolvedName as String?,
      isLookingUpName: isLookingUpName ?? this.isLookingUpName,
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
    isSubmitting,
    resolvedName,
    isLookingUpName,
  ];
}
