import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:geepay_pos/models/transaction.dart';
import 'package:services_repo/services_repo.dart';

part 'cashier_summary_state.dart';

/// Drives the Cashier Summary screen: today's transactions, optionally
/// narrowed to one status via [setFilter].
class CashierSummaryCubit extends Cubit<CashierSummaryState> {
  CashierSummaryCubit(this._servicesRepo, this._authRepo)
    : super(
        CashierSummaryState(
          dateRange: _rangeFor(CashierSummaryDatePreset.today),
        ),
      ) {
    load();
  }

  final ServicesRepo _servicesRepo;
  final AuthRepo _authRepo;

  Future<void> setFilter(CashierSummaryFilter filter) async {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
    await load();
  }

  /// Applies a quick date preset. Use [setCustomDateRange] for custom ranges.
  /// There is no "any time" preset — every preset resolves to a concrete
  /// day range, defaulting to today.
  Future<void> setDatePreset(CashierSummaryDatePreset preset) async {
    if (preset == state.datePreset &&
        preset != CashierSummaryDatePreset.custom) {
      return;
    }
    emit(
      state.copyWith(datePreset: preset, dateRange: () => _rangeFor(preset)),
    );
    await load();
  }

  static DateTimeRange? _rangeFor(CashierSummaryDatePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (preset) {
      CashierSummaryDatePreset.today => DateTimeRange(
        start: today,
        end: today,
      ),
      CashierSummaryDatePreset.yesterday => DateTimeRange(
        start: DateTime(today.year, today.month, today.day - 1),
        end: DateTime(today.year, today.month, today.day - 1),
      ),
      CashierSummaryDatePreset.last7Days => DateTimeRange(
        start: DateTime(today.year, today.month, today.day - 6),
        end: today,
      ),
      CashierSummaryDatePreset.custom => null,
    };
  }

  Future<void> setCustomDateRange(DateTimeRange range) async {
    emit(
      state.copyWith(
        datePreset: CashierSummaryDatePreset.custom,
        dateRange: () => range,
      ),
    );
    await load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: CashierSummaryStatus.loading));
    final deviceId = await _authRepo.getPosDeviceId();
    final result = await _servicesRepo.getTransactions(
      posDeviceId: deviceId,
      status: state.filter.apiValue,
      startDate: state.dateRange?.start,
      endDate: state.dateRange?.end,
    );
    if (isClosed) return;
    if (result.success) {
      emit(
        state.copyWith(
          status: CashierSummaryStatus.success,
          summary: TransactionList.fromResponseData(result.data),
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: CashierSummaryStatus.failure,
          errorMessage: result.message,
        ),
      );
    }
  }
}
