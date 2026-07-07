import 'package:clanship_mobile_tradesman/features/requests/domain/repositories/requests_repository.dart';

class MarkJobAsReadUseCase {
  final RequestsRepository repository;

  MarkJobAsReadUseCase(this.repository);

  Future<void> call(int jobId) async {
    return await repository.markJobAsRead(jobId);
  }
}
