import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clanship_mobile_tradesman/core/config/environment_config.dart';
import 'package:clanship_mobile_tradesman/core/network/session_service.dart';

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
      onGraphQLError: (request, forward, response) async* {
        bool shouldRetry = false;
        for (final error in response.errors ?? []) {
          final message = error.message;
          if (message.contains('SESSION_INVALIDATED')) {
            await storage.delete(key: 'jwt_token');
            await storage.delete(key: 'jwt_refresh_token');
            SessionService.instance.notifySessionInvalidated(
              'Tu sesión ha sido iniciada en otro dispositivo.',
            );
          } else if (message.contains('Signature has expired') || 
                     message.contains('Error decoding signature') ||
                     message.contains('Token is invalid') ||
                     message.contains('TOKEN_EXPIRED')) {
            final refreshToken = await storage.read(key: 'jwt_refresh_token');
            if (refreshToken != null) {
              try {
                final HttpLink tempHttpLink = HttpLink(EnvConfig.instance.baseUrl);
                final GraphQLClient tempClient = GraphQLClient(
                  cache: GraphQLCache(),
                  link: tempHttpLink,
                );

                final MutationOptions refreshOptions = MutationOptions(
                  document: gql(r'''
                    mutation RefreshToken($refreshToken: String!) {
                      refreshToken(refreshToken: $refreshToken) {
                        token
                        refreshToken
                      }
                    }
                  '''),
                  variables: {'refreshToken': refreshToken},
                  fetchPolicy: FetchPolicy.networkOnly,
                );

                final result = await tempClient.mutate(refreshOptions);
                if (!result.hasException) {
                  final newToken = result.data?['refreshToken']?['token'];
                  final newRefresh = result.data?['refreshToken']?['refreshToken'];

                  if (newToken != null) {
                    await storage.write(key: 'jwt_token', value: newToken);
                    if (newRefresh != null) {
                      await storage.write(key: 'jwt_refresh_token', value: newRefresh);
                    }
                    shouldRetry = true;
                  } else {
                    await storage.delete(key: 'jwt_token');
                    await storage.delete(key: 'jwt_refresh_token');
                    SessionService.instance.notifySessionInvalidated('Tu sesión ha expirado.');
                  }
                } else {
                  await storage.delete(key: 'jwt_token');
                  await storage.delete(key: 'jwt_refresh_token');
                  SessionService.instance.notifySessionInvalidated('Tu sesión ha expirado.');
                }
              } catch (e) {
                await storage.delete(key: 'jwt_token');
                await storage.delete(key: 'jwt_refresh_token');
                SessionService.instance.notifySessionInvalidated('Tu sesión ha expirado.');
              }
            } else {
              await storage.delete(key: 'jwt_token');
              SessionService.instance.notifySessionInvalidated('Tu sesión ha expirado.');
            }
          }
        }
        
        if (shouldRetry) {
          final newToken = await storage.read(key: 'jwt_token');
          final updatedRequest = request.updateContextEntry<HttpLinkHeaders>(
            (headers) => HttpLinkHeaders(
              headers: {
                ...headers?.headers ?? {},
                'Authorization': 'JWT $newToken',
              },
            ),
          );
          yield* forward(updatedRequest);
        } else {
          yield response;
        }
      },
    );

    // Combine links: Auth -> Error -> HTTP
    final Link link = Link.from([authLink, errorLink, httpLink]);

    client = GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
      queryRequestTimeout: null,
    );

    publicClient = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
      queryRequestTimeout: null,
    );
  }
}
