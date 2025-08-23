
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
  final TextEditingController _clienteController = TextEditingController();
  bool esMayorista = false; // false = minorista, true = mayorista

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

  double get total {
    double s = 0;
    for (final entry in cart.entries) {
      final drug = inventory.firstWhere((d) => d.id == entry.key);
      final precio = esMayorista ? drug.precioVentaMayorista : drug.precioVentaMinorista;
      s += precio * entry.value;
    }
    return s;
  }

  Future<void> _confirmSale() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Añade productos al carrito.')));
      return;
    }
    if (_clienteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa el nombre del cliente.')));
      return;
    }
    
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      final fecha = DateTime.now().toIso8601String();
      final totalVenta = total;
      final nombreCliente = _clienteController.text.trim();
      final ventaId = await txn.insert('ventas', {
        'fecha': fecha, 
        'total': totalVenta, 
        'nombre_cliente': nombreCliente,
        'es_mayorista': esMayorista ? 1 : 0
      });

      // Insert items y rebajar stock
      for (final entry in cart.entries) {
        final drug = inventory.firstWhere((d) => d.id == entry.key);
        final precioUnitario = esMayorista ? drug.precioVentaMayorista : drug.precioVentaMinorista;
        await txn.insert('detalle_ventas', {
          'venta_id': ventaId,
          'medicamento_id': drug.id,
          'cantidad': entry.value,
          'precio_unitario': precioUnitario,
        });
        final nuevoStock = drug.cantidad - entry.value;
        await txn.update('medicamentos', {'cantidad': nuevoStock}, where: 'id = ?', whereArgs: [drug.id]);
      }

      // Guardar informe de venta (sin compartir PDF)
      await PdfGenerator.saveReceiptReport(
        ventaId: ventaId,
        fecha: fecha,
        nombreCliente: nombreCliente,
        items: cart.entries.map((e) {
          final drug = inventory.firstWhere((d) => d.id == e.key);
          final precioUnitario = esMayorista ? drug.precioVentaMayorista : drug.precioVentaMinorista;
          return ReceiptItem(nombre: drug.nombre, cantidad: e.value, precioUnitario: precioUnitario);
        }).toList(),
        total: totalVenta,
      );
    });

    setState(() {
      cart.clear();
      _clienteController.clear();
      esMayorista = false;
    });
    await _loadInventory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Venta registrada e informe guardado.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _clienteController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del cliente',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _confirmSale,
                    icon: const Icon(Icons.save),
                    label: const Text('Confirmar Venta'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.business, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text('Tipo de cliente:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Minorista'),
                          icon: Icon(Icons.person),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('Mayorista'),
                          icon: Icon(Icons.business),
                        ),
                      ],
                      selected: {esMayorista},
                      onSelectionChanged: (Set<bool> selection) {
                        setState(() {
                          esMayorista = selection.first;
                        });
                      },
                    ),
                  ),
                ],
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
                subtitle: Text('Precio: \$${(esMayorista ? d.precioVentaMayorista : d.precioVentaMinorista).toStringAsFixed(2)} • Stock: ${d.cantidad}'),
                trailing: SizedBox(
                  width: 160,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: q > 0 ? () => setState(() => cart[d.id!] = q - 1 == 0 ? 0 : q - 1) : null,
                      ),
                      SizedBox(
                        width: 50,
                        child: TextFormField(
                          initialValue: q.toString(),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          onChanged: (value) {
                            final newQ = int.tryParse(value) ?? 0;
                            if (newQ >= 0 && newQ <= d.cantidad) {
                              setState(() {
                                if (newQ == 0) {
                                  cart.remove(d.id!);
                                } else {
                                  cart[d.id!] = newQ;
                                }
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: d.cantidad > q ? () => setState(() => cart[d.id!] = q + 1) : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items en carrito: ${cart.values.fold(0, (sum, qty) => sum + qty)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
