import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/core/config/environment_config.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/main.dart';
import 'package:clanship_mobile_tradesman/core/network/firebase_notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseNotificationHelper.initialize();

  // Instantiate Dev Environment
  EnvConfig.instantiate(
    environment: Environment.dev,
    baseUrl: 'https://api-dev.clanship.com/graphql/', // TODO: Update with real dev URL
    websocketUrl: 'wss://api-dev.clanship.com/graphql/', // TODO: Update with real dev WS URL
  );

  await di.init();
  runApp(const AntiGravityApp());
}
