import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/database_factory.dart';
import '../data/database_helper.dart';
import '../models/drug.dart';
import '../models/finance.dart';
import '../utils/currency_formatter.dart';
import '../utils/bubble_notification.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  double recoveredMoneyDay = 0; // Solo dinero recuperado de inversión (sin ganancias)
  double recoveredMoneyMonth = 0;
  double profitDay = 0;
  double profitMonth = 0;
  double totalInvested = 0;
  double physicalMoney = 0;
  double borrowedMoney = 0;
  
  final TextEditingController _physicalMoneyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadStoredValues();
  }

  @override
  void dispose() {
    _physicalMoneyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final sales = await DatabaseFactory.instance.getSales();
      final drugs = await DatabaseFactory.instance.getDrugs();
      final now = DateTime.now();
      final dayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

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

      // Calculate recovered money (cost of sold medicines - only investment recovery)
      recoveredMoneyDay = 0.0;
      recoveredMoneyMonth = 0.0;
      
      for (final sale in todaySales) {
        final items = await DatabaseFactory.instance.getSaleItems(sale.id!);
        for (final item in items) {
          final drug = drugs.firstWhere(
            (d) => d.id == item.medicamentoId, 
            orElse: () => Drug(id: 0, nombre: '', precioCoste: 0, precioVentaMinorista: 0, precioVentaMayorista: 0, cantidad: 0)
          );
          if (drug.id != 0) {
            recoveredMoneyDay += drug.precioCoste * item.cantidad; // Solo costo de inversión
          }
        }
      }
      
      for (final sale in monthSales) {
        final items = await DatabaseFactory.instance.getSaleItems(sale.id!);
        for (final item in items) {
          final drug = drugs.firstWhere(
            (d) => d.id == item.medicamentoId, 
            orElse: () => Drug(id: 0, nombre: '', precioCoste: 0, precioVentaMinorista: 0, precioVentaMayorista: 0, cantidad: 0)
          );
          if (drug.id != 0) {
            recoveredMoneyMonth += drug.precioCoste * item.cantidad; // Solo costo de inversión
          }
        }
      }

      // Calculate profits
      profitDay = 0.0;
      profitMonth = 0.0;
      
      for (final sale in todaySales) {
        final items = await DatabaseFactory.instance.getSaleItems(sale.id!);
        for (final item in items) {
          final drug = drugs.firstWhere(
            (d) => d.id == item.medicamentoId, 
            orElse: () => Drug(id: 0, nombre: '', precioCoste: 0, precioVentaMinorista: 0, precioVentaMayorista: 0, cantidad: 0)
          );
          if (drug.id != 0) {
            profitDay += (item.precioUnitario - drug.precioCoste) * item.cantidad;
          }
        }
      }
      
      for (final sale in monthSales) {
        final items = await DatabaseFactory.instance.getSaleItems(sale.id!);
        for (final item in items) {
          final drug = drugs.firstWhere(
            (d) => d.id == item.medicamentoId, 
            orElse: () => Drug(id: 0, nombre: '', precioCoste: 0, precioVentaMinorista: 0, precioVentaMayorista: 0, cantidad: 0)
          );
          if (drug.id != 0) {
            profitMonth += (item.precioUnitario - drug.precioCoste) * item.cantidad;
          }
        }
      }

      // Calculate total invested in medicines
      totalInvested = drugs.fold(0.0, (sum, drug) => sum + (drug.precioCoste * drug.cantidad));

      // Automatically add recovered money to physical money
      physicalMoney += recoveredMoneyMonth;
      _physicalMoneyController.text = physicalMoney.toString();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error cargando datos de inversión: $e');
      if (mounted) {
        context.showErrorBubble('Error cargando datos: $e');
      }
    }
  }

  Future<void> _loadStoredValues() async {
    try {
      final db = DatabaseHelper.instance;
      
      // Cargar dinero físico almacenado
      final physicalRecords = await db.getFinanceRecordsByType('dinero_fisico_manual');
      if (physicalRecords.isNotEmpty) {
        final totalPhysical = physicalRecords.fold<double>(0, (sum, record) => 
          sum + (record.esIngreso ? record.monto : -record.monto));
        physicalMoney += totalPhysical;
      }
      
      // Cargar dinero prestado almacenado
      final borrowedRecords = await db.getFinanceRecordsByType('dinero_prestado');
      if (borrowedRecords.isNotEmpty) {
        borrowedMoney = borrowedRecords.fold<double>(0, (sum, record) => 
          sum + (record.esIngreso ? record.monto : -record.monto));
      }
      
      _physicalMoneyController.text = '';
    } catch (e) {
      print('Error loading stored values: $e');
      _physicalMoneyController.text = '';
    }
  }

  Future<void> _addBorrowedMoney(double amount) async {
    try {
      final db = DatabaseHelper.instance;
      final now = DateTime.now().toIso8601String();
      
      // Agregar dinero prestado (incrementa la deuda)
      await db.insertFinanceRecord(FinanceRecord(
        tipo: 'dinero_prestado',
        monto: amount,
        esIngreso: true, // true porque aumenta el dinero prestado
        fecha: now,
        descripcion: 'Dinero prestado: ${CurrencyFormatter.formatCubanPesos(amount)}',
      ));
      
      borrowedMoney += amount;
      setState(() {});
    } catch (e) {
      print('Error adding borrowed money: $e');
      rethrow;
    }
  }
  
  Future<void> _subtractBorrowedMoney(double amount) async {
    try {
      final db = DatabaseHelper.instance;
      final now = DateTime.now().toIso8601String();
      
      // Restar dinero prestado (reduce la deuda porque te devolvieron dinero)
      await db.insertFinanceRecord(FinanceRecord(
        tipo: 'dinero_prestado',
        monto: amount,
        esIngreso: false, // false porque reduce el dinero prestado
        fecha: now,
        descripcion: 'Dinero devuelto: ${CurrencyFormatter.formatCubanPesos(amount)}',
      ));
      
      borrowedMoney -= amount;
      setState(() {});
    } catch (e) {
      print('Error subtracting borrowed money: $e');
      rethrow;
    }
  }

  double get totalMoney => physicalMoney + totalInvested - borrowedMoney; // Restar dinero prestado

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = CurrencyFormatter.isSmallScreen(screenWidth);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Dinero recuperado del día
            _buildSalesCard(
              title: 'Dinero Recuperado del Día',
              icon: Icons.today,
              salesAmount: recoveredMoneyDay,
              profitAmount: profitDay,
              theme: theme,
              isSmallScreen: isSmallScreen,
            ),
             const SizedBox(height: 16),
            
            // Dinero recuperado del mes
            _buildSalesCard(
              title: 'Dinero Recuperado del Mes',
              icon: Icons.calendar_month,
              salesAmount: recoveredMoneyMonth,
              profitAmount: profitMonth,
              theme: theme,
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 16),
            
            // Total invertido en medicinas
            _buildInvestmentCard(
              title: 'Total Invertido en Medicinas',
              icon: Icons.medical_services,
              amount: totalInvested,
              theme: theme,
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 16),
            
            // Dinero físico actual (solo lectura)
            _buildPhysicalMoneyDisplayCard(
              theme: theme,
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 16),
            
            // Agregar dinero físico
            _buildAddMoneyCard(
              theme: theme,
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 16),
            
            // Dinero prestado actual (solo lectura)
            _buildBorrowedMoneyDisplayCard(
              theme: theme,
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 16),
            
            // Agregar/Restar dinero prestado
            _buildBorrowedMoneyActionsCard(
              theme: theme,
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 16),
            
            // Total general
            _buildTotalCard(
              theme: theme,
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 12),
            
            Text(
              'Desliza hacia abajo para actualizar los datos.',
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

  Widget _buildSalesCard({
    required String title,
    required IconData icon,
    required double salesAmount,
    required double profitAmount,
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    return Card(
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
                Icon(icon, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Ventas',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatCubanPesos(salesAmount),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ganancias',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatCubanPesos(profitAmount),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentCard({
    required String title,
    required IconData icon,
    required double amount,
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    return Card(
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
                Icon(icon, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              CurrencyFormatter.formatCubanPesos(amount),
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalMoneyDisplayCard({
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    return Card(
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
                Icon(Icons.account_balance_wallet, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Dinero Físico Actual',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                CurrencyFormatter.formatCubanPesos(physicalMoney),
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este monto incluye dinero recuperado de ventas',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoneyCard({
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    final TextEditingController addMoneyController = TextEditingController();
    
    return Card(
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
                Icon(Icons.add_circle, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Agregar Dinero Físico',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addMoneyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad a agregar',
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(addMoneyController.text) ?? 0;
                    if (amount > 0) {
                      try {
                        final db = DatabaseHelper.instance;
                        final now = DateTime.now().toIso8601String();
                        
                        // Guardar en la base de datos
                        await db.insertFinanceRecord(FinanceRecord(
                          tipo: 'dinero_fisico_manual',
                          monto: amount,
                          descripcion: 'Dinero físico agregado manualmente',
                          fecha: now,
                          esIngreso: true,
                        ));
                        
                        setState(() {
                          physicalMoney += amount;
                          _physicalMoneyController.text = physicalMoney.toString();
                        });
                        addMoneyController.clear();
                        
                        context.showSuccessBubble('Se agregaron ${CurrencyFormatter.formatCubanPesos(amount)} al dinero físico');
                      } catch (e) {
                        context.showErrorBubble('Error al guardar: $e');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(addMoneyController.text) ?? 0;
                    if (amount > 0) {
                      try {
                        final db = DatabaseHelper.instance;
                        final now = DateTime.now().toIso8601String();
                        
                        // Guardar en la base de datos como egreso
                        await db.insertFinanceRecord(FinanceRecord(
                          tipo: 'dinero_fisico_manual',
                          monto: amount,
                          descripcion: 'Dinero físico restado manualmente',
                          fecha: now,
                          esIngreso: false,
                        ));
                        
                        setState(() {
                          physicalMoney -= amount;
                          _physicalMoneyController.text = physicalMoney.toString();
                        });
                        addMoneyController.clear();
                        
                        context.showSuccessBubble('Se restaron ${CurrencyFormatter.formatCubanPesos(amount)} del dinero físico');
                      } catch (e) {
                        context.showErrorBubble('Error al guardar: $e');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorrowedMoneyDisplayCard({
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    return Card(
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
                Icon(Icons.handshake, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Dinero Prestado Actual',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                CurrencyFormatter.formatCubanPesos(borrowedMoney),
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: borrowedMoney > 0 ? Colors.red : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dinero que has prestado y aún no te han devuelto',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorrowedMoneyActionsCard({
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    final TextEditingController borrowedActionController = TextEditingController();
    
    return Card(
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
                Icon(Icons.swap_horiz, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Gestionar Dinero Prestado',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: borrowedActionController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final text = borrowedActionController.text.trim();
                      if (text.isNotEmpty) {
                        try {
                          final amount = double.parse(text);
                          if (amount > 0) {
                            await _addBorrowedMoney(amount);
                            borrowedActionController.clear();
                            context.showSuccessBubble('Se agregaron ${CurrencyFormatter.formatCubanPesos(amount)} al dinero prestado');
                          }
                        } catch (e) {
                          context.showErrorBubble('Error: Ingresa un número válido');
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text(isSmallScreen ? 'Prestar' : 'Prestar Dinero'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final text = borrowedActionController.text.trim();
                      if (text.isNotEmpty) {
                        try {
                          final amount = double.parse(text);
                          if (amount > 0) {
                            await _subtractBorrowedMoney(amount);
                            borrowedActionController.clear();
                            context.showSuccessBubble('Se restaron ${CurrencyFormatter.formatCubanPesos(amount)} del dinero prestado');
                          }
                        } catch (e) {
                          context.showErrorBubble('Error: Ingresa un número válido');
                        }
                      }
                    },
                    icon: const Icon(Icons.remove),
                    label: Text(isSmallScreen ? 'Cobrar' : 'Cobrar Dinero'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Usa "Prestar" cuando des dinero y "Cobrar" cuando te lo devuelvan',
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 13,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard({
    required ThemeData theme,
    required bool isSmallScreen,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total de Dinero',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '(Sin incluir ganancias)',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                CurrencyFormatter.formatCubanPesos(totalMoney),
                style: TextStyle(
                  fontSize: isSmallScreen ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: theme.colorScheme.onPrimaryContainer.withOpacity(0.3)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Físico:',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatCubanPesos(physicalMoney),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prestado:',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatCubanPesos(borrowedMoney),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invertido:',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatCubanPesos(totalInvested),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}