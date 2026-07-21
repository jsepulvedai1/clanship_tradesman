import 'package:equatable/equatable.dart';

abstract class RequestsEvent extends Equatable {
  const RequestsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingRequests extends RequestsEvent {}

class LoadCompletedRequests extends RequestsEvent {}

class LoadRejectedRequests extends RequestsEvent {}

class UpdateJobStatusEvent extends RequestsEvent {
  final int jobId;
  final String newStatus;
  final String? cancellationReason;

  const UpdateJobStatusEvent({
    required this.jobId,
    required this.newStatus,
    this.cancellationReason,
  });

  @override
  List<Object?> get props => [jobId, newStatus, cancellationReason];
}

class MarkRequestAsReadEvent extends RequestsEvent {
  final int jobId;

  const MarkRequestAsReadEvent({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

class ScheduleJobVisitEvent extends RequestsEvent {
  final int jobId;
  final String scheduledDate;
  final String scheduledTime;
  final int notificationLeadMinutes;
  final double? agreedPrice;

  const ScheduleJobVisitEvent({
    required this.jobId,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.notificationLeadMinutes,
    this.agreedPrice,
  });

  @override
  List<Object?> get props => [jobId, scheduledDate, scheduledTime, notificationLeadMinutes, agreedPrice];
}
