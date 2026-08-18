import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/core/network/graphql_service.dart';
import 'package:clanship_mobile_tradesman/firebase_options.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_event.dart';
import 'package:clanship_mobile_tradesman/core/network/local_notification_service.dart';

class FirebaseNotificationHelper {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final messaging = FirebaseMessaging.instance;

      // Request notification permissions
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('User granted notification permission: ${settings.authorizationStatus}');

      // Habilitar alertas/popups/sonidos cuando la app está abierta en primer plano (foreground)
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground push notification received: ${message.notification?.title} - ${message.notification?.body}');
        _handleIncomingMessage(message);
      });

      // Handle notification taps when app is in background but not terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification opened app: ${message.messageId}');
        _handleIncomingMessage(message);
      });

      // Check if the app was opened by a notification tap from terminated state
      messaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          debugPrint('App opened from terminated state via notification: ${message.messageId}');
          _handleIncomingMessage(message);
        }
      });

      // Handle background/terminated state messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Listen to token refresh and update backend
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        debugPrint('Tradesman FCM Token refreshed: $token');
        _sendTokenToBackend(token);
      });
    } catch (e) {
      debugPrint('Error initializing Firebase Push Notifications: $e');
    }
  }

  static void _handleIncomingMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? 'Notificación';
    final body = message.notification?.body ?? message.data['body'] ?? 'Tienes un nuevo mensaje';
    LocalNotificationService.saveNotification(title, body);

    try {
      di.sl<RequestsBloc>().add(RefreshCurrentRequests());
    } catch (_) {}
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Background message received: ${message.messageId}');
    final title = message.notification?.title ?? message.data['title'] ?? 'Notificación';
    final body = message.notification?.body ?? message.data['body'] ?? 'Tienes un nuevo mensaje';
    await LocalNotificationService.saveNotification(title, body);
  }

  static Future<void> uploadFcmToken() async {
    try {
      // On iOS, FCM requires an APNS token first.
      // Simulators do not support APNS so we skip gracefully.
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken;
        for (int attempt = 1; attempt <= 6; attempt++) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null) break;
          debugPrint('Waiting for APNS token (attempt $attempt/6)...');
          await Future.delayed(const Duration(milliseconds: 1000));
        }

        if (apnsToken != null) {
          debugPrint('APNS token obtained: $apnsToken. Proceeding to fetch FCM token.');
        } else {
          debugPrint('APNS token check timed out, proceeding to fetch FCM token anyway.');
        }
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('FCM Token obtained: $token. Uploading to backend...');
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('Error uploading FCM token: $e');
    }
  }

  static Future<void> deleteFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('No FCM token found to delete.');
        return;
      }

      const String mutation = r'''
        mutation DeleteFcmToken($fcmToken: String!) {
          deleteFcmToken(fcmToken: $fcmToken) {
            success
          }
        }
      ''';

      final client = di.sl<GraphQLService>().client;
      final options = MutationOptions(
        document: gql(mutation),
        variables: {'fcmToken': token},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await client.mutate(options);
      if (result.hasException) {
        debugPrint('Failed to delete FCM token: ${result.exception.toString()}');
      } else {
        debugPrint('FCM Token deleted successfully from backend.');
      }
    } catch (e) {
      debugPrint('Error calling deleteFcmToken mutation: $e');
    }
  }

  static Future<void> _sendTokenToBackend(String fcmToken) async {
    const String mutation = r'''
      mutation UpdateFcmToken($fcmToken: String!) {
        updateFcmToken(fcmToken: $fcmToken) {
          success
        }
      }
    ''';

    try {
      final client = di.sl<GraphQLService>().client;
      final options = MutationOptions(
        document: gql(mutation),
        variables: {'fcmToken': fcmToken},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await client.mutate(options);
      if (result.hasException) {
        debugPrint('Failed to upload FCM token: ${result.exception.toString()}');
      } else {
        debugPrint('FCM Token uploaded successfully.');
      }
    } catch (e) {
      debugPrint('Error calling updateFcmToken mutation: $e');
    }
  }
}

