import 'package:clanship_mobile_tradesman/features/requests/domain/entities/completed_job_entity.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/repositories/requests_repository.dart';

class GetCompletedRequestsUseCase {
  final RequestsRepository repository;

  GetCompletedRequestsUseCase(this.repository);

  Future<List<CompletedJobEntity>> call() async {
    return await repository.getCompletedRequests();
  }
}
