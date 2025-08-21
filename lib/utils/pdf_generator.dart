
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReceiptItem {
  final String nombre;
  final int cantidad;
  final double precioUnitario;
  ReceiptItem({required this.nombre, required this.cantidad, required this.precioUnitario});
}

class PdfGenerator {
  static Future<void> generateAndShareReceipt({
    required int ventaId,
    required String fecha,
    required List<ReceiptItem> items,
    required double envio,
    required double total,
  }) async {
    final pdf = pw.Document();
    final fCurrency = NumberFormat.currency(symbol: '\$');

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Tienda de Medicamentos', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Recibo #$ventaId  •  ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(fecha))}'),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: const ['Producto', 'Cant.', 'Precio', 'Total'],
              data: items.map((e) => [
                e.nombre,
                e.cantidad.toString(),
                fCurrency.format(e.precioUnitario),
                fCurrency.format(e.precioUnitario * e.cantidad),
              ]).toList(),
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                  pw.Text('Subtotal: ${fCurrency.format(items.fold(0.0, (p, e) => p + e.precioUnitario * e.cantidad))}'),
                  pw.Text('Envío: ${fCurrency.format(envio)}'),
                  pw.Text('TOTAL: ${fCurrency.format(total)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ]),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Text('Gracias por su compra.'),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/recibo_$ventaId.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Recibo de compra #$ventaId');
  }
}
