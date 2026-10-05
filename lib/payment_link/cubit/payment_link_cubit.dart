import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:services_repo/services_repo.dart';
import 'package:uuid/uuid.dart';

part 'payment_link_state.dart';

/// Drives the Payment Link -> QR -> Result flow (`pos_mobile_app_endpoints.md`
/// §5). One instance is shared across all three screens (provided once at
/// `PaymentLinkPage` and reused via `BlocProvider.value` on the pushed
/// routes) so polling keeps running even if the cashier backgrounds a screen.
class PaymentLinkCubit extends Cubit<PaymentLinkState> {
  PaymentLinkCubit(this._servicesRepo, this._authRepo)
    : super(const PaymentLinkState());

  final ServicesRepo _servicesRepo;
  final AuthRepo _authRepo;
  Timer? _pollTimer;

  static const _pollInterval = Duration(seconds: 5);
  // ~10 minutes at a 5s interval — generous enough for a customer to open
  // the link and pay, without polling forever on an abandoned link. The
  // session itself stays valid on the backend for the full
  // `expires_in_minutes` regardless of whether this screen is still open.
  static const _maxPollAttempts = 120;

  void pickAmount(int amount) {
    emit(state.copyWith(amount: amount.toDouble()));
  }

  /// Called as the cashier types into the amount field. Clears the amount
  /// back to null when the text can't be parsed or is empty, rather than
  /// silently keeping a stale value.
  void setAmount(String text) {
    emit(state.copyWith(amount: double.tryParse(text.trim())));
  }

  Future<void> submit() async {
    final amount = state.amount;
    if (amount == null || amount <= 0) {
      emit(state.copyWith(errorMessage: 'Enter or choose an amount'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: ''));
    final transactionRef = const Uuid().v4();
    final deviceId = await _authRepo.getPosDeviceId();
    final user = await _authRepo.getUser();
    String? branchId;
    if (deviceId != null) {
      final (_, resolvedBranchId) = await _authRepo.getPosDevice(deviceId);
      branchId = resolvedBranchId;
    }

    final result = await _servicesRepo.createPaymentLink(
      amount: amount,
      transactionRef: transactionRef,
      branchId: branchId,
      posDeviceId: deviceId,
      userId: user?.id,
    );
    if (isClosed) return;
    if (!result.success) {
      emit(state.copyWith(isSubmitting: false, errorMessage: result.message));
      return;
    }

    final data = result.data;
    final checkoutUrl = data is Map ? data['checkout_url']?.toString() : null;
    final token = data is Map ? data['token']?.toString() : null;
    if (checkoutUrl == null || token == null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Unexpected response from server',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        step: PaymentLinkStep.active,
        checkoutUrl: checkoutUrl,
        token: token,
        status: 'pending',
        pollAttempts: 0,
        isSubmitting: false,
        errorMessage: '',
      ),
    );
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  static const _finalStatuses = {'paid', 'failed', 'cancelled', 'expired'};

  Future<void> _poll() async {
    final token = state.token;
    if (token == null) return;

    final attempts = state.pollAttempts + 1;
    final result = await _servicesRepo.checkPaymentLinkStatus(token);
    if (isClosed) return;

    if (result.success) {
      final data = result.data;
      final status = (data is Map ? data['status']?.toString() : null)
          ?.toLowerCase();
      if (status != null && _finalStatuses.contains(status)) {
        _pollTimer?.cancel();
        emit(state.copyWith(step: PaymentLinkStep.done, status: status));
        return;
      }
      if (status != null) {
        emit(state.copyWith(status: status, pollAttempts: attempts));
        return;
      }
    }

    if (attempts >= _maxPollAttempts) {
      _pollTimer?.cancel();
      emit(state.copyWith(step: PaymentLinkStep.done, status: 'expired'));
      return;
    }
    emit(state.copyWith(pollAttempts: attempts));
  }

  /// Cancels an in-flight link and returns the flow to the form step. The
  /// session itself isn't revoked server-side — this only stops the app
  /// from polling/displaying it.
  void cancel() {
    _pollTimer?.cancel();
    emit(const PaymentLinkState());
  }

  /// Resets state for "Create another" after a finished link.
  void reset() {
    _pollTimer?.cancel();
    emit(const PaymentLinkState());
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
