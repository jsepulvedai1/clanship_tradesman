import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/core/config/environment_config.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/main.dart';
import 'package:clanship_mobile_tradesman/core/network/firebase_notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseNotificationHelper.initialize();

  // Instantiate Prod Environment
  EnvConfig.instantiate(
    environment: Environment.prod,
    baseUrl: 'https://api.clanship.cl/graphql/', // URL real de producción
    websocketUrl: 'wss://api.clanship.cl/graphql/', // WS real de producción
  );

  await di.init();
  runApp(const AntiGravityApp());
}
