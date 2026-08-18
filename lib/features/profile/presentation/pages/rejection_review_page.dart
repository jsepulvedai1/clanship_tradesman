import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/core/utils/image_cropper_helper.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';

import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_event.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_state.dart';

class RejectionReviewPage extends StatelessWidget {
  const RejectionReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ProfileBloc>()..add(LoadProfileData()),
      child: const RejectionReviewPageView(),
    );
  }
}

class RejectionReviewPageView extends StatefulWidget {
  const RejectionReviewPageView({super.key});

  @override
  State<RejectionReviewPageView> createState() => _RejectionReviewPageViewState();
}

class _RejectionReviewPageViewState extends State<RejectionReviewPageView> {
  String? _newCedulaFrontPath;
  String? _newCedulaBackPath;
  final Map<String, String> _newReplacements = {}; // docId: newFilePath
  bool _isSubmitting = false;

  ProfessionalDocumentEntity? _getFrontDoc(List<ProfessionalDocumentEntity> docs) {
    for (final doc in docs) {
      final n = doc.name.toLowerCase();
      if (n.contains('frontal')) return doc;
    }
    return null;
  }

  ProfessionalDocumentEntity? _getBackDoc(List<ProfessionalDocumentEntity> docs) {
    for (final doc in docs) {
      final n = doc.name.toLowerCase();
      if (n.contains('posterior') || n.contains('trasera')) return doc;
    }
    return null;
  }

  List<ProfessionalDocumentEntity> _getOtherDocs(List<ProfessionalDocumentEntity> docs) {
    final front = _getFrontDoc(docs);
    final back = _getBackDoc(docs);
    return docs.where((d) => d.id != front?.id && d.id != back?.id).toList();
  }

  bool get _hasChanges =>
      _newCedulaFrontPath != null ||
      _newCedulaBackPath != null ||
      _newReplacements.isNotEmpty;

  Future<ImageSource?> _showSourceSheet() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Seleccionar Foto del Documento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(Icons.camera_alt_rounded, color: AppColors.primaryBlue),
                  ),
                  title: const Text('Tomar Foto con la Cámara'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(Icons.photo_library_rounded, color: AppColors.primaryBlue),
                  ),
                  title: const Text('Elegir de la Galería'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto({
    required Function(String path) onSelected,
  }) async {
    final source = await _showSourceSheet();
    if (source == null) return;

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 75,
      );

      if (image != null) {
        final croppedPath = await ImageCropperHelper.cropImage(
          imagePath: image.path,
          isSquare: false,
        );
        if (croppedPath != null && mounted) {
          setState(() {
            onSelected(croppedPath);
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo procesar la imagen seleccionada.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _submitReview(UserEntity user) async {
    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor actualiza al menos una foto antes de enviar a revisión.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final repo = di.sl<ProfileRepository>();
    String? errorMessage;
    final frontDoc = _getFrontDoc(user.documents);
    final backDoc = _getBackDoc(user.documents);

    try {
      // 1. Cédula Frontal
      if (_newCedulaFrontPath != null) {
        final file = File(_newCedulaFrontPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final b64 = base64Encode(bytes);

          if (frontDoc != null) {
            await repo.deleteProfessionalDocument(documentId: frontDoc.id);
          }

          final res = await repo.addProfessionalDocument(
            name: 'Cédula de Identidad (Frontal)',
            fileBase64: b64,
          );
          res.fold((f) => errorMessage = f.message, (_) {});
        }
      }

      // 2. Cédula Posterior
      if (_newCedulaBackPath != null && errorMessage == null) {
        final file = File(_newCedulaBackPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final b64 = base64Encode(bytes);

          if (backDoc != null) {
            await repo.deleteProfessionalDocument(documentId: backDoc.id);
          }

          final res = await repo.addProfessionalDocument(
            name: 'Cédula de Identidad (Posterior)',
            fileBase64: b64,
          );
          res.fold((f) => errorMessage = f.message, (_) {});
        }
      }

      // 3. Otros Documentos Reemplazados
      for (final entry in _newReplacements.entries) {
        if (errorMessage != null) break;
        final docId = entry.key;
        final path = entry.value;
        final existingDoc = user.documents.firstWhere((d) => d.id == docId);

        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final b64 = base64Encode(bytes);

          await repo.deleteProfessionalDocument(documentId: docId);
          final res = await repo.addProfessionalDocument(
            name: existingDoc.name,
            fileBase64: b64,
          );
          res.fold((f) => errorMessage = f.message, (_) {});
        }
      }

      if (errorMessage != null) {
        throw Exception(errorMessage);
      }

      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          final updatedAuthUser = authState.user.copyWith(
            isValidated: false,
            verificationStatus: 'PENDING',
            rejectionReason: null,
          );
          context.read<AuthBloc>().add(ProfileUpdated(updatedAuthUser));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 ¡Documentos actualizados y enviados a revisión! Nuestro equipo evaluará tu solicitud.',
            ),
            backgroundColor: AppColors.successGreen,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar documentos: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Revisión de Documentación',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),

                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ProfileBloc>().add(LoadProfileData()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            final frontDoc = _getFrontDoc(user.documents);
            final backDoc = _getBackDoc(user.documents);
            final otherDocs = _getOtherDocs(user.documents);

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Banner de Observaciones
                      _buildGeneralAlert(user, isDark),
                      const SizedBox(height: 24),

                      const Text(
                        'Cédula de Identidad',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D2B45),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Asegúrate de que las fotos sean nítidas, legibles y con buena iluminación.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card Frontal
                      _buildDocumentItem(
                        title: 'Cédula de Identidad (Frontal)',
                        icon: Icons.badge_outlined,
                        existingDoc: frontDoc,
                        newLocalPath: _newCedulaFrontPath,
                        onPickNew: () => _pickPhoto(onSelected: (p) => _newCedulaFrontPath = p),
                        onClearNew: () => setState(() => _newCedulaFrontPath = null),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),

                      // Card Posterior
                      _buildDocumentItem(
                        title: 'Cédula de Identidad (Posterior)',
                        icon: Icons.flip_to_back_rounded,
                        existingDoc: backDoc,
                        newLocalPath: _newCedulaBackPath,
                        onPickNew: () => _pickPhoto(onSelected: (p) => _newCedulaBackPath = p),
                        onClearNew: () => setState(() => _newCedulaBackPath = null),
                        isDark: isDark,
                      ),

                      // Otros documentos observados (si existen)
                      if (otherDocs.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        const Text(
                          'Otros Documentos y Certificados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D2B45),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...otherDocs.map(
                          (doc) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildDocumentItem(
                              title: doc.name,
                              icon: Icons.description_outlined,
                              existingDoc: doc,
                              newLocalPath: _newReplacements[doc.id],
                              onPickNew: () => _pickPhoto(onSelected: (p) => _newReplacements[doc.id] = p),
                              onClearNew: () => setState(() => _newReplacements.remove(doc.id)),
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 90), // Espacio para botón inferior
                    ],
                  ),
                ),

                // Botón inferior fijo
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : () => _submitReview(user),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.send_rounded, size: 20),
                          label: Text(
                            _isSubmitting ? 'Enviando a Revisión...' : 'Enviar Documentos a Revisión',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D2B45),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildGeneralAlert(UserEntity user, bool isDark) {
    final reason = user.effectiveRejectionReason;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF450A0A).withValues(alpha: 0.4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF87171), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Observaciones del Administrador',
                style: TextStyle(
                  color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reason.isNotEmpty ? reason : 'Por favor sube fotos claras y legibles para poder validar tu cuenta.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required IconData icon,
    required ProfessionalDocumentEntity? existingDoc,
    required String? newLocalPath,
    required VoidCallback onPickNew,
    required VoidCallback onClearNew,
    required bool isDark,
  }) {
    final bool isRejected = existingDoc?.status == 'REJECTED';
    final bool isApproved = existingDoc?.status == 'APPROVED';
    final bool hasNewPhoto = newLocalPath != null;

    Color badgeColor = Colors.amber.shade800;
    Color badgeBg = Colors.amber.shade50;
    String badgeText = 'Pendiente';

    if (hasNewPhoto) {
      badgeColor = const Color(0xFF15803D);
      badgeBg = const Color(0xFFDCFCE7);
      badgeText = '✓ Nueva foto lista';
    } else if (isRejected) {
      badgeColor = const Color(0xFFB91C1C);
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = '❌ Rechazado';
    } else if (isApproved) {
      badgeColor = const Color(0xFF15803D);
      badgeBg = const Color(0xFFDCFCE7);
      badgeText = '✓ Aprobado';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasNewPhoto
              ? const Color(0xFF22C55E)
              : (isRejected ? const Color(0xFFF87171) : const Color(0xFFE2E8F0)),
          width: hasNewPhoto || isRejected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF0D2B45)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (isRejected && existingDoc?.rejectionReason != null && existingDoc!.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF450A0A).withValues(alpha: 0.3) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Motivo: ${existingDoc.rejectionReason!}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Área de Previsualización / Acción
          if (hasNewPhoto) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Image.file(
                    File(newLocalPath),
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.white),
                        onPressed: onClearNew,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onPickNew,
              icon: const Icon(Icons.camera_alt_rounded, size: 16),
              label: const Text('Cambiar por otra foto'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ] else if (existingDoc != null && existingDoc.fileUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                existingDoc.fileUrl,
                width: double.infinity,
                height: 130,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 90,
                  color: Colors.grey.shade100,
                  alignment: Alignment.center,
                  child: const Text('No se pudo cargar la vista previa', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: onPickNew,
              icon: const Icon(Icons.camera_alt_rounded, size: 16),
              label: Text(
                isRejected ? 'Tomar o Subir Nueva Foto' : 'Reemplazar Foto',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRejected ? const Color(0xFFDC2626) : AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: onPickNew,
              icon: const Icon(Icons.add_a_photo_rounded, size: 16),
              label: const Text('Tomar o Subir Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2B45),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
