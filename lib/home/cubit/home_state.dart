part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

/// {@template home}
/// State for the Dashboard (Home) screen.
/// {@endtemplate}
class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.data,
    this.errorMessage,
  });

  final HomeStatus status;
  final TransactionList? data;
  final String? errorMessage;

  bool get isLoading => status == HomeStatus.loading;

  HomeState copyWith({
    HomeStatus? status,
    TransactionList? data,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
