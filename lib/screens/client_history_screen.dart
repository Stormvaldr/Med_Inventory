import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/database_factory.dart';
import '../utils/bubble_notification.dart';

class ClientHistoryScreen extends StatefulWidget {
  final String clientName;
  
  const ClientHistoryScreen({super.key, required this.clientName});

  @override
  State<ClientHistoryScreen> createState() => _ClientHistoryScreenState();
}

class _ClientHistoryScreenState extends State<ClientHistoryScreen> {
  List<Map<String, dynamic>> purchases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientHistory();
  }

  Future<void> _loadClientHistory() async {
    try {
      final sales = await DatabaseFactory.instance.getSales();
      
      // Filter sales for this client
      final clientSales = sales.where((sale) => sale.nombreCliente == widget.clientName).toList();
      
      // Get sale items for each sale and build the result
      final List<Map<String, dynamic>> result = [];
      for (final sale in clientSales) {
        final items = await DatabaseFactory.instance.getSaleItems(sale.id!);
        for (final item in items) {
          result.add({
            'venta_id': sale.id,
            'fecha': sale.fecha,
            'total': sale.total,
            'es_mayorista': sale.esMayorista ? 1 : 0,
            'cantidad': item.cantidad,
            'precio_unitario': item.precioUnitario,
            'medicamento_nombre': item.nombre,
          });
        }
      }
      
      setState(() {
        purchases = result;
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando historial del cliente: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        context.showErrorBubble('Error cargando historial: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header personalizado
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial de Cliente',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.clientName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.person,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ],
              ),
            ),
            
            // Contenido principal
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : purchases.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 64,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay compras registradas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'para este cliente',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadClientHistory,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _getUniqueVentas().length,
                            itemBuilder: (context, index) {
                              final venta = _getUniqueVentas()[index];
                              final ventaItems = purchases
                                  .where((p) => p['venta_id'] == venta['venta_id'])
                                  .toList();
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ExpansionTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  collapsedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '#${venta['venta_id']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.primary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.receipt_long,
                                            size: 20,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.secondary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          currencyFormat.format(venta['total']),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.secondary,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: theme.colorScheme.outline,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          dateFormat.format(DateTime.parse(venta['fecha'])),
                                          style: TextStyle(
                                            color: theme.colorScheme.outline,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: venta['es_mayorista'] == 1 
                                                ? theme.colorScheme.tertiary.withOpacity(0.1)
                                                : theme.colorScheme.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            venta['es_mayorista'] == 1 ? 'Mayorista' : 'Minorista',
                                            style: TextStyle(
                                              color: venta['es_mayorista'] == 1 
                                                  ? theme.colorScheme.tertiary
                                                  : theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.colorScheme.outline.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                topRight: Radius.circular(12),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.shopping_bag,
                                                  color: theme.colorScheme.onPrimaryContainer,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Detalles de la compra',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: theme.colorScheme.onPrimaryContainer,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Table(
                                              border: TableBorder.symmetric(
                                                inside: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
                                              ),
                                              columnWidths: const {
                                                0: FlexColumnWidth(3),
                                                1: FlexColumnWidth(1),
                                                2: FlexColumnWidth(1.5),
                                                3: FlexColumnWidth(1.5),
                                              },
                                              children: [
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                                                    borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(8),
                                                      topRight: Radius.circular(8),
                                                    ),
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(12),
                                                      child: Text(
                                                        'Medicamento',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: theme.colorScheme.onSecondaryContainer,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(12),
                                                      child: Text(
                                                        'Cant.',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: theme.colorScheme.onSecondaryContainer,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(12),
                                                      child: Text(
                                                        'Precio Unit.',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: theme.colorScheme.onSecondaryContainer,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(12),
                                                      child: Text(
                                                        'Subtotal',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: theme.colorScheme.onSecondaryContainer,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ...ventaItems.map((item) => TableRow(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(12),
                                                      child: Text(
                                                        item['medicamento_nombre'],
                                                        style: TextStyle(
                                                          color: theme.colorScheme.onSurface,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(12),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          '${item['cantidad']}',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            color: theme.colorScheme.primary,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(12),
                                                      child: Text(
                                                        currencyFormat.format(item['precio_unitario']),
                                                        style: TextStyle(
                                                          color: theme.colorScheme.onSurface,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(12),
                                                      child: Text(
                                                        currencyFormat.format(item['cantidad'] * item['precio_unitario']),
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: theme.colorScheme.secondary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )).toList(),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: FilledButton.icon(
                                              onPressed: () => _deleteSaleFromHistory(venta['venta_id']),
                                              icon: const Icon(Icons.delete),
                                              label: const Text('Eliminar venta'),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                   ],
                                 ),
                               );
                             },
                           ),
                         ),
             ),
           ],
         ),
       ),
    );
  }
  
  Future<void> _deleteSaleFromHistory(int ventaId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la venta #$ventaId?\n\n'
          'Esta acción restaurará el stock de los medicamentos vendidos y no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseFactory.instance.deleteSale(ventaId);
        
        // Recargar el historial del cliente
        await _loadClientHistory();
        
        if (mounted) {
          context.showSuccessBubble('Venta #$ventaId eliminada correctamente');
        }
      } catch (e) {
        if (mounted) {
          context.showErrorBubble('Error al eliminar la venta: $e');
        }
      }
    }
  }

  List<Map<String, dynamic>> _getUniqueVentas() {
    final Map<int, Map<String, dynamic>> uniqueVentas = {};
    
    for (final purchase in purchases) {
      final ventaId = purchase['venta_id'] as int;
      if (!uniqueVentas.containsKey(ventaId)) {
        uniqueVentas[ventaId] = {
          'venta_id': purchase['venta_id'],
          'fecha': purchase['fecha'],
          'total': purchase['total'],
          'es_mayorista': purchase['es_mayorista'],
        };
      }
    }
    
    return uniqueVentas.values.toList();
  }
}