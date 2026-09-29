import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geepay_pos/models/transaction.dart';
import 'package:services_repo/services_repo.dart';

part 'cashier_summary_state.dart';

/// Drives the Cashier Summary screen: today's transactions, optionally
/// narrowed to one status via [setFilter].
class CashierSummaryCubit extends Cubit<CashierSummaryState> {
  CashierSummaryCubit(this._servicesRepo, this._authRepo)
    : super(const CashierSummaryState()) {
    load();
  }

  final ServicesRepo _servicesRepo;
  final AuthRepo _authRepo;

  Future<void> setFilter(CashierSummaryFilter filter) async {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
    await load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: CashierSummaryStatus.loading));
    final deviceId = await _authRepo.getDeviceId();
    final result = await _servicesRepo.getTransactions(
      posDeviceId: deviceId,
      status: state.filter.apiValue,
      todayOnly: true,
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
