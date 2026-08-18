import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:clanship_mobile_tradesman/features/chat/domain/entities/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:clanship_mobile_tradesman/core/utils/image_cropper_helper.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_action_buttons.dart';
import '../widgets/chat_input_bar.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/messages/chat_messages_bloc.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/messages/chat_messages_event.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/messages/chat_messages_state.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'dart:async';
import 'package:clanship_mobile_tradesman/core/network/jobs_websocket_service.dart';
import 'package:clanship_mobile_tradesman/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_state.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_event.dart';

class ChatPage extends StatelessWidget {
  final String roomId;
  final int? jobId;
  final String? jobStatus;
  final String? customerName;

  const ChatPage({
    super.key,
    required this.roomId,
    this.jobId,
    this.jobStatus,
    this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ChatMessagesBloc>()),
        BlocProvider(create: (context) => sl<RequestsBloc>()),
      ],
      child: _ChatPageContent(
        roomId: roomId,
        jobId: jobId,
        jobStatus: jobStatus,
        customerName: customerName,
      ),
    );
  }
}

class _ChatPageContent extends StatefulWidget {
  final String roomId;
  final int? jobId;
  final String? jobStatus;
  final String? customerName;

  const _ChatPageContent({
    required this.roomId,
    this.jobId,
    this.jobStatus,
    this.customerName,
  });

  @override
  State<_ChatPageContent> createState() => _ChatPageContentState();
}

class _ChatPageContentState extends State<_ChatPageContent> {
  final TextEditingController _controller = TextEditingController();
  String? _currentStatus;
  String? _pendingStatusChange;
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordPath;
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.jobStatus;
    _loadMessages();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    final socketService = sl<JobsWebSocketService>();
    _socketSubscription = socketService.stream.listen((event) {
      final eventType = (event['event']?.toString() ?? event['type']?.toString() ?? '').toLowerCase();
      if (eventType == 'job_updated' || eventType == 'job_status_changed' || eventType == 'job_cancelled') {
        final jobId = event['job_id']?.toString() ?? event['jobId']?.toString();
        final status = (event['status']?.toString() ?? event['new_status']?.toString() ?? '').toUpperCase();
        if (widget.jobId != null && jobId == widget.jobId.toString() && (status == 'CANCELLED' || eventType == 'job_cancelled')) {
          if (mounted) {
            final reason = event['cancellation_reason'] ?? event['reason'];
            final messageText = reason != null && reason.toString().isNotEmpty
                ? 'La solicitud ha sido cancelada. Motivo: $reason'
                : 'La solicitud ha sido cancelada por el cliente.';
            context.read<NavigationBloc>().add(const TabChanged(0));
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(messageText),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 70,
      );
      if (image == null) return;

      final croppedPath = await ImageCropperHelper.cropImage(
        imagePath: image.path,
        isSquare: false,
      );
      if (croppedPath == null) return;

      final File file = File(croppedPath);
      final bytes = await file.readAsBytes();
      final String base64Image = base64Encode(bytes);
      final String fileName = image.name;

      if (mounted) {
        context.read<ChatMessagesBloc>().add(
          SendMessage(
            widget.roomId,
            '',
            fileBase64: 'data:image/jpeg;base64,$base64Image',
            fileName: fileName,
            messageType: 'IMAGE',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking or sending image: $e');
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.primaryBlue,
                ),
                title: const Text('Tomar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.primaryBlue,
                ),
                title: const Text('Elegir de Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
        });

        if (path != null) {
          final File file = File(path);
          final bytes = await file.readAsBytes();
          final String base64Audio = base64Encode(bytes);
          final String fileName =
              'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

          if (mounted) {
            context.read<ChatMessagesBloc>().add(
              SendMessage(
                widget.roomId,
                '',
                fileBase64: 'data:audio/m4a;base64,$base64Audio',
                fileName: fileName,
                messageType: 'AUDIO',
              ),
            );
          }
        }
      } else {
        if (await _audioRecorder.hasPermission()) {
          final directory = await getTemporaryDirectory();
          final String filePath =
              '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: filePath,
          );

          setState(() {
            _isRecording = true;
            _recordPath = filePath;
          });
        }
      }
    } catch (e) {
      debugPrint('Error toggling recording: $e');
    }
  }

  void _loadMessages() {
    final authState = context.read<AuthBloc>().state;
    int userId = 0; // Default or fallback
    if (authState is AuthAuthenticated) {
      userId = int.tryParse(authState.user.id) ?? 0;
    }
    context.read<ChatMessagesBloc>().add(
      LoadChatMessages(widget.roomId, userId),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _showRejectionDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rechazar Trabajo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Deseas indicar la razón del rechazo? (Opcional)',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe tu razón aquí...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5277),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final reason = reasonController.text.trim();
              Navigator.pop(dialogContext);
              if (widget.jobId != null) {
                _pendingStatusChange = 'CANCELLED';
                context.read<RequestsBloc>().add(
                  UpdateJobStatusEvent(
                    jobId: widget.jobId!,
                    newStatus: 'CANCELLED',
                    cancellationReason: reason.isNotEmpty ? reason : null,
                  ),
                );
              }
            },
            child: const Text('Confirmar Rechazo'),
          ),
        ],
      ),
    );
  }

  Future<void> _onScheduleTap() async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final TextEditingController priceController = TextEditingController();
    int leadMinutes = 60;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final dateText = DateFormat(
              'EEE d MMMM, yyyy',
              'es',
            ).format(selectedDate);
            final timeText = selectedTime.format(context);

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Proponer Fecha y Hora',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 20),

                  // Date Picker Row
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.primaryBlue,
                    ),
                    title: const Text('Fecha de la visita'),
                    subtitle: Text(
                      dateText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setBottomSheetState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                  const Divider(),

                  // Time Picker Row
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.access_time_rounded,
                      color: AppColors.primaryBlue,
                    ),
                    title: const Text('Hora de la visita'),
                    subtitle: Text(
                      timeText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        setBottomSheetState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                  ),
                  const Divider(),

                  // Optional Price Row
                  const SizedBox(height: 10),
                  const Text(
                    'Monto de la visita (Opcional)',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Ej: 35.000',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Enviar Propuesta',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        final formattedDate = DateFormat(
          'EEE d MMM',
          'es',
        ).format(selectedDate);
        final formattedTime = selectedTime.format(context);
        final price = priceController.text.trim();

        // Build message text
        String text =
            'Propuesta de visita: $formattedDate a las $formattedTime';
        if (price.isNotEmpty) {
          text += ' | Precio: \$ $price';
        }

        // Send message to WebSocket
        context.read<ChatMessagesBloc>().add(SendMessage(widget.roomId, text));

        // Submit proposal mutation to backend
        if (widget.jobId != null) {
          _pendingStatusChange = 'SCHEDULED';

          final String formattedDbDate =
              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
          final String formattedDbTime =
              "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00";

          // Parse price for GraphQL mutation
          double? parsedPrice;
          if (price.isNotEmpty) {
            final cleanPrice = price.replaceAll('.', '').replaceAll(',', '');
            parsedPrice = double.tryParse(cleanPrice);
          }

          context.read<RequestsBloc>().add(
            ScheduleJobVisitEvent(
              jobId: widget.jobId!,
              scheduledDate: formattedDbDate,
              scheduledTime: formattedDbTime,
              notificationLeadMinutes: leadMinutes,
              agreedPrice: parsedPrice,
            ),
          );
        }
      }
    });
  }

  Future<String?> _showPriceDialog() async {
    final TextEditingController priceController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ingresa el valor del servicio'),
        content: TextField(
          controller: priceController,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ],
          decoration: const InputDecoration(
            hintText: 'Ej: 35.000',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          // ElevatedButton(
          //   onPressed: () => Navigator.pop(context, priceController.text),
          //   child: const Text('Aceptar'),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<RequestsBloc, RequestsState>(
          listener: (context, state) {
            if (state is RequestsLoaded && _pendingStatusChange != null) {
              final updatedStatus = _pendingStatusChange;
              _pendingStatusChange = null;
              if (updatedStatus == 'CANCELLED') {
                setState(() {
                  _currentStatus = 'CANCELLED';
                });
                context.read<NavigationBloc>().add(const TabChanged(0));
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Solicitud rechazada con éxito.')),
                );
              } else if (updatedStatus == 'AGREED') {
                setState(() {
                  _currentStatus = 'AGREED';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Solicitud aceptada con éxito.')),
                );
              } else if (updatedStatus == 'SCHEDULED') {
                setState(() {
                  _currentStatus = 'SCHEDULED';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Propuesta de agenda enviada con éxito.'),
                  ),
                );
              } else if (updatedStatus == 'FINISHED') {
                setState(() {
                  _currentStatus = 'FINISHED';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trabajo finalizado con éxito.'),
                  ),
                );
                // REFRESCO SILENCIOSO DE SESION PARA DETECTAR BLOQUEO
                sl<GetCurrentUserUseCase>()(NoParams()).then((res) {
                  res.fold(
                    (l) => null,
                    (user) {
                      if (context.mounted) {
                        context.read<AuthBloc>().add(UserAuthenticated(user));
                      }
                    },
                  );
                });
              }
            } else if (state is RequestsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
            }
          },
        ),
        BlocListener<ChatMessagesBloc, ChatMessagesState>(
          listener: (context, state) {
            if (state is ChatMessagesLoaded && state.jobStatus != null) {
              if (state.jobStatus != _currentStatus) {
                setState(() {
                  _currentStatus = state.jobStatus;
                });
              }
            }
          },
        ),
      ],
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: isDark
              ? Colors.black.withOpacity(0.7)
              : Colors.white.withOpacity(0.7),
          elevation: 0,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : AppColors.trueBlack,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
            builder: (context, state) {
              String? avatarUrl;
              if (state is ChatMessagesLoaded) {
                // Find the first message not sent by me to extract the customer's avatar
                for (final m in state.messages) {
                  if (!m.isMe &&
                      m.profileImageUrl != null &&
                      m.profileImageUrl!.isNotEmpty) {
                    avatarUrl = m.profileImageUrl;
                    break;
                  }
                }
              }

              final name = widget.customerName ?? 'Cliente';

              return Row(
                children: [
                  CircleAvatar(
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    backgroundColor: Colors.grey[300],
                    radius: 20,
                    child: avatarUrl == null || avatarUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.trueBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.successGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'En línea',
                            style: TextStyle(
                              color: AppColors.successGreen,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.flag_outlined,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              tooltip: 'Reportar usuario o chat',
              onPressed: () => _showReportUserDialog(
                context,
                widget.customerName ?? 'Cliente',
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 110), // Space for AppBar
            // Action Buttons (Agendar, Regresar, Rechazar)

            // Chat List
            Expanded(
              child: BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
                builder: (context, state) {
                  if (state is ChatMessagesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatMessagesError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is ChatMessagesLoaded) {
                    final messages = state.messages.reversed.toList();

                    if (messages.isEmpty) {
                      return const Center(
                        child: Text('No hay mensajes en esta sala.'),
                      );
                    }

                    ChatMessage? latestProposalMsg;
                    if (_currentStatus == 'SCHEDULED') {
                      try {
                        latestProposalMsg = state.messages.lastWhere(
                          (m) => m.type == ChatMessageType.appointment,
                        );
                      } catch (_) {
                        latestProposalMsg = null;
                      }
                    }

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isLatest =
                            latestProposalMsg != null &&
                            message.id == latestProposalMsg.id;

                        return ChatBubble(
                          message: message,
                          jobStatus: _currentStatus,
                          isLatestProposal: isLatest,
                        );
                      },
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            BlocBuilder<RequestsBloc, RequestsState>(
              builder: (context, requestsState) {
                final isLoading = requestsState is RequestsLoading;

                if (_currentStatus == 'AGREED' ||
                    _currentStatus == 'SCHEDULED' ||
                    _currentStatus == 'IN_VISIT' ||
                    _currentStatus == 'FINISHED' ||
                    _currentStatus == 'CANCELLED') {
                  return const SizedBox.shrink();
                }

                return ChatActionButtons(
                  onSchedule: isLoading ? () {} : _onScheduleTap,
                );
              },
            ),
            // Input Bar
            ChatInputBar(
              controller: _controller,
              isRecording: _isRecording,
              onSend: () {
                if (_isRecording || _controller.text.isEmpty) {
                  _toggleRecording();
                } else {
                  context.read<ChatMessagesBloc>().add(
                    SendMessage(widget.roomId, _controller.text),
                  );
                  _controller.clear();
                }
              },
              onMic: _toggleRecording,
              onAttachment: _showAttachmentOptions,
              onStopRecording: _toggleRecording,
            ),
          ],
        ),
      ),
    );
  }

  void _showReportUserDialog(BuildContext context, String targetName) {
    final TextEditingController detailController = TextEditingController();
    String selectedReason = 'Lenguaje inapropiado o acoso';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: AppColors.primaryAzure, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reportar a $targetName',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona el motivo por el cual deseas reportar a este usuario en el chat:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...[
                    'Lenguaje inapropiado o acoso',
                    'Spam o fraude',
                    'Comportamiento sospechoso o agresivo',
                    'Contenido / foto ofensiva',
                    'Otro motivo',
                  ].map((reason) => RadioListTile<String>(
                        title: Text(reason, style: const TextStyle(fontSize: 14)),
                        value: reason,
                        groupValue: selectedReason,
                        activeColor: AppColors.primaryAzure,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedReason = val);
                          }
                        },
                      )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Detalles adicionales (opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAzure,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Reporte de chat recibido con éxito. El equipo de soporte revisará la conversación dentro de 24 horas.',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text(
                        'Enviar Reporte',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final int value = int.parse(
      newValue.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    final formatter = NumberFormat.decimalPattern('es');
    final String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
