import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import 'database_helper_web.dart' if (dart.library.io) 'database_helper.dart';
import '../models/drug.dart';
import '../models/sale.dart';
import '../models/finance.dart';

abstract class DatabaseInterface {
  Future<List<Drug>> getDrugs();
  Future<List<Sale>> getSales();
  Future<List<FinanceRecord>> getFinanceRecords();
  Future<List<FinanceRecord>> getFinanceRecordsByType(String tipo);
  Future<int> insertFinanceRecord(FinanceRecord record);
  Future<void> updateFinanceRecord(FinanceRecord record);
  Future<void> deleteFinanceRecord(int id);
  Future<FinanceSummary> getFinanceSummary();
  Future<double> calculateInvestedAmount();
  Future<List<SaleItemWithName>> getSaleItems(int ventaId);
  Future<void> deleteSale(int ventaId);
  Future<int> insert(String table, Map<String, dynamic> data);
  Future<void> update(String table, Map<String, dynamic> data, String where, List<dynamic> whereArgs);
  Future<void> delete(String table, String where, List<dynamic> whereArgs);
  Future<int> saveSale({
    required String fecha,
    required double total,
    required String nombreCliente,
    required bool esMayorista,
    required List<Map<String, dynamic>> items,
  });
}

class DatabaseFactory {
  static DatabaseInterface? _instance;
  
  static DatabaseInterface get instance {
    if (_instance == null) {
      if (kIsWeb) {
        // This will only be used in web builds
        throw UnsupportedError('Web not supported in mobile build');
      } else {
        _instance = DatabaseHelper.instance as DatabaseInterface;
      }
    }
    return _instance!;
  }
  
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Web initialization not supported in mobile build
      throw UnsupportedError('Web not supported in mobile build');
    } else {
      // Para móvil/desktop, la inicialización se hace automáticamente
      await DatabaseHelper.instance.database;
    }
  }
}