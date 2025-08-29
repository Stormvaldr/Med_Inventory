
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/database_factory.dart';
import '../models/drug.dart';
import '../utils/currency_formatter.dart';
import '../utils/bubble_notification.dart';
import 'client_history_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double ingresosDia = 0;
  double ingresosMes = 0;
  double utilidadDia = 0;
  double utilidadMes = 0;
  List<Map<String, dynamic>> clients = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sales = await DatabaseFactory.instance.getSales();
      final drugs = await DatabaseFactory.instance.getDrugs();
      final now = DateTime.now();
      final dayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      print('Total ventas en BD: ${sales.length}');

      // Filter sales by date
      final todaySales = sales.where((sale) {
        final saleDate = DateTime.parse(sale.fecha);
        return saleDate.year == dayStart.year && 
               saleDate.month == dayStart.month && 
               saleDate.day == dayStart.day;
      }).toList();
      
      final monthSales = sales.where((sale) {
        final saleDate = DateTime.parse(sale.fecha);
        return saleDate.year == monthStart.year && 
               saleDate.month == monthStart.month;
      }).toList();

      // Calculate income
      ingresosDia = todaySales.fold(0.0, (sum, sale) => sum + sale.total);
      ingresosMes = monthSales.fold(0.0, (sum, sale) => sum + sale.total);

      print('Ingresos día: $ingresosDia, mes: $ingresosMes');

      // Calculate profit (difference between sale price and cost)
      utilidadDia = 0.0;
      utilidadMes = 0.0;
      
      for (final sale in todaySales) {
        final items = await DatabaseFactory.instance.getSaleItems(sale.id!);
        for (final item in items) {
          final drug = drugs.firstWhere((d) => d.id == item.medicamentoId, orElse: () => Drug(id: 0, nombre: '', precioCoste: 0, precioVentaMinorista: 0, precioVentaMayorista: 0, cantidad: 0));
          if (drug.id != 0) {
            utilidadDia += (item.precioUnitario - drug.precioCoste) * item.cantidad;
          }
        }
      }
      
      for (final sale in monthSales) {
        final items = await DatabaseFactory.instance.getSaleItems(sale.id!);
        for (final item in items) {
          final drug = drugs.firstWhere((d) => d.id == item.medicamentoId, orElse: () => Drug(id: 0, nombre: '', precioCoste: 0, precioVentaMinorista: 0, precioVentaMayorista: 0, cantidad: 0));
          if (drug.id != 0) {
            utilidadMes += (item.precioUnitario - drug.precioCoste) * item.cantidad;
          }
        }
      }

      print('Utilidad día: $utilidadDia, mes: $utilidadMes');

      // Build client statistics
      final Map<String, Map<String, dynamic>> clientStats = {};
      for (final sale in sales) {
        if (sale.nombreCliente.isNotEmpty) {
          if (!clientStats.containsKey(sale.nombreCliente)) {
            clientStats[sale.nombreCliente] = {
              'nombre_cliente': sale.nombreCliente,
              'total_compras': 0,
              'total_gastado': 0.0,
              'ultima_compra': sale.fecha,
            };
          }
          clientStats[sale.nombreCliente]!['total_compras'] += 1;
          clientStats[sale.nombreCliente]!['total_gastado'] += sale.total;
          
          // Update last purchase if this sale is more recent
          final currentLast = DateTime.parse(clientStats[sale.nombreCliente]!['ultima_compra']);
          final saleDate = DateTime.parse(sale.fecha);
          if (saleDate.isAfter(currentLast)) {
            clientStats[sale.nombreCliente]!['ultima_compra'] = sale.fecha;
          }
        }
      }
      
      clients = clientStats.values.toList()
        ..sort((a, b) => (b['total_gastado'] as double).compareTo(a['total_gastado'] as double));
      print('Clientes encontrados: ${clients.length}');

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error cargando reportes: $e');
      if (mounted) {
        context.showErrorBubble('Error cargando datos: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = CurrencyFormatter.isSmallScreen(screenWidth);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sección de clientes
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, color: theme.colorScheme.primary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Historial de Clientes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (clients.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'No hay clientes registrados',
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Table(
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
                          ),
                          columnWidths: isSmallScreen ? const {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                          } : const {
                            0: FlexColumnWidth(2.5),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1.5),
                            3: FlexColumnWidth(1.5),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                  child: Text(
                                    'Cliente',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                  child: Text(
                                    'Compras',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                  child: Text(
                                    isSmallScreen ? 'Total' : 'Total Gastado',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                  child: Text(
                                    isSmallScreen ? 'Última' : 'Última Compra',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ...clients.map((client) => TableRow(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClientHistoryScreen(
                                          clientName: client['nombre_cliente'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                    child: Text(
                                      client['nombre_cliente'],
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                  child: Text(
                                    CurrencyFormatter.formatPurchaseCount(client['total_compras']),
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                  child: Text(
                                    CurrencyFormatter.formatForTable(client['total_gastado'], isSmallScreen),
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: isSmallScreen ? 12 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                  child: Text(
                                    dateFormat.format(DateTime.parse(client['ultima_compra'])),
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 10 : 12,
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            )).toList(),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Desliza hacia abajo para actualizar. Toca el nombre de un cliente para ver su historial.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
