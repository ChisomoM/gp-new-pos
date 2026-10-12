part of 'cashier_summary_cubit.dart';

enum CashierSummaryStatus { initial, loading, success, failure }

enum CashierSummaryFilter { all, successful, failed, pending }

enum CashierSummaryDatePreset { today, yesterday, last7Days, custom }

extension on CashierSummaryFilter {
  String? get apiValue => switch (this) {
    CashierSummaryFilter.all => null,
    CashierSummaryFilter.successful => 'successful',
    CashierSummaryFilter.failed => 'failed',
    CashierSummaryFilter.pending => 'pending',
  };
}

/// Display label for [CashierSummaryFilter], used by the status picker and
/// its trigger button.
extension CashierSummaryFilterLabel on CashierSummaryFilter {
  String get label => switch (this) {
    CashierSummaryFilter.all => 'All statuses',
    CashierSummaryFilter.successful => 'Successful',
    CashierSummaryFilter.failed => 'Failed',
    CashierSummaryFilter.pending => 'Pending',
  };
}

class CashierSummaryState extends Equatable {
  const CashierSummaryState({
    this.status = CashierSummaryStatus.initial,
    this.filter = CashierSummaryFilter.all,
    this.datePreset = CashierSummaryDatePreset.today,
    this.dateRange,
    this.summary,
    this.errorMessage,
  });

  final CashierSummaryStatus status;
  final CashierSummaryFilter filter;
  final CashierSummaryDatePreset datePreset;

  /// Inclusive day range for the active preset. Always set by the cubit
  /// (defaults to today) — there is no "any time"/unbounded option.
  final DateTimeRange? dateRange;
  final TransactionList? summary;
  final String? errorMessage;

  bool get isLoading => status == CashierSummaryStatus.loading;

  CashierSummaryState copyWith({
    CashierSummaryStatus? status,
    CashierSummaryFilter? filter,
    CashierSummaryDatePreset? datePreset,
    DateTimeRange? Function()? dateRange,
    TransactionList? summary,
    String? errorMessage,
  }) {
    return CashierSummaryState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      datePreset: datePreset ?? this.datePreset,
      dateRange: dateRange != null ? dateRange() : this.dateRange,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    filter,
    datePreset,
    dateRange,
    summary,
    errorMessage,
  ];
}
