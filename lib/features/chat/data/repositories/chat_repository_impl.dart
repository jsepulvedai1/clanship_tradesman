import 'package:clanship_mobile_tradesman/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/entities/chat_message.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> getOrCreateChatRoomWithCustomer(int customerId, {int? jobId}) async {
    return await remoteDataSource.getOrCreateChatRoomWithCustomer(customerId, jobId: jobId);
  }

  @override
  Future<List<ChatMessage>> getMessagesHistory(String roomId, int currentUserId) async {
    final models = await remoteDataSource.getChatHistory(roomId);
    return models.map((model) => model.toEntity(currentUserId)).toList();
  }

  @override
  Stream<ChatMessage> getMessagesStream(String roomId, int currentUserId) {
    return remoteDataSource.getMessagesStream(roomId).map((model) => model.toEntity(currentUserId));
  }

  @override
  Future<void> sendMessage(String roomId, String text) async {
    await remoteDataSource.sendMessage(roomId, text);
  }

  @override
  void closeChat() {
    remoteDataSource.closeConnection();
  }
}
