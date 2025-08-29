
import 'package:flutter/material.dart';
import '../data/database_factory.dart';
import '../models/drug.dart';
import '../utils/pdf_generator.dart';
import '../utils/bubble_notification.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Drug> inventory = [];
  final Map<int, int> cart = {}; // medicamentoId -> cantidad
  final Map<int, TextEditingController> _quantityControllers = {}; // medicamentoId -> controller
  final TextEditingController _clienteController = TextEditingController();
  bool esMayorista = false; // false = minorista, true = mayorista

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  @override
  void dispose() {
    _clienteController.dispose();
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getQuantityController(int drugId) {
    if (!_quantityControllers.containsKey(drugId)) {
      final quantity = cart[drugId] ?? 0;
      _quantityControllers[drugId] = TextEditingController(text: quantity.toString());
    }
    return _quantityControllers[drugId]!;
  }

  void _updateQuantityController(int drugId, int newQuantity) {
    final controller = _getQuantityController(drugId);
    if (controller.text != newQuantity.toString()) {
      controller.text = newQuantity.toString();
    }
  }

  Future<void> _loadInventory() async {
    final drugs = await DatabaseFactory.instance.getDrugs();
    setState(() {
      inventory = drugs;
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
      context.showWarningBubble('Añade productos al carrito.');
      return;
    }
    if (_clienteController.text.trim().isEmpty) {
      context.showWarningBubble('Ingresa el nombre del cliente.');
      return;
    }
    
    // Use DatabaseFactory for web-compatible database operations
    try {
      final fecha = DateTime.now().toIso8601String();
      final totalVenta = total;
      final nombreCliente = _clienteController.text.trim();
      
      // Prepare sale items
      final items = cart.entries.map((entry) {
        final drug = inventory.firstWhere((d) => d.id == entry.key);
        final precioUnitario = esMayorista ? drug.precioVentaMayorista : drug.precioVentaMinorista;
        return {
          'medicamento_id': drug.id,
          'cantidad': entry.value,
          'precio_unitario': precioUnitario,
          'nombre': drug.nombre,
        };
      }).toList();
      
      final ventaId = await DatabaseFactory.instance.saveSale(
        fecha: fecha,
        total: totalVenta,
        nombreCliente: nombreCliente,
        esMayorista: esMayorista,
        items: items,
      );

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
    } catch (e) {
      if (mounted) {
        context.showErrorBubble('Error al registrar venta: $e');
      }
      return;
    }

    setState(() {
      cart.clear();
      _clienteController.clear();
      esMayorista = false;
      // Limpiar todos los controladores de cantidad
      for (final controller in _quantityControllers.values) {
        controller.clear();
      }
    });
    await _loadInventory();
    if (mounted) {
      context.showSuccessBubble('Venta registrada e informe guardado.');
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
                  width: 80,
                  child: TextFormField(
                    controller: _getQuantityController(d.id!),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
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
                      } else if (value.isEmpty) {
                        // Permitir campo vacío temporalmente
                        setState(() {
                          cart.remove(d.id!);
                        });
                      }
                    },
                    onEditingComplete: () {
                      // Asegurar que el valor sea válido al terminar la edición
                      final controller = _getQuantityController(d.id!);
                      final newQ = int.tryParse(controller.text) ?? 0;
                      if (newQ < 0 || newQ > d.cantidad) {
                        final validQ = newQ < 0 ? 0 : d.cantidad;
                        controller.text = validQ.toString();
                        setState(() {
                          if (validQ == 0) {
                            cart.remove(d.id!);
                          } else {
                            cart[d.id!] = validQ;
                          }
                        });
                      }
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
