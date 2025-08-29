import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database_factory.dart';
import '../models/finance.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/bubble_notification.dart';

class FinanceDetailScreen extends StatefulWidget {
  final String type;
  final String title;
  final Color color;

  const FinanceDetailScreen({
    super.key,
    required this.type,
    required this.title,
    required this.color,
  });

  @override
  State<FinanceDetailScreen> createState() => _FinanceDetailScreenState();
}

class _FinanceDetailScreenState extends State<FinanceDetailScreen> {
  List<FinanceRecord> _records = [];
  bool _isLoading = true;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      List<FinanceRecord> records;
      if (widget.type == 'inversion') {
        // Para inversión, calculamos desde los medicamentos
        final invested = await DatabaseFactory.instance.calculateInvestedAmount();
        setState(() {
          _records = [];
          _total = invested;
          _isLoading = false;
        });
        return;
      } else {
        records = await DatabaseFactory.instance.getFinanceRecordsByType(widget.type);
      }
      
      double total = 0.0;
      for (final record in records) {
        total += record.esIngreso ? record.monto : -record.monto;
      }
      
      setState(() {
        _records = records;
        _total = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorBubble('Error al cargar registros: $e');
      }
    }
  }

  Future<void> _showAddRecordDialog() async {
    if (widget.type == 'inversion') {
      context.showInfoBubble('La inversión se calcula automáticamente desde el inventario');
      return;
    }

    final result = await showDialog<FinanceRecord>(
      context: context,
      builder: (context) => _AddRecordDialog(
        type: widget.type,
        title: widget.title,
        color: widget.color,
      ),
    );

    if (result != null) {
      await DatabaseFactory.instance.insertFinanceRecord(result);
      _loadRecords();
    }
  }

  Future<void> _deleteRecord(FinanceRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar este registro de ${record.descripcion}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && record.id != null) {
      await DatabaseFactory.instance.deleteFinanceRecord(record.id!);
      _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = AppTheme.getTheme(themeProvider.isDarkMode);
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(widget.title),
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          floatingActionButton: widget.type != 'inversion'
              ? FloatingActionButton(
                  onPressed: _showAddRecordDialog,
                  backgroundColor: widget.color,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildHeader(theme),
                    Expanded(
                      child: _buildRecordsList(theme),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Total',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_total.toStringAsFixed(2)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.type == 'inversion') ...[
            const SizedBox(height: 8),
            Text(
              'Calculado automáticamente desde el inventario',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordsList(ThemeData theme) {
    if (widget.type == 'inversion') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 64,
                color: widget.color.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Inversión Automática',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'El monto invertido se calcula automáticamente basado en el costo y cantidad de medicamentos en tu inventario.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: widget.color.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay registros',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: widget.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega tu primer registro tocando el botón +',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          return _buildRecordCard(theme, record);
        },
      ),
    );
  }

  Widget _buildRecordCard(ThemeData theme, FinanceRecord record) {
    final isIncome = record.esIngreso;
    final amount = record.monto;
    final date = DateTime.parse(record.fecha);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isIncome ? Icons.add : Icons.remove,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          record.descripcion,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${date.day}/${date.month}/${date.year}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: () => _deleteRecord(record),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRecordDialog extends StatefulWidget {
  final String type;
  final String title;
  final Color color;

  const _AddRecordDialog({
    required this.type,
    required this.title,
    required this.color,
  });

  @override
  State<_AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends State<_AddRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();
  bool _esIngreso = true;

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = AppTheme.getTheme(themeProvider.isDarkMode);
        
        return AlertDialog(
          title: Text('Agregar ${widget.title}'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa una descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _montoController,
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un monto';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Ingresa un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Ingreso'),
                        value: true,
                        groupValue: _esIngreso,
                        onChanged: (value) => setState(() => _esIngreso = value!),
                        activeColor: widget.color,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Egreso'),
                        value: false,
                        groupValue: _esIngreso,
                        onChanged: (value) => setState(() => _esIngreso = value!),
                        activeColor: widget.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _saveRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      final record = FinanceRecord(
        tipo: widget.type,
        descripcion: _descripcionController.text.trim(),
        monto: double.parse(_montoController.text),
        esIngreso: _esIngreso,
        fecha: DateTime.now().toIso8601String(),
      );
      Navigator.pop(context, record);
    }
  }
}