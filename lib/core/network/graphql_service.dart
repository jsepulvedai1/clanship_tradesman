import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clanship_mobile_tradesman/core/config/environment_config.dart';

class GraphQLService {
  late final GraphQLClient client;
  late final GraphQLClient publicClient;
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

    final ErrorLink errorLink = ErrorLink(
      onGraphQLError: (request, forward, response) {
        for (final error in response.errors ?? []) {
          if (error.message.contains('SESSION_INVALIDATED')) {
            storage.delete(key: 'jwt_token');
          }
        }
        return forward(request);
      },
    );

    // Combine links: Auth -> Error -> HTTP
    final Link link = Link.from([authLink, errorLink, httpLink]);

    client = GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
    );

    publicClient = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
    );
  }
}
