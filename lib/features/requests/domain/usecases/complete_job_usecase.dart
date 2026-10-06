import 'package:clanship_mobile_tradesman/features/requests/domain/repositories/requests_repository.dart';

class CompleteJobUseCase {
  final RequestsRepository repository;

  CompleteJobUseCase(this.repository);

  Future<void> call(
    int jobId, {
    double? finalPrice,
    String? tradesmanComments,
    List<String>? finishedPhotosBase64,
  }) async {
    return await repository.completeJob(
      jobId,
      finalPrice: finalPrice,
      tradesmanComments: tradesmanComments,
      finishedPhotosBase64: finishedPhotosBase64,
    );
  }
}
