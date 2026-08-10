import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:clanship_mobile_tradesman/core/config/environment_config.dart';
import 'package:clanship_mobile_tradesman/features/chat/data/models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<String> getOrCreateChatRoomWithCustomer(int customerId, {int? jobId});
  Future<List<MessageModel>> getChatHistory(String roomId);
  Stream<MessageModel> getMessagesStream(String roomId);
  Stream<Map<String, dynamic>> getJobStatusStream(String roomId);
  Future<void> sendMessage(
    String roomId, 
    String text, {
    String? fileBase64, 
    String? fileName, 
    String? messageType,
  });
  void closeConnection();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final GraphQLClient client;
  final storage = const FlutterSecureStorage();
  WebSocketChannel? _channel;
  StreamController<MessageModel>? _streamController;
  StreamController<Map<String, dynamic>>? _jobStatusController;

  ChatRemoteDataSourceImpl(this.client);

  @override
  Future<String> getOrCreateChatRoomWithCustomer(int customerId, {int? jobId}) async {
    const String mutation = r'''
      mutation GetOrCreateChatRoomWithCustomer($customerId: Int!, $jobId: Int) {
        getOrCreateChatRoomWithCustomer(customerId: $customerId, jobId: $jobId) {
          room {
            id
            customer {
              id
              firstName
            }
            professional {
              id
              firstName
            }
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'customerId': customerId,
        'jobId': jobId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final roomId = result.data?['getOrCreateChatRoomWithCustomer']?['room']?['id']?.toString();

    if (roomId == null) {
      throw Exception('Could not get room id');
    }

    return roomId;
  }

  @override
  Future<List<MessageModel>> getChatHistory(String roomId) async {
    const String query = r'''
      query GetChatMessages($roomId: Int!) {
        chatMessages(roomId: $roomId) {
          id
          text
          createdAt
          fileUrl
          messageType
          sender {
            id
            username
            avatarUrl
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {
        'roomId': int.parse(roomId),
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List<dynamic>? messagesData = result.data?['chatMessages'];
    
    if (messagesData == null) {
      return [];
    }

    return messagesData.map((e) => MessageModel.fromJsonGraphql(e)).toList();
  }

  @override
  Stream<MessageModel> getMessagesStream(String roomId) {
    _streamController ??= StreamController<MessageModel>.broadcast();
    _jobStatusController ??= StreamController<Map<String, dynamic>>.broadcast();
    
    _connectWebSocket(roomId);

    return _streamController!.stream;
  }

  @override
  Stream<Map<String, dynamic>> getJobStatusStream(String roomId) {
    _jobStatusController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _jobStatusController!.stream;
  }

  Future<void> _connectWebSocket(String roomId) async {
    final token = await storage.read(key: 'jwt_token');
    
    final uri = Uri.parse(EnvConfig.instance.websocketUrl);
    final baseUrl = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
    final wsUrl = Uri.parse('$baseUrl/ws/chat/$roomId/?token=$token');

    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (data) {
        try {
          final Map<String, dynamic> jsonData = jsonDecode(data);
          final type = jsonData['event'] ?? jsonData['type'];
          if (type == 'JOB_STATUS_CHANGED' || type == 'job_status_changed') {
            _jobStatusController?.add(jsonData);
          } else {
            final message = MessageModel.fromJsonWebSocket(jsonData);
            _streamController?.add(message);
          }
        } catch (_) {}
      },
      onError: (error) {
        _streamController?.addError(error);
      },
      onDone: () {
        // Handle disconnection if necessary
      },
    );
  }

  @override
  Future<void> sendMessage(
    String roomId, 
    String text, {
    String? fileBase64, 
    String? fileName, 
    String? messageType,
  }) async {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'message': text,
        'file_base64': fileBase64,
        'file_name': fileName,
        'message_type': messageType ?? 'TEXT',
      }));
    } else {
      throw Exception('WebSocket is not connected');
    }
  }

  @override
  void closeConnection() {
    _channel?.sink.close();
    _channel = null;
    _streamController?.close();
    _streamController = null;
    _jobStatusController?.close();
    _jobStatusController = null;
  }
}
