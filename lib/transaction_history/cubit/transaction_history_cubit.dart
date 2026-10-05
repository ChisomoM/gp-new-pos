import 'dart:developer';

import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:geepay_pos/models/transaction.dart';
import 'package:services_repo/services_repo.dart';

part 'transaction_history_state.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  TransactionHistoryCubit(this._servicesRepo, this._authRepo)
    : super(
        TransactionHistoryState(
          dateRange: _rangeFor(TransactionHistoryDatePreset.today),
        ),
      ) {
    load();
  }

  final ServicesRepo _servicesRepo;
  final AuthRepo _authRepo;

  Future<void> setFilter(TransactionHistoryFilter filter) async {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
    await load();
  }

  /// Applies a quick date preset. Use [setCustomDateRange] for custom ranges.
  /// There is no "any time" preset — every preset resolves to a concrete
  /// day range, defaulting to today.
  Future<void> setDatePreset(TransactionHistoryDatePreset preset) async {
    if (preset == state.datePreset &&
        preset != TransactionHistoryDatePreset.custom) {
      return;
    }
    emit(
      state.copyWith(datePreset: preset, dateRange: () => _rangeFor(preset)),
    );
    await load();
  }

  static DateTimeRange? _rangeFor(TransactionHistoryDatePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (preset) {
      TransactionHistoryDatePreset.today => DateTimeRange(
        start: today,
        end: today,
      ),
      TransactionHistoryDatePreset.yesterday => DateTimeRange(
        start: DateTime(today.year, today.month, today.day - 1),
        end: DateTime(today.year, today.month, today.day - 1),
      ),
      TransactionHistoryDatePreset.last7Days => DateTimeRange(
        start: DateTime(today.year, today.month, today.day - 6),
        end: today,
      ),
      TransactionHistoryDatePreset.custom => null,
    };
  }

  Future<void> setCustomDateRange(DateTimeRange range) async {
    emit(
      state.copyWith(
        datePreset: TransactionHistoryDatePreset.custom,
        dateRange: () => range,
      ),
    );
    await load();
  }

  Future<void> clearFilters() async {
    emit(
      state.copyWith(
        filter: TransactionHistoryFilter.all,
        datePreset: TransactionHistoryDatePreset.today,
        dateRange: () => _rangeFor(TransactionHistoryDatePreset.today),
      ),
    );
    await load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: TransactionHistoryStatus.loading));
    final deviceId = await _authRepo.getDeviceId();
    final result = await _servicesRepo.getTransactions(
      posDeviceId: deviceId,
      status: state.filter.apiValue,
      startDate: state.dateRange?.start,
      endDate: state.dateRange?.end,
      pageSize: 1000,
    );
    // log('Loaded transactions: ${result.data}');
    if (isClosed) return;
    if (result.success) {
      final parsed = TransactionList.fromResponseData(result.data);
      emit(
        state.copyWith(
          status: TransactionHistoryStatus.success,
          transactions: parsed.transactions,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: TransactionHistoryStatus.failure,
          errorMessage: result.message,
        ),
      );
    }
  }
}
