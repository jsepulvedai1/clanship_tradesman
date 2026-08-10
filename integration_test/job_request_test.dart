import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:clanship_mobile_tradesman/main.dart' as app;

void main() {
  patrolTest(
    'Flujo de Solicitud de Trabajo y Completados',
    ($) async {
      app.main();
      await $.pumpAndSettle();

      // NOTA: Para esta prueba asumimos que el usuario ya está autenticado.
      // 1. Aceptar permisos de ubicación (si salta el diálogo nativo)
      // await $.native.grantPermissionWhenInUse();

      // 2. Simular recepción de un trabajo (puede requerir mock del backend o UI navigation)
      // await $('Nueva Solicitud de Trabajo').tap();
      // await $('Aceptar').tap();
      
      // 3. Validar estado del trabajo (En camino, Iniciado, Completado)
      // await $('Estoy en camino').tap();
      // await $.pumpAndSettle();
      // await $('Iniciar trabajo').tap();
      // await $.pumpAndSettle();
      // await $('Completar trabajo').tap();
      // await $.pumpAndSettle();

      // 4. Ir a la lista de trabajos completados
      // await $('Completados').tap();
      
      // 5. Validar que el subtítulo "servicio de visita técnica" ya no exista
      // expect($('servicio de visita técnica'), findsNothing);

      // 6. Validar orden de los trabajos (del más nuevo al más antiguo)
      // Esto requeriría leer las fechas de las tarjetas de trabajo y verificar el orden.
    },
  );
}
