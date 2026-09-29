part of 'cashier_summary_cubit.dart';

enum CashierSummaryStatus { initial, loading, success, failure }

enum CashierSummaryFilter { all, successful, failed, pending }

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
    this.summary,
    this.errorMessage,
  });

  final CashierSummaryStatus status;
  final CashierSummaryFilter filter;
  final TransactionList? summary;
  final String? errorMessage;

  bool get isLoading => status == CashierSummaryStatus.loading;

  CashierSummaryState copyWith({
    CashierSummaryStatus? status,
    CashierSummaryFilter? filter,
    TransactionList? summary,
    String? errorMessage,
  }) {
    return CashierSummaryState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, filter, summary, errorMessage];
}
