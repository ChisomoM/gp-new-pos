import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geepay_pos/models/transaction.dart';
import 'package:services_repo/services_repo.dart';

part 'transaction_details_state.dart';

class TransactionDetailsCubit extends Cubit<TransactionDetailsState> {
  TransactionDetailsCubit(this._servicesRepo, this.transactionId)
    : super(const TransactionDetailsState()) {
    load();
  }

  final ServicesRepo _servicesRepo;
  final String transactionId;

  Future<void> load() async {
    emit(const TransactionDetailsState());
    final result = await _servicesRepo.getTransactionDetails(transactionId);
    if (isClosed) return;
    if (result.success) {
      emit(
        TransactionDetailsState(
          status: TransactionDetailsStatus.success,
          transaction: Transaction.fromDetailResponse(result.data),
        ),
      );
    } else {
      emit(
        TransactionDetailsState(
          status: TransactionDetailsStatus.failure,
          errorMessage: result.message,
        ),
      );
    }
  }
}
