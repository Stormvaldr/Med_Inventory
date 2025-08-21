
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day).toIso8601String();
    final nextDay = DateTime(now.year, now.month, now.day + 1).toIso8601String();
    final monthStart = DateTime(now.year, now.month, 1).toIso8601String();
    final nextMonth = DateTime(now.year, now.month + 1, 1).toIso8601String();

    // Ingresos (sum de total)
    final d = await db.rawQuery(
      'SELECT SUM(total) as s FROM ventas WHERE fecha >= ? AND fecha < ?',
      [dayStart, nextDay],
    );
    final m = await db.rawQuery(
      'SELECT SUM(total) as s FROM ventas WHERE fecha >= ? AND fecha < ?',
      [monthStart, nextMonth],
    );
    ingresosDia = (d.first['s'] as num?)?.toDouble() ?? 0;
    ingresosMes = (m.first['s'] as num?)?.toDouble() ?? 0;

    // Utilidad = sum( (precio_venta - precio_coste) * cantidad ) por periodo
    // Para el día
    final ud = await db.rawQuery('''
      SELECT SUM( (dv.precio_unitario - med.precio_coste) * dv.cantidad ) AS u
      FROM detalle_ventas dv
      JOIN ventas v ON v.id = dv.venta_id
      JOIN medicamentos med ON med.id = dv.medicamento_id
      WHERE v.fecha >= ? AND v.fecha < ?
    ''', [dayStart, nextDay]);

    final um = await db.rawQuery('''
      SELECT SUM( (dv.precio_unitario - med.precio_coste) * dv.cantidad ) AS u
      FROM detalle_ventas dv
      JOIN ventas v ON v.id = dv.venta_id
      JOIN medicamentos med ON med.id = dv.medicamento_id
      WHERE v.fecha >= ? AND v.fecha < ?
    ''', [monthStart, nextMonth]);

    utilidadDia = (ud.first['u'] as num?)?.toDouble() ?? 0;
    utilidadMes = (um.first['u'] as num?)?.toDouble() ?? 0;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(symbol: '\$');
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Ingresos de HOY'),
              subtitle: Text(f.format(ingresosDia)),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Ingresos del MES'),
              subtitle: Text(f.format(ingresosMes)),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Utilidad de HOY'),
              subtitle: Text(f.format(utilidadDia)),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Utilidad del MES'),
              subtitle: Text(f.format(utilidadMes)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Desliza hacia abajo para actualizar.', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
