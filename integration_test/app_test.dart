import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:clanship_mobile_tradesman/main.dart' as app;

void main() {
  patrolTest(
    'app boots and shows initial screen',
    ($) async {
      // Bootstrap app
      app.main();
      
      // Esperar a que la app renderice el primer frame
      await $.pumpAndSettle();

      // Basic assertion to ensure app loaded
      expect(find.byType(MaterialApp), findsOneWidget);
    },
  );
}
