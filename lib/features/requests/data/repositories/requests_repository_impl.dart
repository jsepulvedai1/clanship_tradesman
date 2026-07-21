import 'package:clanship_mobile_tradesman/features/requests/data/datasources/requests_remote_data_source.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/entities/active_request_detail_entity.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/entities/completed_job_entity.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/repositories/requests_repository.dart';

class RequestsRepositoryImpl implements RequestsRepository {
  final RequestsRemoteDataSource remoteDataSource;

  RequestsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ActiveRequestDetailEntity>> getPendingRequests() async {
    final models = await remoteDataSource.getPendingJobRequests();
    return models
        .where((model) => model.status != 'FINISHED' && model.status != 'CANCELLED')
        .map((model) {
      return ActiveRequestDetailEntity(
        id: model.id,
        category: 'Nueva solicitud',
        instruction: model.description,
        clientName: model.customer?.firstName ?? 'Sin nombre',
        clientPhone: model.customer?.phoneNumber ?? 'Sin teléfono',
        clientAddress: model.address,
        customerId: model.customer?.id ?? 0,
        isUrgent: false, // Defaulting to false for now, unless status or description tells us
        scheduledDate: model.scheduledDate,
        scheduledTime: model.scheduledTime,
        agreedPrice: model.agreedPrice,
        status: model.status,
        isRead: model.isRead,
        hasUnreadMessages: model.hasUnreadMessages,
        enrichedDetails: model.enrichedDetails,
        additionalPhotoUrl: model.additionalPhotoUrl,
        notificationLeadMinutes: model.notificationLeadMinutes,
        cancellationReason: model.cancellationReason,
        cancelledByUserName: model.cancelledByUserName,
      );
    }).toList();
  }

  @override
  Future<List<CompletedJobEntity>> getCompletedRequests() async {
    final models = await remoteDataSource.getCompletedJobRequests();
    return models.map((model) {
      return CompletedJobEntity(
        id: model.id,
        category: 'Nueva solicitud',
        description: model.description,
        date: model.scheduledDate ?? '',
        time: model.scheduledTime ?? '',
        amount: model.agreedPrice ?? 0.0,
        isUrgent: false,
      );
    }).toList();
  }

  @override
  Future<List<ActiveRequestDetailEntity>> getRejectedRequests() async {
    final models = await remoteDataSource.getRejectedJobRequests();
    return models.map((model) {
      return ActiveRequestDetailEntity(
        id: model.id,
        category: 'Nueva solicitud',
        instruction: model.description,
        clientName: model.customer?.firstName ?? 'Sin nombre',
        clientPhone: model.customer?.phoneNumber ?? 'Sin teléfono',
        clientAddress: model.address,
        customerId: model.customer?.id ?? 0,
        isUrgent: false,
        scheduledDate: model.scheduledDate,
        scheduledTime: model.scheduledTime,
        agreedPrice: model.agreedPrice,
        status: model.status,
        isRead: model.isRead,
        enrichedDetails: model.enrichedDetails,
        additionalPhotoUrl: model.additionalPhotoUrl,
        notificationLeadMinutes: model.notificationLeadMinutes,
        cancellationReason: model.cancellationReason,
        cancelledByUserName: model.cancelledByUserName,
      );
    }).toList();
  }

  @override
  Future<void> updateJobStatus(int jobId, String newStatus, {String? cancellationReason}) async {
    await remoteDataSource.updateJobStatus(jobId, newStatus, cancellationReason: cancellationReason);
  }

  @override
  Future<void> markJobAsRead(int jobId) async {
    await remoteDataSource.markJobAsRead(jobId);
  }

  @override
  Future<void> scheduleJobVisit(int jobId, String scheduledDate, String scheduledTime, int notificationLeadMinutes, {double? agreedPrice}) async {
    await remoteDataSource.scheduleJobVisit(jobId, scheduledDate, scheduledTime, notificationLeadMinutes, agreedPrice: agreedPrice);
  }
}
