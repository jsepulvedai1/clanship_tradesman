import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clanship_mobile_tradesman/core/config/environment_config.dart';

class GraphQLService {
  late final GraphQLClient client;
  final storage = const FlutterSecureStorage();

  GraphQLService(SharedPreferences sharedPreferences) {
    final HttpLink httpLink = HttpLink(
      EnvConfig.instance.baseUrl,
    );

    final AuthLink authLink = AuthLink(
      getToken: () async {
        // Read the JWT token from Secure Storage
        final token = await storage.read(key: 'jwt_token');
        if (token != null && token.isNotEmpty) {
          return 'JWT $token'; // Or 'Bearer $token' depending on your Django configuration
        }
        return null;
      },
    );

    // If using websockets for subscriptions, configure WebSocketLink here
    final WebSocketLink websocketLink = WebSocketLink(
      EnvConfig.instance.websocketUrl,
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: null,
        initialPayload: () async {
          final token = await storage.read(key: 'jwt_token');
          return {
            'Authorization': token != null ? 'JWT $token' : '',
          };
        },
      ),
    );

    // Combine links: Auth -> HTTP
    // For subscriptions, split based on operation type
    final Link link = Link.split(
      (request) => request.isSubscription,
      websocketLink,
      authLink.concat(httpLink),
    );

    client = GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
    );
  }
}
