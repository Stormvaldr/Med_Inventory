import 'package:flutter/material.dart';
import 'utils/bubble_notification.dart';

void main() {
  runApp(const MedSalesWebApp());
}

class MedSalesWebApp extends StatelessWidget {
  const MedSalesWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ventas de Medicamentos - Demo Web',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const WebHomePage(),
    );
  }
}

class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key});

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  int _index = 0;
  final _clienteController = TextEditingController();
  final List<Map<String, dynamic>> _cartItems = [];
  final List<Map<String, dynamic>> _inventory = [
    {'id': 1, 'nombre': 'Paracetamol 500mg', 'precio': 15.50, 'cantidad': 100},
    {'id': 2, 'nombre': 'Ibuprofeno 400mg', 'precio': 22.00, 'cantidad': 75},
    {'id': 3, 'nombre': 'Amoxicilina 250mg', 'precio': 35.00, 'cantidad': 50},
    {'id': 4, 'nombre': 'Loratadina 10mg', 'precio': 18.75, 'cantidad': 80},
  ];

  double get total {
    return _cartItems.fold(0.0, (sum, item) => sum + (item['precio'] * item['cantidad']));
  }

  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + (item['cantidad'] as int));
  }

  void _addToCart(Map<String, dynamic> product, int quantity) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((item) => item['id'] == product['id']);
      if (existingIndex >= 0) {
        _cartItems[existingIndex]['cantidad'] += quantity;
      } else {
        _cartItems.add({
          ...product,
          'cantidad': quantity,
        });
      }
    });
  }

  void _confirmSale() {
    if (_clienteController.text.trim().isEmpty) {
      context.showWarningBubble('Por favor ingrese el nombre del cliente');
      return;
    }

    if (_cartItems.isEmpty) {
      context.showWarningBubble('El carrito está vacío');
      return;
    }

    // Simular guardado de venta
    setState(() {
      _cartItems.clear();
      _clienteController.clear();
    });

    context.showSuccessBubble('Venta confirmada y guardada exitosamente');
  }

  Widget _buildInventoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Inventario de Medicamentos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _inventory.length,
              itemBuilder: (context, index) {
                final item = _inventory[index];
                return Card(
                  child: ListTile(
                    title: Text(item['nombre']),
                    subtitle: Text('Precio: \$${item['precio']} - Stock: ${item['cantidad']}'),
                    trailing: const Icon(Icons.medication),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Sistema de Ventas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Campo de cliente
          TextFormField(
            controller: _clienteController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Cliente',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          // Lista de productos
          Expanded(
            child: Row(
              children: [
                // Productos disponibles
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Productos Disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _inventory.length,
                          itemBuilder: (context, index) {
                            final product = _inventory[index];
                            return Card(
                              child: ListTile(
                                title: Text(product['nombre']),
                                subtitle: Text('\$${product['precio']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _addToCart(product, 1),
                                      icon: const Icon(Icons.add_shopping_cart),
                                    ),
                                    IconButton(
                                      onPressed: () => _addToCart(product, 5),
                                      icon: const Icon(Icons.add_circle),
                                      tooltip: 'Agregar 5',
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
                ),
                const SizedBox(width: 16),
                // Carrito
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Carrito de Compras', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _cartItems.isEmpty
                            ? const Center(child: Text('Carrito vacío'))
                            : ListView.builder(
                                itemCount: _cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = _cartItems[index];
                                  return Card(
                                    child: ListTile(
                                      title: Text(item['nombre']),
                                      subtitle: Text('Cantidad: ${item['cantidad']}'),
                                      trailing: Text('\$${(item['precio'] * item['cantidad']).toStringAsFixed(2)}'),
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (_cartItems.isNotEmpty) ...[
                        const Divider(),
                        Text('Items: $totalItems', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _confirmSale,
                            icon: const Icon(Icons.save),
                            label: const Text('Confirmar Venta'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Reportes y Ganancias',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 32),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Ganancias del Día', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('\$1,250.00', style: TextStyle(fontSize: 32, color: Colors.green)),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Ganancias del Mes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('\$35,750.00', style: TextStyle(fontSize: 32, color: Colors.blue)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesReportsTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Informes de Ventas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 32),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Ventas Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Juan Pérez'),
                    subtitle: Text('Venta: \$125.50'),
                    trailing: Text('Hoy'),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('María García'),
                    subtitle: Text('Venta: \$89.25'),
                    trailing: Text('Ayer'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildInventoryTab(),
      _buildSalesTab(),
      _buildReportsTab(),
      _buildSalesReportsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Icono personalizado
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_pharmacy,
                color: Colors.teal,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Pinguina Medical - Demo Web'),
          ],
        ),
        backgroundColor: Colors.teal.shade50,
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale),
            label: 'Ventas',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment),
            label: 'Informes',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _clienteController.dispose();
    super.dispose();
  }
}