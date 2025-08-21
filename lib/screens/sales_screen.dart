
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../models/drug.dart';
import '../utils/pdf_generator.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Drug> inventory = [];
  final Map<int, int> cart = {}; // medicamentoId -> cantidad
  double envio = 0.0;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.query('medicamentos', orderBy: 'nombre ASC');
    setState(() {
      inventory = res.map((e) => Drug.fromMap(e)).toList();
    });
  }

  double get subtotal {
    double s = 0;
    for (final entry in cart.entries) {
      final drug = inventory.firstWhere((d) => d.id == entry.key);
      s += drug.precioVenta * entry.value;
    }
    return s;
  }

  Future<void> _confirmSale() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Añade productos al carrito.')));
      return;
    }
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      final fecha = DateTime.now().toIso8601String();
      final total = subtotal + envio;
      final ventaId = await txn.insert('ventas', {'fecha': fecha, 'total': total, 'envio': envio});

      // Insert items y rebajar stock
      for (final entry in cart.entries) {
        final drug = inventory.firstWhere((d) => d.id == entry.key);
        await txn.insert('detalle_ventas', {
          'venta_id': ventaId,
          'medicamento_id': drug.id,
          'cantidad': entry.value,
          'precio_unitario': drug.precioVenta,
        });
        final nuevoStock = drug.cantidad - entry.value;
        await txn.update('medicamentos', {'cantidad': nuevoStock}, where: 'id = ?', whereArgs: [drug.id]);
      }

      // Generar PDF
      await PdfGenerator.generateAndShareReceipt(
        ventaId: ventaId,
        fecha: fecha,
        items: cart.entries.map((e) {
          final drug = inventory.firstWhere((d) => d.id == e.key);
          return ReceiptItem(nombre: drug.nombre, cantidad: e.value, precioUnitario: drug.precioVenta);
        }).toList(),
        envio: envio,
        total: total,
      );
    });

    setState(() {
      cart.clear();
      envio = 0.0;
    });
    await _loadInventory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Venta registrada y recibo generado.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Costo de envío (manual)',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => envio = double.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _confirmSale,
                icon: const Icon(Icons.receipt_long),
                label: const Text('Confirmar y PDF'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: inventory.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = inventory[i];
              final q = cart[d.id] ?? 0;
              return ListTile(
                title: Text(d.nombre),
                subtitle: Text('Precio: ${d.precioVenta.toStringAsFixed(2)} • Stock: ${d.cantidad}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: q > 0 ? () => setState(() => cart[d.id!] = q - 1 == 0 ? 0 : q - 1) : null,
                    ),
                    Text('$q'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: d.cantidad > q ? () => setState(() => cart[d.id!] = q + 1) : null,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
              Text('Total: \$${(subtotal + envio).toStringAsFixed(2)}'),
            ],
          ),
        ),
      ],
    );
  }
}
