import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/core/network/graphql_service.dart';
import 'package:clanship_mobile_tradesman/firebase_options.dart';

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
      });

      // Handle background/terminated state messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Error initializing Firebase Push Notifications: $e');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Background message received: ${message.messageId}');
  }

  static Future<void> uploadFcmToken() async {
    try {
      // On iOS, FCM requires an APNS token first.
      // Simulators do not support APNS so we skip gracefully.
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Wait for APNS token with retries (needed on real devices after cold start)
        String? apnsToken;
        for (int attempt = 1; attempt <= 5; attempt++) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null) break;
          debugPrint('Waiting for APNS token (attempt $attempt/5)...');
          await Future.delayed(const Duration(seconds: 2));
        }

        if (apnsToken == null) {
          // This is expected on iOS simulators — not a real error.
          debugPrint('APNS token unavailable (likely running on simulator). Skipping FCM token upload.');
          return;
        }

        debugPrint('APNS token obtained. Proceeding to fetch FCM token.');
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('FCM Token obtained. Uploading to backend...');
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('Error uploading FCM token: $e');
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
