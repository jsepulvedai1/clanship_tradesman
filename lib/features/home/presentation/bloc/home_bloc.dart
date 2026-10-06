import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/job_request_entity.dart';
import '../../domain/entities/user_entity.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/get_my_profile_usecase.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/update_availability_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/get_pending_requests_usecase.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/features/requests/data/datasources/requests_remote_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class ToggleUrgency extends HomeEvent {
  final bool isEmergency;
  ToggleUrgency(this.isEmergency);
  @override
  List<Object> get props => [isEmergency];
}

class MarkOpportunitiesAsSeen extends HomeEvent {}

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
  final int openOpportunitiesCount;

  HomeDataLoaded(this.user, this.recentRequests, {this.openOpportunitiesCount = 0});

  @override
  List<Object> get props => [user, recentRequests, openOpportunitiesCount];
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
    on<ToggleUrgency>(_onToggleUrgency);
    on<MarkOpportunitiesAsSeen>(_onMarkOpportunitiesAsSeen);
  }

  Future<void> _onLoadUserData(LoadUserData event, Emitter<HomeState> emit) async {
    if (state is! HomeDataLoaded) {
      emit(HomeLoading());
    }
    
    final result = await getMyProfileUseCase(NoParams());
    
    List<JobRequestEntity> requestsList = [];
    int openOpportunitiesCount = 0;
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

    try {
      final prefs = await SharedPreferences.getInstance();
      final seenList = prefs.getStringList('seen_opportunities') ?? [];
      final dataSource = di.sl<RequestsRemoteDataSource>();
      final list = await dataSource.getOpenPublicJobRequests();
      openOpportunitiesCount = list.where((req) => !seenList.contains(req['id'].toString())).length;
    } catch (e) {
      print('Error al cargar oportunidades: $e');
    }
    
    result.fold(
      (failure) {
        print('HomeBloc: Error al obtener el perfil: $failure');
        emit(HomeError('Error al obtener el perfil'));
      },
      (user) {
        print('HomeBloc: _onLoadUserData actualizado exitosamente (activeJobs: ${user.activeJobs}, rejectedJobs: ${user.rejectedJobs}, scheduledJobs: ${user.scheduledJobs}, completedJobs: ${user.completedJobs})');
        emit(HomeDataLoaded(user, requestsList, openOpportunitiesCount: openOpportunitiesCount));
      },
    );
  }

  Future<void> _onToggleAvailability(
    ToggleAvailability event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeDataLoaded) {
      final currentState = state as HomeDataLoaded;
      
      final bool newAvailable = event.isAvailable;
      final bool newEmergency = newAvailable ? currentState.user.isEmergency : false;

      // Emit the optimistic state first
      final optimisticUser = currentState.user.copyWith(
        isAvailable: newAvailable,
        isEmergency: newEmergency,
      );
      emit(HomeDataLoaded(optimisticUser, currentState.recentRequests, openOpportunitiesCount: currentState.openOpportunitiesCount));

      final result = await updateAvailabilityUseCase(UpdateAvailabilityParams(
        isAvailable: newAvailable,
        isEmergency: newEmergency,
      ));
      result.fold(
        (failure) {
          emit(HomeDataLoaded(currentState.user, currentState.recentRequests, openOpportunitiesCount: currentState.openOpportunitiesCount));
        },
        (updatedUser) {
          emit(HomeDataLoaded(updatedUser, currentState.recentRequests, openOpportunitiesCount: currentState.openOpportunitiesCount));
        },
      );
    }
  }

  Future<void> _onMarkOpportunitiesAsSeen(
      MarkOpportunitiesAsSeen event, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is HomeDataLoaded) {
      try {
        final dataSource = di.sl<RequestsRemoteDataSource>();
        final list = await dataSource.getOpenPublicJobRequests();
        final newSeen = list.map((e) => e['id'].toString()).toList();
        final prefs = await SharedPreferences.getInstance();
        final existing = prefs.getStringList('seen_opportunities') ?? [];
        final combined = {...existing, ...newSeen}.toList();
        await prefs.setStringList('seen_opportunities', combined);
        emit(HomeDataLoaded(
          currentState.user,
          currentState.recentRequests,
          openOpportunitiesCount: 0,
        ));
      } catch (_) {}
    }
  }

  Future<void> _onToggleUrgency(
    ToggleUrgency event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeDataLoaded) {
      final currentState = state as HomeDataLoaded;
      
      final bool newEmergency = event.isEmergency;
      final bool newAvailable = newEmergency ? true : currentState.user.isAvailable;

      // Emit the optimistic state first
      final optimisticUser = currentState.user.copyWith(
        isAvailable: newAvailable,
        isEmergency: newEmergency,
      );
      emit(HomeDataLoaded(optimisticUser, currentState.recentRequests, openOpportunitiesCount: currentState.openOpportunitiesCount));

      final result = await updateAvailabilityUseCase(UpdateAvailabilityParams(
        isAvailable: newAvailable,
        isEmergency: newEmergency,
      ));
      result.fold(
        (failure) {
          emit(HomeDataLoaded(currentState.user, currentState.recentRequests, openOpportunitiesCount: currentState.openOpportunitiesCount));
        },
        (updatedUser) {
          emit(HomeDataLoaded(updatedUser, currentState.recentRequests, openOpportunitiesCount: currentState.openOpportunitiesCount));
        },
      );
    }
  }
}
