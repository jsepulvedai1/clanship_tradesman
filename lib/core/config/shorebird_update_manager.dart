import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:restart_app/restart_app.dart';

class ShorebirdUpdateManager {
  static final _shorebirdCodePush = ShorebirdCodePush();
  static bool _isChecking = false;

  /// Verifica si hay actualizaciones en Shorebird.
  /// Puedes llamar a este método desde el Splash, al reanudar la app,
  /// o cuando recibes un evento del backend.
  static Future<void> checkForUpdate(BuildContext context) async {
    if (_isChecking) return;
    
    try {
      _isChecking = true;
      final isUpdateAvailable =
          await _shorebirdCodePush.isNewPatchAvailableForDownload();

      if (isUpdateAvailable && context.mounted) {
        _showUpdateDialog(context);
      }
    } catch (e) {
      debugPrint('Error checking for shorebird update: $e');
    } finally {
      _isChecking = false;
    }
  }

  static void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Obligatorio
      builder: (context) {
        bool isDownloading = false;
        bool isReady = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Actualización disponible'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isDownloading && !isReady)
                    const Text(
                        'Hemos lanzado mejoras importantes para la aplicación. Por favor, actualiza para continuar.'),
                  if (isDownloading) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Descargando actualización...'),
                  ],
                  if (isReady)
                    const Text(
                        '¡Actualización lista! Reinicia la aplicación para aplicar los cambios.'),
                ],
              ),
              actions: [
                if (!isDownloading && !isReady)
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        isDownloading = true;
                      });

                      try {
                        await _shorebirdCodePush.downloadUpdateIfAvailable();
                        setState(() {
                          isDownloading = false;
                          isReady = true;
                        });
                      } catch (e) {
                        setState(() {
                          isDownloading = false;
                        });
                      }
                    },
                    child: const Text('Descargar ahora'),
                  ),
                if (isReady)
                  TextButton(
                    onPressed: () {
                      // Intenta reiniciar la app automáticamente
                      Restart.restartApp();
                    },
                    child: const Text('Reiniciar aplicación'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
