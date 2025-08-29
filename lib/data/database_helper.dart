
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/drug.dart';
import '../models/sale.dart';
import '../models/finance.dart';
import 'database_factory.dart';

class DatabaseHelper implements DatabaseInterface {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'med_sales.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE medicamentos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            precio_coste REAL NOT NULL,
            precio_venta_minorista REAL NOT NULL,
            precio_venta_mayorista REAL NOT NULL,
            cantidad INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE ventas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha TEXT NOT NULL,
            total REAL NOT NULL,
            nombre_cliente TEXT NOT NULL,
            es_mayorista INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE detalle_ventas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            venta_id INTEGER NOT NULL,
            medicamento_id INTEGER NOT NULL,
            cantidad INTEGER NOT NULL,
            precio_unitario REAL NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE finanzas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT NOT NULL,
            monto REAL NOT NULL,
            descripcion TEXT NOT NULL,
            fecha TEXT NOT NULL,
            es_ingreso INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migrar de versión 1 a 2: eliminar envío y agregar nombre_cliente
          await db.execute('ALTER TABLE ventas ADD COLUMN nombre_cliente TEXT DEFAULT "Cliente"');
          await db.execute('CREATE TABLE ventas_new AS SELECT id, fecha, total, nombre_cliente FROM ventas');
          await db.execute('DROP TABLE ventas');
          await db.execute('ALTER TABLE ventas_new RENAME TO ventas');
        }
        if (oldVersion < 3) {
          // Migrar de versión 2 a 3: agregar precios mayorista y minorista
          await db.execute('ALTER TABLE medicamentos ADD COLUMN precio_venta_minorista REAL DEFAULT 0');
          await db.execute('ALTER TABLE medicamentos ADD COLUMN precio_venta_mayorista REAL DEFAULT 0');
          // Copiar el precio_venta existente a precio_venta_minorista
          await db.execute('UPDATE medicamentos SET precio_venta_minorista = precio_venta');
          await db.execute('UPDATE medicamentos SET precio_venta_mayorista = precio_venta');
          // Eliminar la columna precio_venta antigua
          await db.execute('''
            CREATE TABLE medicamentos_new(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              precio_coste REAL NOT NULL,
              precio_venta_minorista REAL NOT NULL,
              precio_venta_mayorista REAL NOT NULL,
              cantidad INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            INSERT INTO medicamentos_new (id, nombre, precio_coste, precio_venta_minorista, precio_venta_mayorista, cantidad)
            SELECT id, nombre, precio_coste, precio_venta_minorista, precio_venta_mayorista, cantidad FROM medicamentos
          ''');
          await db.execute('DROP TABLE medicamentos');
          await db.execute('ALTER TABLE medicamentos_new RENAME TO medicamentos');
        }
        if (oldVersion < 4) {
          // Migrar de versión 3 a 4: agregar campo es_mayorista a ventas
          await db.execute('ALTER TABLE ventas ADD COLUMN es_mayorista INTEGER DEFAULT 0');
        }
        if (oldVersion < 5) {
          // Migrar de versión 4 a 5: agregar tabla de finanzas
          await db.execute('''
            CREATE TABLE finanzas(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              tipo TEXT NOT NULL,
              monto REAL NOT NULL,
              descripcion TEXT NOT NULL,
              fecha TEXT NOT NULL,
              es_ingreso INTEGER NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future<List<Sale>> getSales() async {
    final db = await database;
    final result = await db.query('ventas', orderBy: 'fecha DESC');
    return result.map((map) => Sale.fromMap(map)).toList();
  }

  Future<List<SaleItemWithName>> getSaleItems(int ventaId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT dv.*, m.nombre
      FROM detalle_ventas dv
      JOIN medicamentos m ON m.id = dv.medicamento_id
      WHERE dv.venta_id = ?
      ORDER BY m.nombre
    ''', [ventaId]);
    
    return result.map((map) => SaleItemWithName.fromMap(map)).toList();
  }

  Future<void> deleteSale(int ventaId) async {
    final db = await database;
    await db.transaction((txn) async {
      // Primero obtener los items de la venta para restaurar el stock
      final items = await txn.rawQuery('''
        SELECT dv.medicamento_id, dv.cantidad
        FROM detalle_ventas dv
        WHERE dv.venta_id = ?
      ''', [ventaId]);
      
      // Restaurar el stock de cada medicamento
      for (final item in items) {
        final medicamentoId = item['medicamento_id'] as int;
        final cantidad = item['cantidad'] as int;
        await txn.rawUpdate('''
          UPDATE medicamentos 
          SET cantidad = cantidad + ?
          WHERE id = ?
        ''', [cantidad, medicamentoId]);
      }
      
      // Eliminar los detalles de la venta
      await txn.delete('detalle_ventas', where: 'venta_id = ?', whereArgs: [ventaId]);
      
      // Eliminar la venta
      await txn.delete('ventas', where: 'id = ?', whereArgs: [ventaId]);
    });
  }

  // Métodos para gestión financiera
  Future<int> insertFinanceRecord(FinanceRecord record) async {
    final db = await database;
    return await db.insert('finanzas', record.toMap());
  }

  Future<List<FinanceRecord>> getFinanceRecords() async {
    final db = await database;
    final result = await db.query('finanzas', orderBy: 'fecha DESC');
    return result.map((map) => FinanceRecord.fromMap(map)).toList();
  }

  Future<List<FinanceRecord>> getFinanceRecordsByType(String tipo) async {
    final db = await database;
    final result = await db.query(
      'finanzas',
      where: 'tipo = ?',
      whereArgs: [tipo],
      orderBy: 'fecha DESC',
    );
    return result.map((map) => FinanceRecord.fromMap(map)).toList();
  }

  Future<void> updateFinanceRecord(FinanceRecord record) async {
    final db = await database;
    await db.update(
      'finanzas',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteFinanceRecord(int id) async {
    final db = await database;
    await db.delete('finanzas', where: 'id = ?', whereArgs: [id]);
  }

  Future<FinanceSummary> getFinanceSummary() async {
    final records = await getFinanceRecords();
    return FinanceSummary.fromRecords(records);
  }

  Future<List<Drug>> getDrugs() async {
    final db = await database;
    final result = await db.query('medicamentos', orderBy: 'nombre');
    return result.map((map) => Drug.fromMap(map)).toList();
  }

  Future<double> calculateInvestedAmount() async {
    final drugs = await getDrugs();
    return InvestmentCalculator.calculateInvestedAmount(drugs);
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  @override
  Future<void> update(String table, Map<String, dynamic> data, String where, List<dynamic> whereArgs) async {
    final db = await database;
    await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    await db.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> saveSale({
    required String fecha,
    required double total,
    required String nombreCliente,
    required bool esMayorista,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await database;
    late int ventaId;
    
    await db.transaction((txn) async {
      // Insert sale
      ventaId = await txn.insert('ventas', {
        'fecha': fecha,
        'total': total,
        'nombre_cliente': nombreCliente,
        'es_mayorista': esMayorista ? 1 : 0,
      });

      // Insert sale items and update stock
      for (final item in items) {
        await txn.insert('detalle_ventas', {
          'venta_id': ventaId,
          'medicamento_id': item['medicamento_id'],
          'cantidad': item['cantidad'],
          'precio_unitario': item['precio_unitario'],
        });
        
        // Update drug stock
        await txn.rawUpdate(
          'UPDATE medicamentos SET cantidad = cantidad - ? WHERE id = ?',
          [item['cantidad'], item['medicamento_id']],
        );
      }
    });
    
    return ventaId;
  }
}

class SaleItemWithName {
  final int? id;
  final int ventaId;
  final int medicamentoId;
  final int cantidad;
  final double precioUnitario;
  final String nombre;

  SaleItemWithName({
    this.id,
    required this.ventaId,
    required this.medicamentoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.nombre,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'venta_id': ventaId,
        'medicamento_id': medicamentoId,
        'cantidad': cantidad,
        'precio_unitario': precioUnitario,
        'nombre': nombre,
      };

  static SaleItemWithName fromMap(Map<String, dynamic> m) => SaleItemWithName(
        id: m['id'] as int?,
        ventaId: m['venta_id'] as int,
        medicamentoId: m['medicamento_id'] as int,
        cantidad: m['cantidad'] as int,
        precioUnitario: (m['precio_unitario'] as num).toDouble(),
        nombre: m['nombre'] as String,
      );
}
