import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../utils/pdf_generator.dart';

class QuoteItem {
  TextEditingController descCtrl;
  TextEditingController qtyCtrl;
  TextEditingController priceCtrl;

  QuoteItem()
      : descCtrl = TextEditingController(),
        qtyCtrl = TextEditingController(text: '1'),
        priceCtrl = TextEditingController();

  double get quantity => double.tryParse(qtyCtrl.text) ?? 1.0;
  double get unitPrice => double.tryParse(priceCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  double get total => quantity * unitPrice;

  void dispose() {
    descCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
  }
}

class QuoteBuilderPage extends StatefulWidget {
  final String initialProjectName;

  const QuoteBuilderPage({Key? key, required this.initialProjectName}) : super(key: key);

  @override
  State<QuoteBuilderPage> createState() => _QuoteBuilderPageState();
}

class _QuoteBuilderPageState extends State<QuoteBuilderPage> {
  late TextEditingController _clientNameCtrl;
  late TextEditingController _projectNameCtrl;
  late TextEditingController _notesCtrl;
  
  List<QuoteItem> _items = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _clientNameCtrl = TextEditingController();
    _projectNameCtrl = TextEditingController(text: widget.initialProjectName);
    _notesCtrl = TextEditingController(text: 'Condiciones:\n1. Validez de la oferta: 15 días.\n2. Forma de pago: 50% anticipo, 50% al finalizar.');
    _items.add(QuoteItem());
  }

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _projectNameCtrl.dispose();
    _notesCtrl.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);

  void _generatePdf() async {
    // Validate
    if (_items.isEmpty || _items.first.descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor agrega al menos un ítem con descripción.')));
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final List<Map<String, dynamic>> mappedItems = _items.map((i) => {
        'description': i.descCtrl.text,
        'quantity': i.quantity,
        'unitPrice': i.unitPrice,
        'total': i.total,
      }).toList();

      final pdfFile = await PdfGenerator.generateDetailedPdf(
        clientName: _clientNameCtrl.text.isEmpty ? 'Cliente de Clanship' : _clientNameCtrl.text,
        projectName: _projectNameCtrl.text,
        items: mappedItems,
        subtotal: _subtotal,
        total: _subtotal, // We can add tax logic later if needed
        notes: _notesCtrl.text,
      );

      if (mounted) {
        Navigator.pop(context, pdfFile);
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creador de Cotización'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _clientNameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del Cliente (Opcional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _projectNameCtrl,
              decoration: const InputDecoration(labelText: 'Título del Proyecto/Trabajo', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            
            const Text('Detalle de Costos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (c, i) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Description
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: item.descCtrl,
                        decoration: InputDecoration(labelText: 'Concepto (ej. Materiales)', border: const OutlineInputBorder()),
                        onChanged: (_) => setState((){}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Qty
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: item.qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cant.', border: OutlineInputBorder()),
                        onChanged: (_) => setState((){}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Price
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: item.priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Precio Un.', border: OutlineInputBorder()),
                        onChanged: (_) => setState((){}),
                      ),
                    ),
                    // Remove button
                    if (_items.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            item.dispose();
                            _items.removeAt(index);
                          });
                        },
                      )
                  ],
                );
              },
            ),
            
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _items.add(QuoteItem());
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar Ítem'),
              ),
            ),
            
            const SizedBox(height: 24),
            // Totals
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(formatCurrency.format(_subtotal), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Términos y Notas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Ingresa las condiciones de pago, tiempo de entrega, etc.'),
            ),
            
            const SizedBox(height: 100), // padding for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _generatePdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isGenerating 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Crear y Adjuntar PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
