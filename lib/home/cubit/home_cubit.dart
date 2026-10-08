import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geepay_pos/models/transaction.dart';
import 'package:services_repo/services_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._servicesRepo, this._authRepo) : super(const HomeState()) {
    load();
  }

  final ServicesRepo _servicesRepo;
  final AuthRepo _authRepo;

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));
    final deviceId = await _authRepo.getPosDeviceId();
    final result = await _servicesRepo.getTransactions(
      posDeviceId: deviceId,
      todayOnly: true,
    );
    if (isClosed) return;
    if (result.success) {
      emit(
        state.copyWith(
          status: HomeStatus.success,
          data: TransactionList.fromResponseData(result.data),
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: result.message,
        ),
      );
    }
  }
}
