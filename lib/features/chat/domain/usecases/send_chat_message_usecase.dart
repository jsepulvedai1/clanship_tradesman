import 'package:clanship_mobile_tradesman/features/chat/domain/repositories/chat_repository.dart';

class SendChatMessageUseCase {
  final ChatRepository repository;

  SendChatMessageUseCase(this.repository);

  Future<void> call(String roomId, String text) async {
    return await repository.sendMessage(roomId, text);
  }
}
