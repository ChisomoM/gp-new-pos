import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geepay_pos/models/transaction.dart';
import 'package:services_repo/services_repo.dart';

part 'transaction_history_state.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  TransactionHistoryCubit(this._servicesRepo, this._authRepo)
    : super(const TransactionHistoryState()) {
    load();
  }

  final ServicesRepo _servicesRepo;
  final AuthRepo _authRepo;

  Future<void> setFilter(TransactionHistoryFilter filter) async {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
    await load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: TransactionHistoryStatus.loading));
    final deviceId = await _authRepo.getDeviceId();
    final result = await _servicesRepo.getTransactions(
      posDeviceId: deviceId,
      status: state.filter.apiValue,
      pageSize: 50,
    );
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
