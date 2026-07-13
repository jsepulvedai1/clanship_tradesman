import 'package:clanship_mobile_tradesman/features/requests/domain/entities/active_request_detail_entity.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/entities/completed_job_entity.dart';

abstract class RequestsRepository {
  Future<List<ActiveRequestDetailEntity>> getPendingRequests();
  Future<List<CompletedJobEntity>> getCompletedRequests();
  Future<List<ActiveRequestDetailEntity>> getRejectedRequests();
  Future<void> updateJobStatus(int jobId, String newStatus);
  Future<void> markJobAsRead(int jobId);
  Future<void> scheduleJobVisit(int jobId, String scheduledDate, String scheduledTime, int notificationLeadMinutes, {double? agreedPrice});
}
