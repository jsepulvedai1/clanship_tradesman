import 'package:clanship_mobile_tradesman/features/requests/utils/pdf_generator.dart';
import 'package:clanship_mobile_tradesman/features/navigation/presentation/bloc/navigation_bloc.dart';

import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/pages/documents_page.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/pages/rejection_review_page.dart';
import 'package:clanship_mobile_tradesman/features/requests/data/datasources/requests_remote_data_source.dart';

import 'package:clanship_mobile_tradesman/core/network/jobs_websocket_service.dart';
import 'dart:async';
import 'package:clanship_mobile_tradesman/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
    return formatCurrency(price, defaultValue: 'A convenir');
  }

  @override
  void initState() {
    super.initState();
    _fetchOpportunities();
    
    final socketService = di.sl<JobsWebSocketService>();
    _socketSubscription = socketService.stream.listen((event) {
      final ev = (event['event']?.toString() ?? event['type']?.toString() ?? '').toLowerCase();
      if (ev == 'job_created' || ev == 'job_updated' || ev == 'job_status_changed') {
        if (mounted) {
          _fetchOpportunities();
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
    final messageController = TextEditingController();

    // Reemplazamos los controladores antiguos por una lista de items dinámica
    List<Map<String, TextEditingController>> quoteItems = [
      {
        'desc': TextEditingController(),
        'qty': TextEditingController(text: '1'),
        'price': TextEditingController(
          text: req['budget'] != null ? formatCurrency(req['budget'], includeSymbol: false) : '',
        ),
      }
    ];

    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    if (req['desiredDate'] != null) {
      try {
        selectedDate = DateTime.parse(req['desiredDate'].toString());
      } catch (e) {
        // Ignorar error de parseo y mantener default
      }
    }
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    List<File> attachedFiles = [];
    final ImagePicker picker = ImagePicker();
    bool isSubmitting = false;

    List<String> quickReplies = [
      'Tengo disponibilidad inmediata hoy.',
      'Me gustaría hacer una visita técnica primero.',
      'Cuento con amplia experiencia en esto.',
    ];

    double getTotalPrice() {
      double total = 0;
      for (var item in quoteItems) {
        final q = double.tryParse(item['qty']!.text) ?? 1.0;
        final p = double.tryParse(item['price']!.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
        total += (q * p);
      }
      return total;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final currentTotal = getTotalPrice();
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.92,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cotización Automática (PDF)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Al enviar, se generará y adjuntará un PDF profesional automáticamente.',
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // SECCIÓN 1: DETALLE DE VALORES
                          const Text(
                            '1. Detalle de Valores',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: quoteItems.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = quoteItems[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: item['desc'],
                                      decoration: InputDecoration(
                                        labelText: 'Concepto',
                                        isDense: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      controller: item['qty'],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Cant.',
                                        isDense: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onChanged: (_) => setModalState((){}),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: item['price'],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [CurrencyInputFormatter()],
                                      decoration: InputDecoration(
                                        labelText: 'Precio',
                                        isDense: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onChanged: (_) => setModalState((){}),
                                    ),
                                  ),
                                  if (quoteItems.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        setModalState(() {
                                          quoteItems.removeAt(index);
                                        });
                                      },
                                    ),
                                ],
                              );
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                setModalState(() {
                                  quoteItems.add({
                                    'desc': TextEditingController(),
                                    'qty': TextEditingController(text: '1'),
                                    'price': TextEditingController(),
                                  });
                                });
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Agregar ítem'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Calculado:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(
                                  _formatPrice(currentTotal),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade800),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 32),

                          // SECCIÓN 2: FECHA Y HORA
                          const Text(
                            '2. Disponibilidad Sugerida',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
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
                                        const Duration(days: 60),
                                      ),
                                    );
                                    if (picked != null)
                                      setModalState(
                                        () => selectedDate = picked,
                                      );
                                  },
                                  icon: const Icon(
                                    Icons.calendar_month,
                                    size: 18,
                                  ),
                                  label: Text(
                                    DateFormat('dd MMM').format(selectedDate),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final picked = await showTimePicker(
                                      context: ctx,
                                      initialTime: selectedTime,
                                    );
                                    if (picked != null)
                                      setModalState(
                                        () => selectedTime = picked,
                                      );
                                  },
                                  icon: const Icon(Icons.access_time, size: 18),
                                  label: Text(selectedTime.format(context)),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 32),

                          // SECCIÓN 3: ADJUNTOS
                          const Text(
                            '3. Evidencia Adicional',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Agrega fotos del estado actual o ejemplos. (El PDF se generará solo).',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          if (attachedFiles.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: attachedFiles.map((f) {
                                final isImage =
                                    f.path.toLowerCase().endsWith('.jpg') ||
                                    f.path.toLowerCase().endsWith('.jpeg') ||
                                    f.path.toLowerCase().endsWith('.png');
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: isImage
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                f,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.picture_as_pdf,
                                              size: 30,
                                              color: Colors.redAccent,
                                            ),
                                    ),
                                    Positioned(
                                      top: -8,
                                      right: -8,
                                      child: InkWell(
                                        onTap: () => setModalState(
                                          () => attachedFiles.remove(f),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 70,
                              );
                              if (pickedFile != null)
                                setModalState(
                                  () => attachedFiles.add(
                                    File(pickedFile.path),
                                  ),
                                );
                            },
                            icon: const Icon(
                              Icons.add_photo_alternate,
                              size: 18,
                            ),
                            label: const Text('Agregar Foto de Galería'),
                          ),

                          const Divider(height: 32),

                          // SECCIÓN 5: MENSAJE
                          const Text(
                            '5. Mensaje Breve para el Cliente',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: quickReplies
                                  .map(
                                    (reply) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ActionChip(
                                        label: Text(
                                          reply,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        onPressed: () {
                                          messageController.text =
                                              messageController.text.isEmpty
                                              ? reply
                                              : '${messageController.text} $reply';
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: messageController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Ej: Hola, adjunto cotización detallada en PDF...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // BOTÓN FLOTANTE INFERIOR
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.only(top: 12),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final price = getTotalPrice();
                                if (price <= 0 || quoteItems.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Agrega ítems a la cotización con precio válido.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() => isSubmitting = true);

                                try {
                                  // 1. GENERAR EL PDF CON LOS DATOS
                                  final List<Map<String, dynamic>> mappedItems = quoteItems.map((i) {
                                    final q = double.tryParse(i['qty']!.text) ?? 1.0;
                                    final p = double.tryParse(i['price']!.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                                    return {
                                      'description': i['desc']!.text.isEmpty ? 'Servicio' : i['desc']!.text,
                                      'quantity': q,
                                      'unitPrice': p,
                                      'total': q * p,
                                    };
                                  }).toList();

                                  final generatedPdf = await PdfGenerator.generateDetailedPdf(
                                    clientName: req['customerName'] ?? 'Cliente',
                                    projectName: req['title'] ?? 'Trabajo Solicitado',
                                    items: mappedItems,
                                    subtotal: price,
                                    total: price,
                                    notes: '',
                                  );
                                  
                                  // Mostrar vista previa
                                  setModalState(() => isSubmitting = false);
                                  
                                  if (!mounted) return;
                                  
                                  final bool? confirmSend = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        appBar: AppBar(
                                          title: const Text('Vista Previa'),
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                        body: SfPdfViewer.file(generatedPdf),
                                        bottomNavigationBar: SafeArea(
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: const Text('Modificar'),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppColors.primary,
                                                      foregroundColor: Colors.white,
                                                    ),
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: const Text('Enviar Cotización'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );

                                  if (confirmSend != true) {
                                    // El usuario canceló o quiere modificar
                                    return;
                                  }

                                  setModalState(() => isSubmitting = true);
                                  
                                  // Añadimos el PDF generado a los adjuntos
                                  attachedFiles.add(generatedPdf);

                                  // 2. PREPARAR DATOS PARA ENVÍO
                                  final reqId = int.tryParse(req['id'].toString()) ?? 0;
                                  final timeStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';
                                  final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

                                  List<String> base64Files = [];
                                  for (final file in attachedFiles) {
                                    try {
                                      final bytes = await file.readAsBytes();
                                      final base64String = base64Encode(bytes);
                                      final extension = file.path.split('.').last.toLowerCase();
                                      String mimeType = 'application/octet-stream';
                                      if (['jpg', 'jpeg'].contains(extension))
                                        mimeType = 'image/jpeg';
                                      else if (extension == 'png')
                                        mimeType = 'image/png';
                                      else if (extension == 'pdf')
                                        mimeType = 'application/pdf';

                                      base64Files.add('data:$mimeType;base64,$base64String');
                                    } catch (e) {
                                      debugPrint('Error encoding file: $e');
                                    }
                                  }

                                  // 3. CONSTRUIR TEXTO DEL MENSAJE DE RESUMEN
                                  String finalMessage = messageController.text.trim();
                                  finalMessage += '\n\n--- Resumen de la Cotización ---';
                                  for (var item in mappedItems) {
                                    finalMessage += '\n${item['description']}: \$${item['total']}';
                                  }
                                  finalMessage += '\n\nTotal a pagar: \$$price';

                                  // 4. ENVIAR A BACKEND
                                  final dataSource = di.sl<RequestsRemoteDataSource>();
                                  final ok = await dataSource.submitJobProposal(
                                    publicRequestId: reqId,
                                    estimatedPrice: price,
                                    scheduledDate: dateStr,
                                    scheduledTime: timeStr,
                                    message: finalMessage.trim(),
                                    attachmentsBase64: base64Files.isNotEmpty ? base64Files : null,
                                  );

                                  if (mounted) {
                                    if (ok) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('¡Cotización enviada exitosamente con PDF adjunto!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      _fetchOpportunities();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('La cotización no pudo ser enviada. Revisa los datos o intenta de nuevo.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      setModalState(() => isSubmitting = false);
                                    }
                                  }
                                } catch (e) {
                                  debugPrint('Error submitting proposal: $e');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error al enviar la propuesta: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    setModalState(() => isSubmitting = false);
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Vista Previa',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (previous, current) => previous.currentIndex != current.currentIndex,
      listener: (context, state) {
        if (state.currentIndex == 2) {
          _fetchOpportunities();
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    bool isValidated = true;
    bool isRejected = false;
    String rejectionReason = '';
    if (authState is AuthAuthenticated) {
      isValidated = authState.user.isValidated;
      isRejected = authState.user.isRejected;
      rejectionReason = authState.user.effectiveRejectionReason;
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
                    color: isRejected
                        ? Colors.red.shade100
                        : Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRejected
                        ? Icons.cancel_rounded
                        : Icons.lock_clock_rounded,
                    size: 54,
                    color: isRejected
                        ? Colors.red.shade700
                        : const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isRejected
                      ? 'Registro Rechazado'
                      : 'En Proceso de Validación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isRejected
                        ? Colors.red.shade800
                        : const Color(0xFF92400E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isRejected
                      ? 'Tu perfil profesional fue observado:\n"$rejectionReason"\n\nPor favor vuelve a subir los documentos corregidos para iniciar una nueva revisión.'
                      : 'Tu perfil profesional se encuentra en proceso de revisión por nuestro equipo. Una vez validado tu registro, podrás explorar y enviar cotizaciones a los requerimientos específicos de clientes en tu zona.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRejected
                        ? const Color(0xFFDC2626)
                        : AppColors.primaryBlue,
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
                    if (isRejected && authState is AuthAuthenticated) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RejectionReviewPage(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DocumentsPage(),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    isRejected
                        ? Icons.upload_file_rounded
                        : Icons.description_outlined,
                  ),
                  label: Text(
                    isRejected
                        ? 'Subir documentos de nuevo'
                        : 'Ver mis Documentos',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: const Text(
                'Requerimientos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue.withOpacity(0.8), AppColors.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _fetchOpportunities,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: _selectedTabIndex == 0
                                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Disponibles (${_opportunities.length})',
                              style: TextStyle(
                                color: _selectedTabIndex == 0 ? AppColors.primaryBlue : Colors.grey.shade600,
                                fontWeight: _selectedTabIndex == 0 ? FontWeight.bold : FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: _selectedTabIndex == 1
                                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Mis Cotizaciones (${_opportunities.where((r) => r['hasSubmittedProposal'] == true).length})',
                              style: TextStyle(
                                color: _selectedTabIndex == 1 ? AppColors.primaryBlue : Colors.grey.shade600,
                                fontWeight: _selectedTabIndex == 1 ? FontWeight.bold : FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (filteredList.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final req = filteredList[index];
                    final isUrgent = req['isUrgent'] == true;
                    final proposalsCount = req['proposalsCount'] ?? 0;
                    final hasSubmitted = req['hasSubmittedProposal'] == true;
                    final myProp = req['myProposal'] ?? {};

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            if (hasSubmitted) {
                              _showSentProposalDialog(req);
                            } else {
                              _showProposalDialog(req);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isUrgent ? Colors.red.shade50 : AppColors.primaryBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isUrgent) ...[
                                            const Icon(Icons.whatshot_rounded, color: Colors.red, size: 14),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            isUrgent ? 'URGENTE' : (req['specialtyName'] ?? 'General'),
                                            style: TextStyle(
                                              color: isUrgent ? Colors.red.shade700 : AppColors.primaryBlue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (hasSubmitted) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle_rounded, color: Colors.green.shade700, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Cotizado',
                                              style: TextStyle(
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$proposalsCount/5',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  req['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  req['description'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    height: 1.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey.shade400),
                                    const SizedBox(width: 6),
                                    Text(
                                      req['customerName'] ?? 'Cliente',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade400),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        req['address'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Presupuesto',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          req['budget'] != null ? _formatPrice(req['budget']) : 'A convenir',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: hasSubmitted ? Colors.green.shade700 : AppColors.primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: hasSubmitted ? Colors.white : AppColors.primaryBlue,
                                        foregroundColor: hasSubmitted ? Colors.green.shade700 : Colors.white,
                                        elevation: hasSubmitted ? 0 : 2,
                                        side: hasSubmitted ? BorderSide(color: Colors.green.shade200) : null,
                                        minimumSize: Size.zero,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (hasSubmitted) {
                                          _showSentProposalDialog(req);
                                        } else {
                                          _showProposalDialog(req);
                                        }
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            hasSubmitted ? Icons.visibility_outlined : Icons.send_rounded,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            hasSubmitted ? 'Ver Oferta' : 'Cotizar',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: filteredList.length,
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.campaign_rounded, size: 48, color: Colors.blue.shade300),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedTabIndex == 0
                ? 'No hay solicitudes por ahora'
                : 'Aún no has enviado cotizaciones',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _selectedTabIndex == 0
                  ? 'Te notificaremos cuando un cliente publique un trabajo en tu zona.'
                  : 'Las propuestas que envíes a los clientes aparecerán aquí.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
