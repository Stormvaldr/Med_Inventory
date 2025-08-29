import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../data/database_factory.dart';
import '../utils/pdf_generator.dart';
import '../utils/bubble_notification.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;

class SalesReportsScreen extends StatefulWidget {
  const SalesReportsScreen({super.key});

  @override
  State<SalesReportsScreen> createState() => _SalesReportsScreenState();
}

class _SalesReportsScreenState extends State<SalesReportsScreen> {
  List<Sale> _sales = [];
  bool _isLoading = true;
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _isLoading = true);
    final sales = await DatabaseFactory.instance.getSales();
    setState(() {
      _sales = sales;
      _isLoading = false;
    });
  }

  List<Sale> get _filteredSales {
    return _sales.where((sale) {
      final saleDate = DateTime.parse(sale.fecha);
      final saleMonth = DateFormat('yyyy-MM').format(saleDate);
      return saleMonth == _selectedMonth;
    }).toList();
  }

  Future<void> _exportMonthlyReport() async {
    final filteredSales = _filteredSales;
    if (filteredSales.isEmpty) {
      context.showInfoBubble('No hay ventas en el mes seleccionado');
      return;
    }

    final pdf = pw.Document();
    final fCurrency = NumberFormat.currency(symbol: '\$');
    final monthName = DateFormat('MMMM yyyy', 'es').format(DateTime.parse('$_selectedMonth-01'));
    
    double totalMonth = 0;
    final salesData = <List<String>>[];
    
    for (final sale in filteredSales) {
      final items = await DatabaseFactory.instance.getSaleItems(sale.id!);
      final itemsText = items.map((item) => '${item.nombre} (${item.cantidad})').join(', ');
      salesData.add([
        sale.id.toString(),
        sale.nombreCliente ?? 'Sin nombre',
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(sale.fecha)),
        itemsText,
        fCurrency.format(sale.total),
      ]);
      totalMonth += sale.total;
    }

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Reporte Mensual de Ventas',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Mes: $monthName'),
            pw.Text('Total de ventas: ${filteredSales.length}'),
            pw.Text('Ingresos totales: ${fCurrency.format(totalMonth)}'),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: const ['ID', 'Cliente', 'Fecha', 'Productos', 'Total'],
              data: salesData,
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'TOTAL DEL MES: ${fCurrency.format(totalMonth)}',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${dir.path}/reportes_mensuales');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    
    final file = File('${reportsDir.path}/reporte_$_selectedMonth.pdf');
    await file.writeAsBytes(await pdf.save());
    
    await Share.shareXFiles([XFile(file.path)], text: 'Reporte mensual $_selectedMonth');
    
    if (mounted) {
      context.showSuccessBubble('Reporte exportado: ${file.path}');
    }
  }

  Future<void> _viewSaleReport(Sale sale) async {
    final items = await DatabaseFactory.instance.getSaleItems(sale.id!);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/informes_ventas/informe_venta_${sale.id}.pdf');
    
    if (await file.exists()) {
      await Share.shareXFiles([XFile(file.path)], text: 'Informe de venta #${sale.id}');
    } else {
      // Regenerar el informe si no existe
      final receiptItems = items.map((item) => ReceiptItem(
        nombre: item.nombre,
        cantidad: item.cantidad,
        precioUnitario: item.precioUnitario,
      )).toList();
      
      await PdfGenerator.saveReceiptReport(
        ventaId: sale.id!,
        fecha: sale.fecha,
        nombreCliente: sale.nombreCliente ?? 'Sin nombre',
        items: receiptItems,
        total: sale.total,
      );
      
      await Share.shareXFiles([XFile(file.path)], text: 'Informe de venta #${sale.id}');
    }
  }

  Future<void> _deleteSale(Sale sale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la venta #${sale.id} de ${sale.nombreCliente}?\n\n'
          'Esta acción restaurará el stock de los medicamentos vendidos y no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseFactory.instance.deleteSale(sale.id!);
        
        // Eliminar el archivo PDF si existe
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/informes_ventas/informe_venta_${sale.id}.pdf');
        if (await file.exists()) {
          await file.delete();
        }
        
        // Recargar la lista de ventas
        await _loadSales();
        
        if (mounted) {
          context.showSuccessBubble('Venta #${sale.id} eliminada correctamente');
        }
      } catch (e) {
        if (mounted) {
          context.showErrorBubble('Error al eliminar la venta: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informes de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportMonthlyReport,
            tooltip: 'Exportar reporte mensual',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Mes: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedMonth,
                    isExpanded: true,
                    items: _generateMonthOptions(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedMonth = value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSales.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay ventas en el mes seleccionado',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredSales.length,
                        itemBuilder: (context, index) {
                          final sale = _filteredSales[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(sale.id.toString()),
                              ),
                              title: Text(
                                sale.nombreCliente ?? 'Sin nombre',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(DateTime.parse(sale.fecha)),
                                  ),
                                  Text(
                                    'Total: \$${sale.total.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.picture_as_pdf),
                                    onPressed: () => _viewSaleReport(sale),
                                    tooltip: 'Ver informe PDF',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteSale(sale),
                                    tooltip: 'Eliminar venta',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _generateMonthOptions() {
    final now = DateTime.now();
    final months = <DropdownMenuItem<String>>[];
    
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('yyyy-MM').format(date);
      final monthName = DateFormat('MMMM yyyy', 'es').format(date);
      
      months.add(DropdownMenuItem(
        value: monthKey,
        child: Text(monthName),
      ));
    }
    
    return months;
  }
}