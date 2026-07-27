import 'dart:async';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/login_usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/register_usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/logout_usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final RequestPasswordResetUseCase requestPasswordResetUseCase;

  AuthBloc(this.loginUseCase, this.registerUseCase, this.logoutUseCase, this.requestPasswordResetUseCase) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AvatarUpdated>(_onAvatarUpdated);
    on<ProfileUpdated>(_onProfileUpdated);
    on<RegisterRequested>(_onRegisterRequested);
    on<UserAuthenticated>(_onUserAuthenticated);
    on<PasswordResetRequested>(_onPasswordResetRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await logoutUseCase(NoParams());
    emit(AuthUnauthenticated());
  }

  void _onUserAuthenticated(UserAuthenticated event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }

  /// Handles the update of the user's avatar path.
  /// Only applicable if the user is already authenticated.
  void _onAvatarUpdated(AvatarUpdated event, Emitter<AuthState> emit) {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      // Update the user within the AuthAuthenticated state
      final updatedUser = currentUser.copyWith(avatarPath: event.avatarPath);
      emit(AuthAuthenticated(updatedUser));
    }
  }

  /// Handles the update of the user's profile information.
  void _onProfileUpdated(ProfileUpdated event, Emitter<AuthState> emit) {
    if (state is AuthAuthenticated) {
      emit(AuthAuthenticated(event.user));
    }
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        address: event.address,
        phoneNumber: event.phoneNumber,
        avatarPath: event.avatarPath,
        cedulaFrontPath: event.cedulaFrontPath,
        cedulaBackPath: event.cedulaBackPath,
        certificates: event.certificates,
        latitude: event.latitude,
        longitude: event.longitude,
        specialtyIds: event.specialtyIds,
        tagIds: event.tagIds,
        subtagIds: event.subtagIds,
        bio: event.bio,
        workPhotoPaths: event.workPhotoPaths,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onPasswordResetRequested(PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await requestPasswordResetUseCase(event.email);
    result.fold(
      (failure) => emit(PasswordResetFailure(failure.message)),
      (_) => emit(const PasswordResetSuccess('Se ha enviado un correo con las instrucciones.')),
    );
  }
}
