import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/chat_room_bloc.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/chat_room_event.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/chat_room_state.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_event.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_state.dart';
import '../widgets/urgent_header.dart';
import '../widgets/client_info_item.dart';
import '../widgets/reminder_box.dart';
import '../widgets/action_buttons_section.dart';
import '../../domain/entities/active_request_detail_entity.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/pages/chat_page.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/get_current_user_usecase.dart';

class ActiveRequestDetailPage extends StatefulWidget {
  final ActiveRequestDetailEntity request;

  const ActiveRequestDetailPage({super.key, required this.request});

  @override
  State<ActiveRequestDetailPage> createState() =>
      _ActiveRequestDetailPageState();
}

class _ActiveRequestDetailPageState extends State<ActiveRequestDetailPage> {
  @override
  void initState() {
    super.initState();
    if (!widget.request.isRead) {
      final intId = int.tryParse(widget.request.id) ?? 0;
      if (intId > 0) {
        di.sl<RequestsBloc>().add(MarkRequestAsReadEvent(jobId: intId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatRoomBloc>(create: (_) => di.sl<ChatRoomBloc>()),
        BlocProvider<RequestsBloc>(create: (_) => di.sl<RequestsBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChatRoomBloc, ChatRoomState>(
            listener: (context, state) {
              if (state is ChatRoomLoading) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
              } else if (state is ChatRoomSuccess) {
                Navigator.pop(context); // Close loading dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      roomId: state.roomId,
                      jobId: int.tryParse(request.id),
                      jobStatus: request.status,
                      customerName: request.clientName,
                    ),
                  ),
                );
              } else if (state is ChatRoomError) {
                Navigator.pop(context); // Close loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.message}')),
                );
              }
            },
          ),
          BlocListener<RequestsBloc, RequestsState>(
            listener: (context, state) {
              if (state is RequestsLoading) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
              } else if (state is RequestsLoaded) {
                Navigator.pop(context); // Close loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Estado de trabajo actualizado con éxito'),
                  ),
                );
                // REFRESCO SILENCIOSO DE SESION PARA DETECTAR BLOQUEO
                di.sl<GetCurrentUserUseCase>()(NoParams()).then((res) {
                  res.fold((l) => null, (user) {
                    if (context.mounted) {
                      context.read<AuthBloc>().add(UserAuthenticated(user));
                    }
                  });
                });

                Navigator.pop(context); // Close detail page
              } else if (state is RequestsError) {
                Navigator.pop(context); // Close loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.message}')),
                );
              }
            },
          ),
        ],
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: isDark
                  ? AppColors.trueBlack
                  : AppColors.pureWhite,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : AppColors.trueBlack,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    if (request.isUrgent) const UrgentHeader(),

                    const SizedBox(height: 20),

                    // Category & Instruction Section
                    const SizedBox(height: 32),

                    // Informacion del Cliente Title
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        l10n.requestClientInfo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.trueBlack,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Client Info Cards
                    ClientInfoItem(
                      icon: Icons.person_outline,
                      label: l10n.requestUserLabel,
                      value: request.clientName,
                    ),
                    ClientInfoItem(
                      icon: Icons.phone_outlined,
                      label: l10n.requestPhoneLabel,
                      value: request.clientPhone,
                    ),
                    ClientInfoItem(
                      icon: Icons.location_on_outlined,
                      label: l10n.requestAddressLabel,
                      value: request.clientAddress,
                    ),

                    if (request.status == 'CANCELLED') ...[
                      const SizedBox(height: 20),
                      _buildRejectionCard(context, request, isDark),
                    ],
                    if (request.enrichedDetails != null &&
                        request.enrichedDetails!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade900
                              : const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.amber.shade800,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.requestEnrichedDetailsTitle,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              request.enrichedDetails!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (request.additionalPhotoUrl != null &&
                                request.additionalPhotoUrl!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  request.additionalPhotoUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const SizedBox(
                                          height: 150,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 100,
                                      color: isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade300,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 40,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Action Buttons
                    ActionButtonsSection(
                      onChatTap: () {
                        context.read<ChatRoomBloc>().add(
                          GetRoomForCustomer(
                            request.customerId,
                            jobId: int.tryParse(request.id),
                          ),
                        );
                      },
                      onGoogleMapsTap: () async {
                        final address = request.clientAddress;
                        final googleMapsUrl =
                            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
                        final uri = Uri.parse(googleMapsUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No se pudo abrir Google Maps'),
                            ),
                          );
                        }
                      },
                      onWazeTap: () async {
                        final address = request.clientAddress;
                        final wazeUrl =
                            'https://waze.com/ul?q=${Uri.encodeComponent(address)}&navigate=yes';
                        final uri = Uri.parse(wazeUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No se pudo abrir Waze'),
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 10),

                    // Status progression actions
                    _buildStatusActions(context),

                    const SizedBox(height: 10),

                    // Reminder Box
                    const ReminderBox(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = widget.request.status;
    final jobIdInt = int.tryParse(widget.request.id) ?? 0;

    if (jobIdInt == 0) return const SizedBox();

    switch (status) {
      case 'REQUESTED':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRejectionDialog(context, jobIdInt),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.errorRed,
                          width: 2,
                        ),
                        foregroundColor: AppColors.errorRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Rechazar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Expanded(
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       context.read<RequestsBloc>().add(
                  //         UpdateJobStatusEvent(
                  //           jobId: jobIdInt,
                  //           newStatus: 'AGREED',
                  //         ),
                  //       );
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: AppColors.successGreen,
                  //       foregroundColor: Colors.white,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(16),
                  //       ),
                  //       padding: const EdgeInsets.symmetric(vertical: 16),
                  //     ),
                  //     // child: const Text(
                  //     //   'Aceptar',
                  //     //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  //     // ),
                  //   ),
                  //),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showScheduleDialog(context, jobIdInt),
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(l10n.requestScheduleVisit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'SCHEDULED':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade300, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Esperando que el cliente confirme la visita programada.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showScheduleDialog(context, jobIdInt),
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(l10n.requestRescheduleVisit),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 2,
                    ),
                    foregroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'AGREED':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<RequestsBloc>().add(
                      UpdateJobStatusEvent(
                        jobId: jobIdInt,
                        newStatus: 'IN_VISIT',
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Iniciar Visita',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showScheduleDialog(context, jobIdInt),
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(l10n.requestRescheduleVisit),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 2,
                    ),
                    foregroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _showRejectionDialog(context, jobIdInt),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                ),
                child: const Text(
                  'Cancelar Visita',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        );

      case 'IN_VISIT':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<RequestsBloc>().add(
                  UpdateJobStatusEvent(jobId: jobIdInt, newStatus: 'FINISHED'),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statsOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Finalizar Trabajo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        );

      default:
        return const SizedBox();
    }
  }

  Future<void> _showScheduleDialog(BuildContext context, int jobId) async {
    final l10n = AppLocalizations.of(context)!;
    final requestsBloc = context.read<RequestsBloc>();
    DateTime? selectedDate = DateTime.now();
    TimeOfDay? selectedTime = TimeOfDay.now();
    int selectedLeadMinutes = 60; // Default

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;
    selectedDate = pickedDate;

    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;
    selectedTime = pickedTime;

    if (!context.mounted) return;

    // Show warning lead minutes dialog
    final int? pickedMinutes = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempMinutes = selectedLeadMinutes;
        return AlertDialog(
          title: Text(l10n.requestScheduleLeadTitle),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.requestScheduleLeadBody),
                  const SizedBox(height: 20),
                  DropdownButton<int>(
                    value: tempMinutes,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: 15,
                        child: Text(l10n.requestSchedule15Mins),
                      ),
                      DropdownMenuItem(
                        value: 30,
                        child: Text(l10n.requestSchedule30Mins),
                      ),
                      DropdownMenuItem(
                        value: 60,
                        child: Text(l10n.requestSchedule1Hour),
                      ),
                      DropdownMenuItem(
                        value: 120,
                        child: Text(l10n.requestSchedule2Hours),
                      ),
                      DropdownMenuItem(
                        value: 180,
                        child: Text(l10n.requestSchedule3Hours),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          tempMinutes = val;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.requestCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, tempMinutes),
              child: Text(l10n.requestConfirm),
            ),
          ],
        );
      },
    );

    if (pickedMinutes == null) return;
    selectedLeadMinutes = pickedMinutes;

    final String formattedDate =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    final String formattedTime =
        "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00";

    requestsBloc.add(
      ScheduleJobVisitEvent(
        jobId: jobId,
        scheduledDate: formattedDate,
        scheduledTime: formattedTime,
        notificationLeadMinutes: selectedLeadMinutes,
      ),
    );
  }

  Widget _buildRejectionCard(
    BuildContext context,
    ActiveRequestDetailEntity request,
    bool isDark,
  ) {
    final byWho =
        request.cancelledByUserName != null &&
            request.cancelledByUserName!.isNotEmpty
        ? 'Rechazado por: ${request.cancelledByUserName}'
        : 'Trabajo Rechazado / Cancelado';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  byWho,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.red.shade300 : Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
          if (request.cancellationReason != null &&
              request.cancellationReason!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Motivo de rechazo:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.red.shade200 : Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              request.cancellationReason!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context, int jobIdInt) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar Rechazo de Solicitud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás seguro de que deseas rechazar esta solicitud? Puedes ingresar el motivo del rechazo:',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe el motivo aquí...',
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
            child: const Text('Cancelar'),
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
              context.read<RequestsBloc>().add(
                UpdateJobStatusEvent(
                  jobId: jobIdInt,
                  newStatus: 'CANCELLED',
                  cancellationReason: reason.isNotEmpty ? reason : null,
                ),
              );
            },
            child: const Text('Confirmar Rechazo'),
          ),
        ],
      ),
    );
  }
}
