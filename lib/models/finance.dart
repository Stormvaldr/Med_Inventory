import 'drug.dart';
import 'sale.dart';

class FinanceRecord {
  final int? id;
  final String tipo; // 'inversion', 'fisico', 'utilidad', 'prestamo'
  final double monto;
  final String descripcion;
  final String fecha; // ISO string
  final bool esIngreso; // true para ingresos, false para egresos

  FinanceRecord({
    this.id,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    required this.esIngreso,
  });

  FinanceRecord copyWith({
    int? id,
    String? tipo,
    double? monto,
    String? descripcion,
    String? fecha,
    bool? esIngreso,
  }) {
    return FinanceRecord(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      monto: monto ?? this.monto,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      esIngreso: esIngreso ?? this.esIngreso,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'tipo': tipo,
        'monto': monto,
        'descripcion': descripcion,
        'fecha': fecha,
        'es_ingreso': esIngreso ? 1 : 0,
      };

  static FinanceRecord fromMap(Map<String, dynamic> m) => FinanceRecord(
        id: m['id'] as int?,
        tipo: m['tipo'] as String,
        monto: (m['monto'] as num).toDouble(),
        descripcion: m['descripcion'] as String,
        fecha: m['fecha'] as String,
        esIngreso: (m['es_ingreso'] as int?) == 1,
      );
}

class FinanceSummary {
  final double dineroInvertido;
  final double dineroFisico;
  final double utilidades;
  final double prestamos;
  final double totalDisponible;
  final double totalPatrimonio;

  FinanceSummary({
    required this.dineroInvertido,
    required this.dineroFisico,
    required this.utilidades,
    required this.prestamos,
    required this.totalDisponible,
    required this.totalPatrimonio,
  });

  factory FinanceSummary.fromRecords(List<FinanceRecord> records) {
    double inversion = 0;
    double fisico = 0;
    double utilidad = 0;
    double prestamo = 0;

    for (final record in records) {
      final monto = record.esIngreso ? record.monto : -record.monto;
      
      switch (record.tipo) {
        case 'inversion':
          inversion += monto;
          break;
        case 'fisico':
          fisico += monto;
          break;
        case 'utilidad':
          utilidad += monto;
          break;
        case 'prestamo':
          prestamo += monto;
          break;
      }
    }

    final totalDisponible = fisico + utilidad;
    final totalPatrimonio = inversion + fisico + utilidad + prestamo;

    return FinanceSummary(
      dineroInvertido: inversion,
      dineroFisico: fisico,
      utilidades: utilidad,
      prestamos: prestamo,
      totalDisponible: totalDisponible,
      totalPatrimonio: totalPatrimonio,
    );
  }
}

class InvestmentCalculator {
  static double calculateInvestedAmount(List<Drug> drugs) {
    return drugs.fold(0.0, (sum, drug) => sum + (drug.precioCoste * drug.cantidad));
  }

  static double calculatePotentialProfit(List<Drug> drugs, bool esMayorista) {
    return drugs.fold(0.0, (sum, drug) {
      final precioVenta = esMayorista ? drug.precioVentaMayorista : drug.precioVentaMinorista;
      final ganancia = (precioVenta - drug.precioCoste) * drug.cantidad;
      return sum + ganancia;
    });
  }

  static double calculateProfitFromSales(List<Sale> sales, List<Drug> drugs) {
    // Esta función calculará las ganancias reales basadas en las ventas
    // Por ahora retornamos 0, se implementará cuando tengamos más detalles de ventas
    return 0.0;
  }
}