import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/pages/documents_page.dart';
import 'package:clanship_mobile_tradesman/features/requests/data/datasources/requests_remote_data_source.dart';
import 'package:clanship_mobile_tradesman/core/network/jobs_websocket_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({super.key});

  @override
  State<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _opportunities = [];
  int _selectedTabIndex = 0; // 0 = Disponibles, 1 = Mis Cotizaciones
  StreamSubscription? _socketSubscription;

  String _formatPrice(dynamic price) {
    if (price == null) return 'A convenir';
    double? parsed;
    if (price is num) {
      parsed = price.toDouble();
    } else if (price is String) {
      parsed = double.tryParse(price);
    }
    if (parsed != null) {
      final formatter = NumberFormat.currency(
        locale: 'es_CL',
        symbol: '',
        decimalDigits: 0,
      );
      return '\$ ${formatter.format(parsed)}';
    }
    return '\$$price';
  }

  @override
  void initState() {
    super.initState();
    _fetchOpportunities();
    
    final socketService = di.sl<JobsWebSocketService>();
    _socketSubscription = socketService.stream.listen((event) {
      if (event != null && event is Map) {
        if (event['event'] == 'job_created' || event['event'] == 'job_updated') {
          if (mounted) {
            _fetchOpportunities();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchOpportunities() async {
    setState(() => _isLoading = true);
    try {
      final dataSource = di.sl<RequestsRemoteDataSource>();
      final list = await dataSource.getOpenPublicJobRequests();
      if (mounted) {
        setState(() {
          _opportunities = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSentProposalDialog(Map<String, dynamic> req) {
    final myProp = req['myProposal'] ?? {};
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Tu Cotización Enviada',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trabajo: ${req['title'] ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Precio Cotizado: ${_formatPrice(myProp['estimatedPrice'] ?? req['budget'] ?? 0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Fecha Sugerida: ${myProp['scheduledDate'] ?? ''} - ${myProp['scheduledTime'] ?? ''}',
            ),
            if (myProp['message'] != null &&
                myProp['message'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Mensaje: "${myProp['message']}"',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: myProp['status'] == 'ACCEPTED'
                    ? Colors.green.shade100
                    : Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                myProp['status'] == 'ACCEPTED'
                    ? '✓ ACEPTADA POR EL CLIENTE'
                    : '⌛ Pendiente de respuesta del cliente',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: myProp['status'] == 'ACCEPTED'
                      ? Colors.green.shade800
                      : Colors.amber.shade900,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showProposalDialog(Map<String, dynamic> req) {
    final priceController = TextEditingController(
      text: req['budget']?.toString() ?? '',
    );
    final messageController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cotizar Trabajo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Solicitud: ${req['title']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Precio Estimado de Visita / Trabajo (\$) *',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        hintText: 'Ej. 25000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fecha Sugerida *',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: ctx,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 30),
                                    ),
                                  );
                                  if (picked != null) {
                                    setModalState(() => selectedDate = picked);
                                  }
                                },
                                icon: const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  DateFormat('dd/MM/yyyy').format(selectedDate),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hora Sugerida *',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: ctx,
                                    initialTime: selectedTime,
                                  );
                                  if (picked != null) {
                                    setModalState(() => selectedTime = picked);
                                  }
                                },
                                icon: const Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                ),
                                label: Text(selectedTime.format(ctx)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mensaje / Nota para el Cliente',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'Ej. Hola, cuento con disponibilidad y experiencia para resolver este problema rápidamente.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final double? price = double.tryParse(
                            priceController.text.trim(),
                          );
                          if (price == null || price <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ingresa un precio válido.'),
                              ),
                            );
                            return;
                          }

                          final reqId = int.tryParse(req['id'].toString()) ?? 0;
                          final timeStr =
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';
                          final dateStr = DateFormat(
                            'yyyy-MM-dd',
                          ).format(selectedDate);

                          Navigator.pop(ctx);

                          try {
                            final dataSource = di
                                .sl<RequestsRemoteDataSource>();
                            final ok = await dataSource.submitJobProposal(
                              publicRequestId: reqId,
                              estimatedPrice: price,
                              scheduledDate: dateStr,
                              scheduledTime: timeStr,
                              message: messageController.text.trim(),
                            );

                            if (mounted && ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '¡Cotización enviada exitosamente al cliente!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _fetchOpportunities();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Enviar Propuesta al Cliente',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    bool isValidated = true;
    if (authState is AuthAuthenticated) {
      isValidated = authState.user.isValidated;
    }

    if (!isValidated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Requerimientos específicos'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_clock_rounded,
                    size: 54,
                    color: Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'En Proceso de Validación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tu perfil profesional se encuentra en proceso de revisión por nuestro equipo. Una vez validado tu registro, podrás explorar y enviar cotizaciones a los requerimientos específicos de clientes en tu zona.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DocumentsPage()),
                    );
                  },
                  icon: const Icon(Icons.description_outlined),
                  label: const Text(
                    'Ver mis Documentos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filteredList = _selectedTabIndex == 0
        ? _opportunities
        : _opportunities
              .where((req) => req['hasSubmittedProposal'] == true)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Requerimientos especificos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchOpportunities,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Center(
                      child: Text('Disponibles (${_opportunities.length})'),
                    ),
                    selected: _selectedTabIndex == 0,
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(
                      color: _selectedTabIndex == 0
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedTabIndex = 0);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Center(
                      child: Text(
                        'Mis Cotizaciones (${_opportunities.where((r) => r['hasSubmittedProposal'] == true).length})',
                      ),
                    ),
                    selected: _selectedTabIndex == 1,
                    selectedColor: Colors.green.shade700,
                    labelStyle: TextStyle(
                      color: _selectedTabIndex == 1
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedTabIndex = 1);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _fetchOpportunities,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final req = filteredList[index];
                        final isUrgent = req['isUrgent'] == true;
                        final proposalsCount = req['proposalsCount'] ?? 0;
                        final hasSubmitted =
                            req['hasSubmittedProposal'] == true;
                        final myProp = req['myProposal'] ?? {};

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isUrgent
                                            ? Colors.red.withValues(alpha: 0.15)
                                            : AppColors.primaryBlue.withValues(
                                                alpha: 0.15,
                                              ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isUrgent
                                            ? '🚨 URGENTE'
                                            : (req['specialtyName'] ??
                                                  'General'),
                                        style: TextStyle(
                                          color: isUrgent
                                              ? Colors.red
                                              : AppColors.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    if (hasSubmitted) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          '✓ Cotizado',
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    Text(
                                      '$proposalsCount/5 ofertas',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  req['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  req['description'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      req['customerName'] ?? 'Cliente',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        req['address'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Presupuesto cliente:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          req['budget'] != null
                                              ? _formatPrice(req['budget'])
                                              : 'A convenir',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: hasSubmitted
                                            ? Colors.green.shade700
                                            : AppColors.primaryBlue,
                                        foregroundColor: Colors.white,
                                        minimumSize: Size.zero,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (hasSubmitted) {
                                          _showSentProposalDialog(req);
                                        } else {
                                          _showProposalDialog(req);
                                        }
                                      },
                                      icon: Icon(
                                        hasSubmitted
                                            ? Icons.check_circle_rounded
                                            : Icons.send_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        hasSubmitted
                                            ? '✓ Cotizado (\$${myProp['estimatedPrice'] ?? ''})'
                                            : 'Cotizar',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _selectedTabIndex == 0
                ? 'No hay solicitudes abiertas disponibles por ahora'
                : 'Aún no has enviado cotizaciones a trabajos abiertos',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
