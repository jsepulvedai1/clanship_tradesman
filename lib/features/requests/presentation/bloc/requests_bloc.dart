import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:clanship_mobile_tradesman/core/config/environment_config.dart';
import 'package:clanship_mobile_tradesman/core/utils/error_parser.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/get_pending_requests_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/get_completed_requests_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/get_rejected_requests_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/update_job_status_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/mark_job_as_read_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/schedule_job_visit_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_event.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_state.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final GetPendingRequestsUseCase getPendingRequests;
  final GetCompletedRequestsUseCase getCompletedRequests;
  final GetRejectedRequestsUseCase getRejectedRequests;
  final UpdateJobStatusUseCase updateJobStatus;
  final MarkJobAsReadUseCase markJobAsRead;
  final ScheduleJobVisitUseCase scheduleJobVisit;
  final storage = const FlutterSecureStorage();

  WebSocketChannel? _jobsChannel;

  RequestsBloc({
    required this.getPendingRequests,
    required this.getCompletedRequests,
    required this.getRejectedRequests,
    required this.updateJobStatus,
    required this.markJobAsRead,
    required this.scheduleJobVisit,
  }) : super(RequestsInitial()) {
    on<LoadPendingRequests>(_onLoadPendingRequests);
    on<LoadCompletedRequests>(_onLoadCompletedRequests);
    on<LoadRejectedRequests>(_onLoadRejectedRequests);
    on<UpdateJobStatusEvent>(_onUpdateJobStatus);
    on<MarkRequestAsReadEvent>(_onMarkRequestAsRead);
    on<ScheduleJobVisitEvent>(_onScheduleJobVisit);
  }

  void _connectJobsWebSocket() async {
    if (_jobsChannel != null) return;
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return;

      final uri = Uri.parse(EnvConfig.instance.websocketUrl);
      final baseUrl =
          '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
      final wsUrl = Uri.parse('$baseUrl/ws/jobs/?token=$token');

      _jobsChannel = WebSocketChannel.connect(wsUrl);
      _jobsChannel!.stream.listen(
        (data) {
          try {
            final Map<String, dynamic> jsonData = jsonDecode(data);
            final event = jsonData['event'];
            if (event == 'job_created' || event == 'job_updated') {
              add(LoadPendingRequests());
            }
          } catch (_) {}
        },
        onError: (_) {
          _jobsChannel = null;
        },
        onDone: () {
          _jobsChannel = null;
        },
      );
    } catch (_) {
      _jobsChannel = null;
    }
  }

  Future<void> _onLoadPendingRequests(
    LoadPendingRequests event,
    Emitter<RequestsState> emit,
  ) async {
    _connectJobsWebSocket();
    if (state is! RequestsLoaded) {
      emit(RequestsLoading());
    }
    try {
      final requests = await getPendingRequests();
      emit(RequestsLoaded(requests));
    } catch (e) {
      emit(RequestsError(sanitizeErrorForUser(e)));
    }
  }

  Future<void> _onLoadCompletedRequests(
    LoadCompletedRequests event,
    Emitter<RequestsState> emit,
  ) async {
    if (state is! CompletedRequestsLoaded) {
      emit(RequestsLoading());
    }
    try {
      final completedJobs = await getCompletedRequests();
      emit(CompletedRequestsLoaded(completedJobs));
    } catch (e) {
      emit(RequestsError(sanitizeErrorForUser(e)));
    }
  }

  Future<void> _onLoadRejectedRequests(
    LoadRejectedRequests event,
    Emitter<RequestsState> emit,
  ) async {
    if (state is! RejectedRequestsLoaded) {
      emit(RequestsLoading());
    }
    try {
      final rejected = await getRejectedRequests();
      emit(RejectedRequestsLoaded(rejected));
    } catch (e) {
      emit(RequestsError(sanitizeErrorForUser(e)));
    }
  }

  Future<void> _onUpdateJobStatus(
    UpdateJobStatusEvent event,
    Emitter<RequestsState> emit,
  ) async {
    if (state is! RequestsLoaded && state is! CompletedRequestsLoaded && state is! RejectedRequestsLoaded) {
      emit(RequestsLoading());
    }
    try {
      await updateJobStatus(
        jobId: event.jobId,
        newStatus: event.newStatus,
        cancellationReason: event.cancellationReason,
      );
      final requests = await getPendingRequests();
      emit(RequestsLoaded(requests));
    } catch (e) {
      emit(RequestsError(sanitizeErrorForUser(e)));
    }
  }

  Future<void> _onMarkRequestAsRead(
    MarkRequestAsReadEvent event,
    Emitter<RequestsState> emit,
  ) async {
    try {
      if (state is RequestsLoaded) {
        final currentRequests = (state as RequestsLoaded).requests;
        final updatedRequests = currentRequests.map((r) {
          if (r.id == event.jobId.toString()) {
            return r.copyWith(isRead: true);
          }
          return r;
        }).toList();
        emit(RequestsLoaded(updatedRequests));
      }
      await markJobAsRead(event.jobId);
    } catch (e) {
      // Si falla, no rompemos el flujo de la UI, solo reportamos el error
    }
  }

  Future<void> _onScheduleJobVisit(
    ScheduleJobVisitEvent event,
    Emitter<RequestsState> emit,
  ) async {
    if (state is! RequestsLoaded) {
      emit(RequestsLoading());
    }
    try {
      await scheduleJobVisit(
        jobId: event.jobId,
        scheduledDate: event.scheduledDate,
        scheduledTime: event.scheduledTime,
        notificationLeadMinutes: event.notificationLeadMinutes,
        agreedPrice: event.agreedPrice,
      );
      final requests = await getPendingRequests();
      emit(RequestsLoaded(requests));
    } catch (e) {
      emit(RequestsError(sanitizeErrorForUser(e)));
    }
  }

  @override
  Future<void> close() {
    _jobsChannel?.sink.close();
    _jobsChannel = null;
    return super.close();
  }
}
