
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
  static Future<void> saveReceiptReport({
    required int ventaId,
    required String fecha,
    required String nombreCliente,
    required List<ReceiptItem> items,
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
            pw.Text('Informe de Venta #$ventaId'),
            pw.Text('Cliente: $nombreCliente'),
            pw.Text('Fecha: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(fecha))}'),
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
                  pw.Text('TOTAL: ${fCurrency.format(total)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ]),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Text('Envío gratuito en toda la ciudad.'),
            pw.Text('Gracias por su compra.'),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${dir.path}/informes_ventas');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    
    final file = File('${reportsDir.path}/informe_venta_$ventaId.pdf');
    await file.writeAsBytes(await pdf.save());
  }
  
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

  static Future<void> generateAndShareReportsReport({
    required double ingresosDia,
    required double ingresosMes,
    required double utilidadDia,
    required double utilidadMes,
    required List<Map<String, dynamic>> clients,
  }) async {
    final pdf = pw.Document();
    final fCurrency = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('PinguiMed - Reporte de Ganancias', 
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Generado el: ${dateFormat.format(now)}'),
            pw.SizedBox(height: 20),
            
            // Resumen de Ganancias
            pw.Text('Resumen de Ganancias', 
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: const ['Período', 'Ingresos', 'Utilidad'],
              data: [
                ['HOY', fCurrency.format(ingresosDia), fCurrency.format(utilidadDia)],
                ['ESTE MES', fCurrency.format(ingresosMes), fCurrency.format(utilidadMes)],
              ],
            ),
            pw.SizedBox(height: 20),
            
            // Historial de Clientes
            pw.Text('Historial de Clientes', 
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            if (clients.isEmpty)
              pw.Text('No hay clientes registrados')
            else
              pw.Table.fromTextArray(
                headers: const ['Cliente', 'Compras', 'Total Gastado', 'Última Compra'],
                data: clients.map((client) => [
                  client['nombre_cliente'],
                  client['total_compras'].toString(),
                  fCurrency.format(client['total_gastado']),
                  dateFormat.format(DateTime.parse(client['ultima_compra'])),
                ]).toList(),
              ),
            pw.SizedBox(height: 20),
            pw.Text('Reporte generado automáticamente por PinguiMed',
                 style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('\${dir.path}/reportes_ganancias');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final file = File('\${reportsDir.path}/reporte_ganancias_\$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Reporte de Ganancias - PinguiMed');
  }
}
