import 'package:clanship_mobile_tradesman/features/requests/domain/repositories/requests_repository.dart';

class ScheduleJobVisitUseCase {
  final RequestsRepository repository;

  ScheduleJobVisitUseCase(this.repository);

  Future<void> call({
    required int jobId,
    required String scheduledDate,
    required String scheduledTime,
    required int notificationLeadMinutes,
    double? agreedPrice,
  }) async {
    return await repository.scheduleJobVisit(
      jobId,
      scheduledDate,
      scheduledTime,
      notificationLeadMinutes,
      agreedPrice: agreedPrice,
    );
  }
}
