
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'screens/inventory_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/reports_screen.dart';

void main() {
  runApp(const MedSalesApp());
}

class MedSalesApp extends StatelessWidget {
  const MedSalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ventas de Medicamentos',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final _pages = const [
    InventoryScreen(),
    SalesScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda - Gestión Offline'),
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Inventario'),
          NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'Ventas'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reportes'),
        ],
      ),
    );
  }
}
