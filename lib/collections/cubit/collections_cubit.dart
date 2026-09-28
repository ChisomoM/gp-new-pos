import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geepay_pos/models/transaction.dart';
import 'package:services_repo/services_repo.dart';
import 'package:uuid/uuid.dart';

part 'collections_state.dart';

/// Drives the Collections -> Collection Status -> Collection Result flow.
/// One instance is shared across all three screens (provided once at
/// `CollectionsPage` and reused via `BlocProvider.value` on the pushed
/// routes) so polling keeps running even if the user backgrounds a screen.
class CollectionsCubit extends Cubit<CollectionsState> {
  CollectionsCubit(this._servicesRepo, this._authRepo)
    : super(const CollectionsState());

  final ServicesRepo _servicesRepo;
  final AuthRepo _authRepo;
  Timer? _pollTimer;

  static const _pollInterval = Duration(seconds: 10);
  static const _maxPollAttempts = 30; // ~5 minutes at a 10s interval.

  void pickAmount(int amount) {
    emit(state.copyWith(amount: amount.toDouble()));
  }

  /// Called as the cashier types into the amount field. Clears the amount
  /// back to null (surfacing the "Choose an amount" validation) when the
  /// text can't be parsed or is empty, rather than silently keeping a stale
  /// value.
  void setAmount(String text) {
    emit(state.copyWith(amount: double.tryParse(text.trim())));
  }

  void setPhoneNumber(String phoneNumber) {
    emit(state.copyWith(phoneNumber: phoneNumber));
  }

  Future<void> submit() async {
    final phone = state.phoneNumber.trim();
    if (phone.isEmpty) {
      emit(state.copyWith(errorMessage: 'Enter a customer phone number'));
      return;
    }
    final amount = state.amount;
    if (amount == null) {
      emit(state.copyWith(errorMessage: 'Choose an amount'));
      return;
    }

    final transactionRef = const Uuid().v4();
    final deviceId = await _authRepo.getDeviceId();
    final result = await _servicesRepo.collect(
      phoneNumber: phone,
      amount: amount,
      transactionRef: transactionRef,
      posDeviceId: deviceId,
    );
    if (isClosed) return;
    if (!result.success) {
      emit(state.copyWith(errorMessage: result.message));
      return;
    }

    emit(
      state.copyWith(
        step: CollectionsStep.polling,
        transactionRef: transactionRef,
        errorMessage: '',
        pollAttempts: 0,
      ),
    );
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  Future<void> _poll() async {
    final ref = state.transactionRef;
    if (ref == null) return;

    final attempts = state.pollAttempts + 1;
    final result = await _servicesRepo.checkCollectionStatus(ref);
    if (isClosed) return;

    if (result.success) {
      final data = result.data;
      final tx = data is Map<String, dynamic>
          ? Transaction.fromJson(data)
          : null;
      final status = (tx?.status ?? '').toLowerCase();
      if (status == 'successful' || status == 'failed') {
        _pollTimer?.cancel();
        emit(
          state.copyWith(
            step: CollectionsStep.done,
            isSuccessful: status == 'successful',
            resultTransaction: tx,
          ),
        );
        return;
      }
    }

    if (attempts >= _maxPollAttempts) {
      _pollTimer?.cancel();
      emit(state.copyWith(step: CollectionsStep.done, isSuccessful: false));
      return;
    }
    emit(state.copyWith(pollAttempts: attempts));
  }

  /// Cancels an in-flight request and returns the flow to the form step.
  void cancel() {
    _pollTimer?.cancel();
    emit(const CollectionsState());
  }

  /// Resets state for "Try again" after a failed result, keeping nothing
  /// from the previous attempt.
  void reset() {
    _pollTimer?.cancel();
    emit(const CollectionsState());
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
