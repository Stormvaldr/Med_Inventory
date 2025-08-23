
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';
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
      final db = await DatabaseHelper.instance.database;
      final now = DateTime.now();
      final dayStart = DateTime(now.year, now.month, now.day).toIso8601String();
      final nextDay = DateTime(now.year, now.month, now.day + 1).toIso8601String();
      final monthStart = DateTime(now.year, now.month, 1).toIso8601String();
      final nextMonth = DateTime(now.year, now.month + 1, 1).toIso8601String();

      // Verificar si hay ventas
      final ventasCount = await db.rawQuery('SELECT COUNT(*) as count FROM ventas');
      print('Total ventas en BD: ${ventasCount.first['count']}');

      // Ingresos (sum de total)
      final d = await db.rawQuery(
        'SELECT SUM(total) as s FROM ventas WHERE fecha >= ? AND fecha < ?',
        [dayStart, nextDay],
      );
      final m = await db.rawQuery(
        'SELECT SUM(total) as s FROM ventas WHERE fecha >= ? AND fecha < ?',
        [monthStart, nextMonth],
      );
      ingresosDia = (d.first['s'] as double?) ?? 0;
      ingresosMes = (m.first['s'] as double?) ?? 0;

      print('Ingresos día: $ingresosDia, mes: $ingresosMes');

      // Utilidad (diferencia entre precio venta y coste)
      final ud = await db.rawQuery('''
        SELECT SUM((dv.precio_unitario - m.precio_coste) * dv.cantidad) as utilidad
        FROM detalle_ventas dv
        JOIN ventas v ON dv.venta_id = v.id
        JOIN medicamentos m ON dv.medicamento_id = m.id
        WHERE v.fecha >= ? AND v.fecha < ?
      ''', [dayStart, nextDay]);
      
      final um = await db.rawQuery('''
        SELECT SUM((dv.precio_unitario - m.precio_coste) * dv.cantidad) as utilidad
        FROM detalle_ventas dv
        JOIN ventas v ON dv.venta_id = v.id
        JOIN medicamentos m ON dv.medicamento_id = m.id
        WHERE v.fecha >= ? AND v.fecha < ?
      ''', [monthStart, nextMonth]);
      
      utilidadDia = (ud.first['utilidad'] as double?) ?? 0;
      utilidadMes = (um.first['utilidad'] as double?) ?? 0;

      print('Utilidad día: $utilidadDia, mes: $utilidadMes');

      // Cargar lista de clientes con estadísticas
      final clientsResult = await db.rawQuery('''
        SELECT 
          nombre_cliente,
          COUNT(*) as total_compras,
          SUM(total) as total_gastado,
          MAX(fecha) as ultima_compra
        FROM ventas 
        WHERE nombre_cliente IS NOT NULL AND nombre_cliente != ''
        GROUP BY nombre_cliente
        ORDER BY total_gastado DESC
      ''');
      
      clients = clientsResult;
      print('Clientes encontrados: ${clients.length}');

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error cargando reportes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando datos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sección de ganancias mejorada
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
                        Icon(Icons.trending_up, color: theme.colorScheme.primary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Resumen de Ganancias',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Tabla de ganancias estilo similar a clientes
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Table(
                        border: TableBorder.symmetric(
                          inside: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1.5),
                          2: FlexColumnWidth(1.5),
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
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Período',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Ingresos',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Utilidad',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.today, size: 16, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'HOY',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  f.format(ingresosDia),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  f.format(utilidadDia),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_month, size: 16, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'ESTE MES',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  f.format(ingresosMes),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  f.format(utilidadMes),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Sección de clientes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Historial de Clientes',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (clients.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'No hay clientes registrados',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Table(
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: Colors.grey[300]!),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(2.5),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1.5),
                            3: FlexColumnWidth(1.5),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('Compras', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('Total Gastado', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('Última Compra', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      client['nombre_cliente'],
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text('${client['total_compras']}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(f.format(client['total_gastado'])),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    dateFormat.format(DateTime.parse(client['ultima_compra'])),
                                    style: const TextStyle(fontSize: 12),
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
            const Text(
              'Desliza hacia abajo para actualizar. Toca el nombre de un cliente para ver su historial.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
