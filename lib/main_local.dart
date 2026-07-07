import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/core/config/environment_config.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/main.dart';

import 'package:clanship_mobile_tradesman/core/network/firebase_notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseNotificationHelper.initialize();

  // Instantiate Local Environment
  // For Android emulator use 10.0.2.2, for iOS simulator use 127.0.0.1 or localhost
  EnvConfig.instantiate(
    environment: Environment.local,
    baseUrl: 'http://127.0.0.1:8000/graphql/', // Change depending on simulator/device
    websocketUrl: 'ws://127.0.0.1:8000/graphql/',
  );

  await di.init();
  runApp(const AntiGravityApp());
}
