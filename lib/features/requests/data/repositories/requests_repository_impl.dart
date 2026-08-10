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
        .where(
          (model) => model.status != 'FINISHED' && model.status != 'CANCELLED',
        )
        .map((model) {
          final categoryStr = _getCategoryForStatus(model.status);
          final clientNameStr = model.customer != null
              ? model.customer!.fullName
              : 'Sin nombre';

          return ActiveRequestDetailEntity(
            id: model.id,
            category: categoryStr,
            instruction: model.description,
            clientName: clientNameStr,
            clientPhone: model.customer?.phoneNumber ?? 'Sin teléfono',
            clientAddress: model.address,
            customerId: model.customer?.id ?? 0,
            isUrgent: false,
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
        })
        .toList();
  }

  String _getCategoryForStatus(String status) {
    switch (status) {
      case 'SCHEDULED':
        return 'Visita Agendada';
      case 'AGREED':
        return 'Trabajo Acordado';
      case 'IN_VISIT':
        return 'Visita en Curso';
      case 'ACCEPTED':
        return 'Solicitud Aceptada';
      case 'REQUESTED':
      default:
        return 'Nueva Solicitud';
    }
  }

  @override
  Future<List<CompletedJobEntity>> getCompletedRequests() async {
    final models = await remoteDataSource.getCompletedJobRequests();
    models.sort((a, b) {
      if (a.createdAt != null && b.createdAt != null) {
        return b.createdAt!.compareTo(a.createdAt!);
      }
      final idA = int.tryParse(a.id) ?? 0;
      final idB = int.tryParse(b.id) ?? 0;
      return idB.compareTo(idA);
    });

    return models.map((model) {
      final clientNameStr =
          model.customer?.firstName != null &&
              model.customer!.firstName.trim().isNotEmpty
          ? model.customer!.firstName.trim()
          : 'Cliente';
      final descriptionStr =
          model.description.trim().isNotEmpty &&
              model.description != 'Nueva solicitud de servicio' &&
              model.description != 'Servicio de visita técnica realizada'
          ? model.description
          : '';

      return CompletedJobEntity(
        id: model.id,
        category: 'Trabajo Finalizado',
        clientName: clientNameStr,
        description: descriptionStr,
        date: model.scheduledDate ?? '',
        time: model.scheduledTime ?? '',
        amount: model.agreedPrice ?? 0.0,
        isUrgent: false,
        rating: model.rating,
        reviewComment: model.reviewComment,
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
  Future<void> updateJobStatus(
    int jobId,
    String newStatus, {
    String? cancellationReason,
  }) async {
    await remoteDataSource.updateJobStatus(
      jobId,
      newStatus,
      cancellationReason: cancellationReason,
    );
  }

  @override
  Future<void> markJobAsRead(int jobId) async {
    await remoteDataSource.markJobAsRead(jobId);
  }

  @override
  Future<void> scheduleJobVisit(
    int jobId,
    String scheduledDate,
    String scheduledTime,
    int notificationLeadMinutes, {
    double? agreedPrice,
  }) async {
    await remoteDataSource.scheduleJobVisit(
      jobId,
      scheduledDate,
      scheduledTime,
      notificationLeadMinutes,
      agreedPrice: agreedPrice,
    );
  }
}
