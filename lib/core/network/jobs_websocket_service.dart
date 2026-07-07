import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:clanship_mobile_tradesman/core/config/environment_config.dart';

class JobsWebSocketService {
  final storage = const FlutterSecureStorage();
  WebSocketChannel? _channel;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnecting = false;
  Timer? _reconnectTimer;

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void connect() async {
    if (_channel != null || _isConnecting) return;
    _isConnecting = true;

    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) {
        _isConnecting = false;
        return;
      }

      // Convert from ws://.../graphql/ to ws://.../ws/jobs/
      final baseWsUrl = EnvConfig.instance.websocketUrl.replaceAll('/graphql/', '/ws/jobs/');
      final wsUrl = Uri.parse('$baseWsUrl?token=$token');

      debugPrint('Connecting to Jobs WebSocket: $wsUrl');
      _channel = WebSocketChannel.connect(wsUrl);

      _channel!.stream.listen(
        (data) {
          try {
            final Map<String, dynamic> jsonData = jsonDecode(data.toString());
            _controller.add(jsonData);
          } catch (e) {
            debugPrint('Error decoding jobs socket message: $e');
          }
        },
        onError: (err) {
          debugPrint('Jobs WebSocket error: $err');
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('Jobs WebSocket connection closed');
          _scheduleReconnect();
        },
      );
    } catch (e) {
      debugPrint('Failed to connect to Jobs WebSocket: $e');
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void _scheduleReconnect() {
    _channel = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      debugPrint('Reconnecting to Jobs WebSocket...');
      connect();
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    debugPrint('Disconnected from Jobs WebSocket');
  }
}
