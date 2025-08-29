
import 'package:flutter/material.dart';
import '../data/database_factory.dart';
import '../models/drug.dart';
import '../theme/app_theme.dart';
import '../utils/bubble_notification.dart';

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
    final drugs = await DatabaseFactory.instance.getDrugs();
    setState(() {
      items = drugs;
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
    final newDrug = Drug(
      id: drug?.id,
      nombre: nombreCtrl.text.trim(),
      precioCoste: double.parse(costeCtrl.text),
      precioVentaMinorista: double.parse(ventaMinoristaCtrl.text),
      precioVentaMayorista: double.parse(ventaMayoristaCtrl.text),
      cantidad: int.parse(cantCtrl.text),
    );

    try {
      if (drug == null) {
        // Insertar nuevo medicamento
        await DatabaseFactory.instance.insert('medicamentos', {
          'nombre': newDrug.nombre,
          'precio_coste': newDrug.precioCoste,
          'precio_venta_minorista': newDrug.precioVentaMinorista,
          'precio_venta_mayorista': newDrug.precioVentaMayorista,
          'cantidad': newDrug.cantidad,
        });
        if (mounted) {
          context.showSuccessBubble('Medicamento agregado exitosamente');
        }
      } else {
        // Actualizar medicamento existente
        await DatabaseFactory.instance.update(
          'medicamentos',
          {
            'nombre': newDrug.nombre,
            'precio_coste': newDrug.precioCoste,
            'precio_venta_minorista': newDrug.precioVentaMinorista,
            'precio_venta_mayorista': newDrug.precioVentaMayorista,
            'cantidad': newDrug.cantidad,
          },
          'id = ?',
          [drug.id],
        );
        if (mounted) {
          context.showSuccessBubble('Medicamento actualizado exitosamente');
        }
      }
      _load();
    } catch (e) {
      if (mounted) {
        context.showErrorBubble('Error al guardar medicamento: $e');
      }
    }
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
      try {
        await DatabaseFactory.instance.delete(
          'medicamentos',
          'id = ?',
          [drug.id],
        );
        if (mounted) {
          context.showSuccessBubble('${drug.nombre} eliminado exitosamente');
        }
        _load();
      } catch (e) {
        if (mounted) {
          context.showErrorBubble('Error al eliminar medicamento: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (loading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.getInventoryAccentColor(isDarkMode),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: _buildModernFAB(context, isDarkMode),
      body: items.isEmpty
          ? _buildEmptyState(context, isDarkMode)
          : _buildInventoryGrid(context, isDarkMode),
    );
  }

  Widget _buildModernFAB(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getInventoryCardShadow(isDarkMode),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _upsertDrug(),
        backgroundColor: AppTheme.getInventoryAccentColor(isDarkMode),
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Agregar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.getInventoryAccentColor(isDarkMode).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.getInventoryAccentColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay medicamentos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.getInventoryTextColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pulsa el botón + para agregar tu primer medicamento',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.getInventoryTextSecondaryColor(isDarkMode),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid(BuildContext context, bool isDarkMode) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final drug = items[index];
        final totalInvestment = drug.precioCoste * drug.cantidad;
        
        return _buildDrugListItem(context, drug, totalInvestment, isDarkMode);
      },
    );
  }

  Widget _buildDrugListItem(BuildContext context, Drug drug, double totalInvestment, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getInventoryCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getInventoryCardShadow(isDarkMode),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _upsertDrug(drug),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono de medicamento
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.getInventoryAccentColor(isDarkMode).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: AppTheme.getInventoryAccentColor(isDarkMode),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drug.nombre,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getInventoryTextColor(isDarkMode),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildCompactChip(
                            'Stock: ${drug.cantidad}',
                            drug.cantidad > 10 
                              ? AppTheme.getInventorySuccessColor(isDarkMode)
                              : drug.cantidad > 5
                                ? AppTheme.getInventoryWarningColor(isDarkMode)
                                : AppTheme.getInventoryDangerColor(isDarkMode),
                            isDarkMode,
                          ),
                          const SizedBox(width: 8),
                          _buildCompactChip(
                            'Inv: \$${totalInvestment.toStringAsFixed(0)}',
                            AppTheme.getInventorySecondaryColor(isDarkMode),
                            isDarkMode,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactPriceInfo('Coste', drug.precioCoste, isDarkMode),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactPriceInfo('Minorista', drug.precioVentaMinorista, isDarkMode),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactPriceInfo('Mayorista', drug.precioVentaMayorista, isDarkMode),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Menú de opciones
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'edit') _upsertDrug(drug);
                    if (val == 'del') _deleteDrug(drug);
                  },
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: AppTheme.getInventoryTextSecondaryColor(isDarkMode),
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 20, color: AppTheme.getInventorySecondaryColor(isDarkMode)),
                          const SizedBox(width: 8),
                          const Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'del',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, size: 20, color: AppTheme.getInventoryDangerColor(isDarkMode)),
                          const SizedBox(width: 8),
                          const Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactChip(String text, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCompactPriceInfo(String label, double price, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.getInventoryTextSecondaryColor(isDarkMode),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.getInventoryTextColor(isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.getInventoryTextSecondaryColor(isDarkMode),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.getInventoryTextSecondaryColor(isDarkMode),
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.getInventoryTextColor(isDarkMode),
          ),
        ),
      ],
    );
  }
}
