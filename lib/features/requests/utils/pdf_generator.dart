import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart';

class PdfGenerator {
  static Future<File> generateQuotePdf({
    required String requestTitle,
    required double laborCost,
    required double materialsCost,
    required double totalCost,
    required List<String> conditions,
    required String notes,
  }) async {
    final output = await getTemporaryDirectory();
    final outputPath = '${output.path}/Cotizacion_${DateTime.now().millisecondsSinceEpoch}.pdf';

    Uint8List? logoBytes;
    try {
      final ByteData data = await rootBundle.load('assets/icon/app_icon.jpg');
      logoBytes = data.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading logo: $e');
    }

    return await compute(_buildQuotePdf, {
      'requestTitle': requestTitle,
      'laborCost': laborCost,
      'materialsCost': materialsCost,
      'totalCost': totalCost,
      'conditions': conditions,
      'notes': notes,
      'outputPath': outputPath,
          'logoBytes': logoBytes,
    });
  }

  static Future<File> _buildQuotePdf(Map<String, dynamic> data) async {
    final requestTitle = data['requestTitle'] as String;
    final laborCost = data['laborCost'] as double;
    final materialsCost = data['materialsCost'] as double;
    final totalCost = data['totalCost'] as double;
    final conditions = data['conditions'] as List<String>;
    final notes = data['notes'] as String;
    final outputPath = data['outputPath'] as String;

        final logoBytes = data['logoBytes'] as Uint8List?;

    final pdf = pw.Document();

    String formatCurrency(num amount) {
      return '\$${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    }

    final tableHeaders = ['Descripción', 'Valor'];
    final tableData = [
      if (laborCost > 0) ['Mano de Obra', formatCurrency(laborCost)],
      if (materialsCost > 0) ['Materiales', formatCurrency(materialsCost)],
    ];

    pw.MemoryImage? logoImage;
    if (logoBytes != null) {
      logoImage = pw.MemoryImage(logoBytes);
    }

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          buildBackground: (pw.Context context) {
            if (logoImage != null) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Image(logoImage),
                  ),
                ),
              );
            }
            return pw.SizedBox();
          },
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('COTIZACIÓN DE SERVICIO', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                      pw.SizedBox(height: 4),
                      pw.Text('Generado desde Clanship Profesionales', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('COTIZACIÓN #: ${(DateTime.now().millisecondsSinceEpoch % 100000).toString()}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('FECHA: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 12)),
                    ]
                  )
                ]
              ),
              pw.SizedBox(height: 40),
              pw.Text('PROYECTO: $requestTitle', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              
              if (tableData.isNotEmpty) ...[
                pw.TableHelper.fromTextArray(
                  headers: tableHeaders,
                  data: tableData,
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerRight,
                  },
                ),
                pw.SizedBox(height: 10),
              ],
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Text('TOTAL: ', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        pw.Text(formatCurrency(totalCost), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                      ]
                    )
                  )
                ]
              ),
              
              pw.SizedBox(height: 30),
              
              if (conditions.isNotEmpty) ...[
                pw.Text('CONDICIONES', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                pw.SizedBox(height: 8),
                pw.Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  children: conditions.map((c) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.green800),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                    ),
                    child: pw.Text(c, style: pw.TextStyle(fontSize: 10, color: PdfColors.green800)),
                  )).toList(),
                ),
                pw.SizedBox(height: 20),
              ],
              
              if (notes.isNotEmpty) ...[
                pw.Text('NOTAS ADICIONALES', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                pw.SizedBox(height: 8),
                pw.Text(notes),
              ],
              
              pw.Spacer(),
              pw.Center(
                child: pw.Text('Si usted tiene alguna pregunta sobre esta cotización, por favor responda al chat.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              ),
            ],
          );
        },
      ),
    );

    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<File> generateDetailedPdf({
    required String clientName,
    required String projectName,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double total,
    required String notes,
  }) async {
    final output = await getTemporaryDirectory();
    final outputPath = '${output.path}/Cotizacion_${DateTime.now().millisecondsSinceEpoch}.pdf';

    Uint8List? logoBytes;
    try {
      final ByteData data = await rootBundle.load('assets/icon/app_icon.jpg');
      logoBytes = data.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading logo: $e');
    }

    return await compute(_buildDetailedPdf, {
      'clientName': clientName,
      'projectName': projectName,
      'items': items,
      'subtotal': subtotal,
      'total': total,
      'notes': notes,
      'outputPath': outputPath,
          'logoBytes': logoBytes,
    });
  }

  static Future<File> _buildDetailedPdf(Map<String, dynamic> data) async {
    final clientName = data['clientName'] as String;
    final projectName = data['projectName'] as String;
    final items = data['items'] as List<Map<String, dynamic>>;
    final subtotal = data['subtotal'] as double;
    final total = data['total'] as double;
    final notes = data['notes'] as String;
    final outputPath = data['outputPath'] as String;

        final logoBytes = data['logoBytes'] as Uint8List?;

    final pdf = pw.Document();
    
    String formatCurrency(num amount) {
      return '\$${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    }

    final tableHeaders = ['Descripción', 'Cantidad', 'Precio Un.', 'Total'];
    
    final tableData = items.map((item) {
      return [
        item['description'].toString(),
        item['quantity'].toString(),
        formatCurrency(item['unitPrice']),
        formatCurrency(item['total']),
      ];
    }).toList();

    pw.MemoryImage? logoImage;
    if (logoBytes != null) {
      logoImage = pw.MemoryImage(logoBytes);
    }

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          buildBackground: (pw.Context context) {
            if (logoImage != null) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Image(logoImage),
                  ),
                ),
              );
            }
            return pw.SizedBox();
          },
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('COTIZACIÓN DE SERVICIO', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo800)),
                      pw.SizedBox(height: 4),
                      pw.Text('Generado desde Clanship Profesionales', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Nº: ${(DateTime.now().millisecondsSinceEpoch % 100000).toString()}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.Text('FECHA: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
                    ]
                  )
                ]
              ),
              pw.SizedBox(height: 30),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PREPARADO PARA:', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text(clientName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ]
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('PROYECTO:', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text(projectName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ]
                    ),
                  ]
                )
              ),
              
              pw.SizedBox(height: 30),
              
              pw.TableHelper.fromTextArray(
                headers: tableHeaders,
                data: tableData,
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
              ),
              
              pw.SizedBox(height: 20),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 12)),
                            pw.Text(formatCurrency(subtotal), style: const pw.TextStyle(fontSize: 12)),
                          ]
                        ),
                        pw.Divider(color: PdfColors.grey300),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('TOTAL', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
                            pw.Text(formatCurrency(total), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
                          ]
                        ),
                      ]
                    )
                  )
                ]
              ),
              
              pw.Spacer(),
              
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('TÉRMINOS Y CONDICIONES', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                    pw.SizedBox(height: 8),
                    pw.Text(notes, style: const pw.TextStyle(fontSize: 10, lineSpacing: 2)),
                  ]
                )
              )
            ],
          );
        },
      ),
    );

    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
