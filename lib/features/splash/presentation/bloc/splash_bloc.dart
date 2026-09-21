import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/entities/user.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

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

class SplashConnectionError extends SplashState {
  final String message;

  SplashConnectionError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  SplashBloc(this.getCurrentUserUseCase) : super(SplashInitial()) {
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    
    final startTime = DateTime.now();

    // Reintentar ante fallos de conexión temporales (p.ej. reinicio de backend tras deploy)
    Either<Failure, User>? result;
    const maxAttempts = 3;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      result = await getCurrentUserUseCase(NoParams());

      bool shouldRetry = false;
      result.fold(
        (failure) {
          if (failure is AuthFailure) {
            shouldRetry = false;
          } else {
            shouldRetry = attempt < maxAttempts;
          }
        },
        (_) => shouldRetry = false,
      );

      if (shouldRetry) {
        await Future.delayed(const Duration(seconds: 2));
      } else {
        break;
      }
    }

    final elapsedTime = DateTime.now().difference(startTime);
    const minDelay = Duration(milliseconds: 1500);
    if (elapsedTime < minDelay) {
      await Future.delayed(minDelay - elapsedTime);
    }

    result?.fold(
      (failure) {
        if (failure is AuthFailure) {
          emit(SplashUnauthenticated());
        } else {
          emit(SplashConnectionError(failure.message));
        }
      },
      (user) => emit(SplashAuthenticated(user)),
    );
  }
}
