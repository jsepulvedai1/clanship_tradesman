import 'package:clanship_mobile_tradesman/features/requests/domain/repositories/requests_repository.dart';

class UpdateJobStatusUseCase {
  final RequestsRepository repository;

  UpdateJobStatusUseCase(this.repository);

  Future<void> call({required int jobId, required String newStatus, String? cancellationReason}) async {
    return await repository.updateJobStatus(jobId, newStatus, cancellationReason: cancellationReason);
  }
}
