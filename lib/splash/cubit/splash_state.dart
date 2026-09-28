part of 'splash_cubit.dart';

/// Where Splash should route to once it has resolved device/session state.
enum SplashDestination {
  /// Still resolving — show the loading UI.
  none,

  /// Device isn't registered yet.
  setup,

  /// Device registered but no active session.
  login,

  /// Device registered and session valid.
  main,
}

class SplashState extends Equatable {
  const SplashState({this.destination = SplashDestination.none});

  final SplashDestination destination;

  bool get isLoading => destination == SplashDestination.none;

  @override
  List<Object?> get props => [destination];
}
