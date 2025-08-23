
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../models/drug.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Drug> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.query('medicamentos', orderBy: 'nombre ASC');
    setState(() {
      items = res.map((e) => Drug.fromMap(e)).toList();
      loading = false;
    });
  }

  Future<void> _upsertDrug([Drug? drug]) async {
    final nombreCtrl = TextEditingController(text: drug?.nombre);
    final costeCtrl = TextEditingController(text: drug?.precioCoste.toString() ?? '');
    final ventaMinoristaCtrl = TextEditingController(text: drug?.precioVentaMinorista.toString() ?? '');
    final ventaMayoristaCtrl = TextEditingController(text: drug?.precioVentaMayorista.toString() ?? '');
    final cantCtrl = TextEditingController(text: drug?.cantidad.toString() ?? '');

    final formKey = GlobalKey<FormState>();
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(drug == null ? 'Nuevo medicamento' : 'Editar medicamento'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: costeCtrl,
                  decoration: const InputDecoration(labelText: 'Precio de coste'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (double.tryParse(v ?? '') == null) ? 'Número válido' : null,
                ),
                TextFormField(
                  controller: ventaMinoristaCtrl,
                  decoration: const InputDecoration(labelText: 'Precio venta minorista'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (double.tryParse(v ?? '') == null) ? 'Número válido' : null,
                ),
                TextFormField(
                  controller: ventaMayoristaCtrl,
                  decoration: const InputDecoration(labelText: 'Precio venta mayorista'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (double.tryParse(v ?? '') == null) ? 'Número válido' : null,
                ),
                TextFormField(
                  controller: cantCtrl,
                  decoration: const InputDecoration(labelText: 'Cantidad en stock'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (int.tryParse(v ?? '') == null) ? 'Entero válido' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () {
            if (formKey.currentState!.validate()) Navigator.pop(context, true);
          }, child: const Text('Guardar')),
        ],
      ),
    );

    if (res != true) return;
    final dbi = await DatabaseHelper.instance.database;
    final map = Drug(
      id: drug?.id,
      nombre: nombreCtrl.text.trim(),
      precioCoste: double.parse(costeCtrl.text),
      precioVentaMinorista: double.parse(ventaMinoristaCtrl.text),
      precioVentaMayorista: double.parse(ventaMayoristaCtrl.text),
      cantidad: int.parse(cantCtrl.text),
    ).toMap();

    if (drug == null) {
      await dbi.insert('medicamentos', map);
    } else {
      await dbi.update('medicamentos', map, where: 'id = ?', whereArgs: [drug.id]);
    }
    _load();
  }

  Future<void> _deleteDrug(Drug drug) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar ${drug.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );
    if (ok == true) {
      final db = await DatabaseHelper.instance.database;
      await db.delete('medicamentos', where: 'id = ?', whereArgs: [drug.id]);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _upsertDrug(),
        child: const Icon(Icons.add),
      ),
      body: items.isEmpty
          ? const Center(child: Text('No hay medicamentos. Pulsa + para agregar.'))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final d = items[i];
                return ListTile(
                  title: Text(d.nombre),
                  subtitle: Text('Coste: ${d.precioCoste.toStringAsFixed(2)} • Minorista: ${d.precioVentaMinorista.toStringAsFixed(2)} • Mayorista: ${d.precioVentaMayorista.toStringAsFixed(2)} • Stock: ${d.cantidad}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') _upsertDrug(d);
                      if (val == 'del') _deleteDrug(d);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'del', child: Text('Eliminar')),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
