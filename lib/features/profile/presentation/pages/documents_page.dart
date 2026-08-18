import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';
import 'rejection_review_page.dart';
import '../bloc/profile_bloc.dart';

import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>()..add(LoadProfileData()),
      child: const DocumentsPageView(),
    );
  }
}

class DocumentsPageView extends StatefulWidget {
  const DocumentsPageView({super.key});

  @override
  State<DocumentsPageView> createState() => _DocumentsPageViewState();
}

class _DocumentsPageViewState extends State<DocumentsPageView> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddDocumentDialog(BuildContext context) {
    _nameController.clear();
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: Text(
            l10n.docsAddTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.docsAddInputLabel,
                    hintText: l10n.docsAddInputHint,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sugerencias rápidas:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    'Cédula de Identidad (Frontal)',
                    'Cédula de Identidad (Posterior)',
                    'Certificado de Antecedentes',
                    'Certificado de Título / Oficio',
                  ].map((sug) => ActionChip(
                    label: Text(sug, style: const TextStyle(fontSize: 11)),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    onPressed: () {
                      _nameController.text = sug;
                    },
                  )).toList(),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.docsAddNameError)),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                await _pickAndUploadDocument(context, name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.authNext),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadDocument(BuildContext context, String name) async {
    final picker = ImagePicker();
    // Cap size of uploaded document image
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (pickedFile != null && context.mounted) {
      context.read<ProfileBloc>().add(
            AddProfessionalDocumentEvent(
              name: name,
              filePath: pickedFile.path,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.trueBlack : AppColors.cardLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.trueBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            final docs = user.documents;

            return Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          l10n.docsTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.docsSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white70 : Colors.black45,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (user.isRejected) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF450A0A).withValues(alpha: 0.35)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF87171), width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Color(0xFFDC2626),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Atención: Documentación Observada',
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFFFCA5A5)
                                            : const Color(0xFF991B1B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  user.effectiveRejectionReason,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const RejectionReviewPage()),
                                    );
                                    if (res == true && context.mounted) {
                                      context.read<ProfileBloc>().add(LoadProfileData());
                                    }
                                  },
                                  icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                                  label: const Text(
                                    'Resolver Observaciones y Reenviar',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDC2626),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (docs.isEmpty)

                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Aún no has agregado ningún documento o certificado.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              return _DocumentCard(
                                document: doc,
                                isDark: isDark,
                                onVisibilityChanged: (value) {
                                  context.read<ProfileBloc>().add(
                                        ToggleDocumentVisibilityEvent(
                                          documentId: doc.id,
                                          isVisible: value,
                                        ),
                                      );
                                },
                                onDelete: () {
                                  _confirmDelete(context, doc);
                                },
                              );
                            },
                          ),
                        const SizedBox(height: 32),
                        _AddDocumentButton(
                          onTap: () => _showAddDocumentDialog(context),
                          title: l10n.docsAdd,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.docsFooter,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                if (state.isDocumentUploading || state.isDocumentDeleting || state.isUpdating)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProfessionalDocumentEntity doc) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: const Text('Eliminar Documento'),
          content: Text('¿Estás seguro de que deseas eliminar "${doc.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ProfileBloc>().add(DeleteProfessionalDocumentEvent(doc.id));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final ProfessionalDocumentEntity document;
  final bool isDark;
  final ValueChanged<bool> onVisibilityChanged;
  final VoidCallback onDelete;

  const _DocumentCard({
    required this.document,
    required this.isDark,
    required this.onVisibilityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (document.status) {
      case 'APPROVED':
        statusColor = AppColors.successGreen;
        statusText = l10n.docsStatusApproved;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'REJECTED':
        statusColor = Colors.redAccent;
        statusText = l10n.docsStatusRejected;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = Colors.amber;
        statusText = l10n.docsStatusPending;
        statusIcon = Icons.watch_later_rounded;
    }

    final displayName = _getLocalizedDocumentName(document.name, l10n);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.trueBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (document.status == 'REJECTED' && document.rejectionReason != null && document.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.docsRejectionReason(document.rejectionReason!),
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
          ],
          const Divider(height: 24, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.docsVisiblePublicProfile,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 14,
                ),
              ),
              Switch(
                value: document.isVisible,
                onChanged: onVisibilityChanged,
                activeColor: Colors.white,
                activeTrackColor: AppColors.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLocalizedDocumentName(String name, AppLocalizations l10n) {
    final trimmed = name.trim();
    if (trimmed == 'Cédula de Identidad (Frontal)' || trimmed == 'Cedula de Identidad (Frontal)') {
      return l10n.docsIdCardFront;
    }
    if (trimmed == 'Cédula de Identidad (Posterior)' || trimmed == 'Cedula de Identidad (Posterior)') {
      return l10n.docsIdCardBack;
    }
    if (trimmed == 'Cédula de Identidad' || trimmed == 'Cedula de Identidad') {
      return l10n.docsIdCard;
    }
    if (trimmed == 'Licencia de Conducir') {
      return l10n.docsDriverLicense;
    }
    return name;
  }
}

class _AddDocumentButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final bool isDark;

  const _AddDocumentButton({
    required this.onTap,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRectPainter(
          color: isDark ? Colors.white30 : Colors.black26,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  static const double strokeWidth = 1.5;
  static const double dashWidth = 5;
  static const double dashSpace = 5;

  _DashedRectPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final Path dashedPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
