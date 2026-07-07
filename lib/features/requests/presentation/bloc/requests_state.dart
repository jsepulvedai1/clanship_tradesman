import 'package:equatable/equatable.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/entities/active_request_detail_entity.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/entities/completed_job_entity.dart';

abstract class RequestsState extends Equatable {
  const RequestsState();

  @override
  List<Object?> get props => [];
}

class RequestsInitial extends RequestsState {}

class RequestsLoading extends RequestsState {}

class RequestsLoaded extends RequestsState {
  final List<ActiveRequestDetailEntity> requests;

  const RequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class CompletedRequestsLoaded extends RequestsState {
  final List<CompletedJobEntity> completedJobs;

  const CompletedRequestsLoaded(this.completedJobs);

  @override
  List<Object?> get props => [completedJobs];
}

class RejectedRequestsLoaded extends RequestsState {
  final List<ActiveRequestDetailEntity> rejectedRequests;

  const RejectedRequestsLoaded(this.rejectedRequests);

  @override
  List<Object?> get props => [rejectedRequests];
}

class RequestsError extends RequestsState {
  final String message;

  const RequestsError(this.message);

  @override
  List<Object?> get props => [message];
}
