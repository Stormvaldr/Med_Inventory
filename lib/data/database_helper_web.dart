import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
// Conditional import for web
import 'dart:html' as html if (dart.library.io) 'dart:io';
import '../models/sale.dart';
import '../models/finance.dart';
import '../models/drug.dart';
import 'database_factory.dart';
import 'database_helper.dart' show SaleItemWithName;

class DatabaseHelperWeb implements DatabaseInterface {
  static final DatabaseHelperWeb instance = DatabaseHelperWeb._internal();
  DatabaseHelperWeb._internal();

  static const String _drugsKey = 'pinguimed_drugs';
  static const String _salesKey = 'pinguimed_sales';
  static const String _financeKey = 'pinguimed_finance';
  static const String _saleItemsKey = 'pinguimed_sale_items';

  // Métodos para medicamentos/drugs
  Future<List<Drug>> getDrugs() async {
    try {
      final drugsJson = html.window.localStorage[_drugsKey];
      if (drugsJson == null) return [];
      
      final List<dynamic> drugsList = json.decode(drugsJson);
      return drugsList.map((map) => Drug.fromMap(Map<String, dynamic>.from(map))).toList();
    } catch (e) {
      print('Error loading drugs: $e');
      return [];
    }
  }

  Future<void> saveDrugs(List<Drug> drugs) async {
    try {
      final drugsJson = json.encode(drugs.map((drug) => drug.toMap()).toList());
      html.window.localStorage[_drugsKey] = drugsJson;
    } catch (e) {
      print('Error saving drugs: $e');
    }
  }

  // Métodos para ventas
  Future<List<Sale>> getSales() async {
    try {
      final salesJson = html.window.localStorage[_salesKey];
      if (salesJson == null) return [];
      
      final List<dynamic> salesList = json.decode(salesJson);
      return salesList.map((map) => Sale.fromMap(Map<String, dynamic>.from(map))).toList();
    } catch (e) {
      print('Error loading sales: $e');
      return [];
    }
  }

  Future<void> saveSales(List<Sale> sales) async {
    try {
      final salesJson = json.encode(sales.map((sale) => sale.toMap()).toList());
      html.window.localStorage[_salesKey] = salesJson;
    } catch (e) {
      print('Error saving sales: $e');
    }
  }

  // Métodos para finanzas
  Future<List<FinanceRecord>> getFinanceRecords() async {
    try {
      final financeJson = html.window.localStorage[_financeKey];
      if (financeJson == null) return [];
      
      final List<dynamic> financeList = json.decode(financeJson);
      return financeList.map((map) => FinanceRecord.fromMap(Map<String, dynamic>.from(map))).toList();
    } catch (e) {
      print('Error loading finance records: $e');
      return [];
    }
  }

  Future<void> saveFinanceRecords(List<FinanceRecord> records) async {
    try {
      final financeJson = json.encode(records.map((record) => record.toMap()).toList());
      html.window.localStorage[_financeKey] = financeJson;
    } catch (e) {
      print('Error saving finance records: $e');
    }
  }

  Future<List<FinanceRecord>> getFinanceRecordsByType(String tipo) async {
    final allRecords = await getFinanceRecords();
    return allRecords.where((record) => record.tipo == tipo).toList();
  }

  Future<int> insertFinanceRecord(FinanceRecord record) async {
    final records = await getFinanceRecords();
    final newId = records.isEmpty ? 1 : records.map((r) => r.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    final newRecord = record.copyWith(id: newId);
    records.add(newRecord);
    await saveFinanceRecords(records);
    return newId;
  }

  Future<void> updateFinanceRecord(FinanceRecord record) async {
    final records = await getFinanceRecords();
    final index = records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      records[index] = record;
      await saveFinanceRecords(records);
    }
  }

  Future<void> deleteFinanceRecord(int id) async {
    final records = await getFinanceRecords();
    records.removeWhere((record) => record.id == id);
    await saveFinanceRecords(records);
  }

  Future<FinanceSummary> getFinanceSummary() async {
    final records = await getFinanceRecords();
    return FinanceSummary.fromRecords(records);
  }

  Future<double> calculateInvestedAmount() async {
    final drugs = await getDrugs();
    return InvestmentCalculator.calculateInvestedAmount(drugs);
  }

  // Métodos para items de venta
  Future<List<SaleItemWithName>> getSaleItems(int ventaId) async {
    try {
      final saleItemsJson = html.window.localStorage[_saleItemsKey];
      if (saleItemsJson == null) return [];
      
      final Map<String, dynamic> allSaleItems = json.decode(saleItemsJson);
      final List<dynamic>? items = allSaleItems[ventaId.toString()];
      if (items == null) return [];
      
      return items.map((map) => SaleItemWithName.fromMap(Map<String, dynamic>.from(map))).toList();
    } catch (e) {
      print('Error loading sale items: $e');
      return [];
    }
  }

  Future<void> saveSaleItems(int ventaId, List<SaleItemWithName> items) async {
    try {
      final saleItemsJson = html.window.localStorage[_saleItemsKey] ?? '{}';
      final Map<String, dynamic> allSaleItems = json.decode(saleItemsJson);
      allSaleItems[ventaId.toString()] = items.map((item) => item.toMap()).toList();
      html.window.localStorage[_saleItemsKey] = json.encode(allSaleItems);
    } catch (e) {
      print('Error saving sale items: $e');
    }
  }

  Future<void> deleteSale(int ventaId) async {
    // Obtener items de la venta para restaurar stock
    final items = await getSaleItems(ventaId);
    final drugs = await getDrugs();
    
    // Restaurar stock
    for (final item in items) {
      final drugIndex = drugs.indexWhere((drug) => drug.id == item.medicamentoId);
      if (drugIndex != -1) {
        final updatedDrug = drugs[drugIndex].copyWith(
          cantidad: drugs[drugIndex].cantidad + item.cantidad,
        );
        drugs[drugIndex] = updatedDrug;
      }
    }
    
    // Guardar drugs actualizados
    await saveDrugs(drugs);
    
    // Eliminar items de la venta
    final saleItemsJson = html.window.localStorage[_saleItemsKey] ?? '{}';
    final Map<String, dynamic> allSaleItems = json.decode(saleItemsJson);
    allSaleItems.remove(ventaId.toString());
    html.window.localStorage[_saleItemsKey] = json.encode(allSaleItems);
    
    // Eliminar la venta
    final sales = await getSales();
    sales.removeWhere((sale) => sale.id == ventaId);
    await saveSales(sales);
  }

  // Método para inicializar datos de ejemplo si no existen
  Future<void> initializeDefaultData() async {
    final drugs = await getDrugs();
    if (drugs.isEmpty) {
      final defaultDrugs = [
        Drug(
          id: 1,
          nombre: 'Paracetamol 500mg',
          precioCoste: 0.50,
          precioVentaMinorista: 1.00,
          precioVentaMayorista: 0.80,
          cantidad: 100,
        ),
        Drug(
          id: 2,
          nombre: 'Ibuprofeno 400mg',
          precioCoste: 0.75,
          precioVentaMinorista: 1.50,
          precioVentaMayorista: 1.20,
          cantidad: 50,
        ),
        Drug(
          id: 3,
          nombre: 'Amoxicilina 500mg',
          precioCoste: 2.00,
          precioVentaMinorista: 4.00,
          precioVentaMayorista: 3.20,
          cantidad: 30,
        ),
      ];
      await saveDrugs(defaultDrugs);
    }
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> data) async {
    // For web implementation, we'll handle specific tables
    if (table == 'medicamentos') {
      final drugs = await getDrugs();
      final newId = drugs.isEmpty ? 1 : drugs.map((d) => d.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      final newDrug = Drug.fromMap({...data, 'id': newId});
      drugs.add(newDrug);
      await saveDrugs(drugs);
      return newId;
    }
    // Add other table handling as needed
    return 0;
  }

  @override
  Future<void> update(String table, Map<String, dynamic> data, String where, List<dynamic> whereArgs) async {
    if (table == 'medicamentos' && where.contains('id = ?')) {
      final drugs = await getDrugs();
      final id = whereArgs.first as int;
      final index = drugs.indexWhere((drug) => drug.id == id);
      if (index != -1) {
        final updatedDrug = Drug.fromMap({...drugs[index].toMap(), ...data});
        drugs[index] = updatedDrug;
        await saveDrugs(drugs);
      }
    }
  }

  @override
  Future<void> delete(String table, String where, List<dynamic> whereArgs) async {
    if (table == 'medicamentos' && where.contains('id = ?')) {
      final drugs = await getDrugs();
      final id = whereArgs.first as int;
      drugs.removeWhere((drug) => drug.id == id);
      await saveDrugs(drugs);
    }
    // Add other table handling as needed
  }

  @override
  Future<int> saveSale({
    required String fecha,
    required double total,
    required String nombreCliente,
    required bool esMayorista,
    required List<Map<String, dynamic>> items,
  }) async {
    final sales = await getSales();
    final newId = sales.isEmpty ? 1 : sales.map((s) => s.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    
    // Create new sale
    final newSale = Sale(
      id: newId,
      fecha: fecha,
      total: total,
      nombreCliente: nombreCliente,
      esMayorista: esMayorista,
    );
    
    sales.add(newSale);
    await saveSales(sales);
    
    // Save sale items
    final saleItems = items.map((item) => SaleItemWithName(
      ventaId: newId,
      medicamentoId: item['medicamento_id'],
      cantidad: item['cantidad'],
      precioUnitario: item['precio_unitario'],
      nombre: item['nombre'] ?? '',
    )).toList();
    
    await saveSaleItems(newId, saleItems);
    
    // Update drug stock
    final drugs = await getDrugs();
    for (final item in items) {
      final drugIndex = drugs.indexWhere((drug) => drug.id == item['medicamento_id']);
      if (drugIndex != -1) {
        final updatedDrug = drugs[drugIndex].copyWith(
          cantidad: drugs[drugIndex].cantidad - (item['cantidad'] as int),
        );
        drugs[drugIndex] = updatedDrug;
      }
    }
    await saveDrugs(drugs);
    
    return newId;
  }
}