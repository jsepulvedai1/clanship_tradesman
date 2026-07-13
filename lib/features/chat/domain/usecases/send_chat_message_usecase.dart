import 'package:clanship_mobile_tradesman/features/chat/domain/repositories/chat_repository.dart';

class SendChatMessageUseCase {
  final ChatRepository repository;

  SendChatMessageUseCase(this.repository);

  Future<void> call(
    String roomId, 
    String text, {
    String? fileBase64, 
    String? fileName, 
    String? messageType,
  }) async {
    return await repository.sendMessage(
      roomId, 
      text, 
      fileBase64: fileBase64, 
      fileName: fileName, 
      messageType: messageType,
    );
  }
}
