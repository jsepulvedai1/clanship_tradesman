import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/job_request_entity.dart';
import '../../domain/entities/user_entity.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/get_my_profile_usecase.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/update_availability_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/get_pending_requests_usecase.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';

// Events
abstract class HomeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadUserData extends HomeEvent {}
class ToggleAvailability extends HomeEvent {
  final bool isAvailable;
  ToggleAvailability(this.isAvailable);
  @override
  List<Object> get props => [isAvailable];
}

// States
abstract class HomeState extends Equatable {
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeDataLoaded extends HomeState {
  final UserEntity user;
  final List<JobRequestEntity> recentRequests;

  HomeDataLoaded(this.user, this.recentRequests);

  @override
  List<Object> get props => [user, recentRequests];
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetMyProfileUseCase getMyProfileUseCase;
  final UpdateAvailabilityUseCase updateAvailabilityUseCase;
  final GetPendingRequestsUseCase getPendingRequestsUseCase;

  HomeBloc(
    this.getMyProfileUseCase,
    this.updateAvailabilityUseCase,
    this.getPendingRequestsUseCase,
  ) : super(HomeInitial()) {
    on<LoadUserData>(_onLoadUserData);
    on<ToggleAvailability>(_onToggleAvailability);
  }

  Future<void> _onLoadUserData(LoadUserData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    
    final result = await getMyProfileUseCase(NoParams());
    
    List<JobRequestEntity> requestsList = [];
    try {
      final pendingRequests = await getPendingRequestsUseCase();
      requestsList = pendingRequests.map((req) {
        return JobRequestEntity(
          id: req.id,
          title: req.category,
          description: req.instruction,
          createdAt: req.scheduledDate != null
              ? DateTime.tryParse(req.scheduledDate!) ?? DateTime.now()
              : DateTime.now(),
          status: req.status,
          isRead: req.isRead,
        );
      }).toList();
    } catch (e) {
      // Registrar el error pero continuar para mostrar al menos el perfil cargado
      print('Error al cargar solicitudes reales para HomeBloc: $e');
    }
    
    result.fold(
      (failure) => emit(HomeError('Error al obtener el perfil')),
      (user) => emit(HomeDataLoaded(user, requestsList)),
    );
  }

  Future<void> _onToggleAvailability(
    ToggleAvailability event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeDataLoaded) {
      final currentState = state as HomeDataLoaded;
      
      // Emit the optimistic state first
      final optimisticUser = currentState.user.copyWith(isAvailable: event.isAvailable);
      emit(HomeDataLoaded(optimisticUser, currentState.recentRequests));

      final result = await updateAvailabilityUseCase(event.isAvailable);
      result.fold(
        (failure) {
          // If the network call failed, snapback to original value
          emit(HomeDataLoaded(currentState.user, currentState.recentRequests));
        },
        (updatedUser) {
          // State is already updated, but we ensure we hold the correct server-returned object
          emit(HomeDataLoaded(updatedUser, currentState.recentRequests));
        },
      );
    }
  }
}
