import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/entities/user.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/get_current_user_usecase.dart';

// Events
abstract class SplashEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppStarted extends SplashEvent {}

// States
abstract class SplashState extends Equatable {
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}

class SplashAuthenticated extends SplashState {
  final User user;

  SplashAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class SplashUnauthenticated extends SplashState {}

// BLoC
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  SplashBloc(this.getCurrentUserUseCase) : super(SplashInitial()) {
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    
    final startTime = DateTime.now();

    final result = await getCurrentUserUseCase(NoParams());

    final elapsedTime = DateTime.now().difference(startTime);
    const minDelay = Duration(milliseconds: 1500);
    if (elapsedTime < minDelay) {
      await Future.delayed(minDelay - elapsedTime);
    }

    result.fold(
      (failure) => emit(SplashUnauthenticated()),
      (user) => emit(SplashAuthenticated(user)),
    );
  }
}
