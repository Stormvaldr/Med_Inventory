
class Sale {
  final int? id;
  final String fecha; // ISO string
  final double total;
  final String nombreCliente;
  final bool esMayorista;

  Sale({this.id, required this.fecha, required this.total, required this.nombreCliente, this.esMayorista = false});

  Map<String, dynamic> toMap() => {
        'id': id,
        'fecha': fecha,
        'total': total,
        'nombre_cliente': nombreCliente,
        'es_mayorista': esMayorista ? 1 : 0,
      };

  static Sale fromMap(Map<String, dynamic> m) => Sale(
        id: m['id'] as int?,
        fecha: m['fecha'] as String,
        total: (m['total'] as num).toDouble(),
        nombreCliente: m['nombre_cliente'] as String,
        esMayorista: (m['es_mayorista'] as int?) == 1,
      );
}

class SaleItem {
  final int? id;
  final int ventaId;
  final int medicamentoId;
  final int cantidad;
  final double precioUnitario;

  SaleItem({
    this.id,
    required this.ventaId,
    required this.medicamentoId,
    required this.cantidad,
    required this.precioUnitario,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'venta_id': ventaId,
        'medicamento_id': medicamentoId,
        'cantidad': cantidad,
        'precio_unitario': precioUnitario,
      };

  static SaleItem fromMap(Map<String, dynamic> m) => SaleItem(
        id: m['id'] as int?,
        ventaId: m['venta_id'] as int,
        medicamentoId: m['medicamento_id'] as int,
        cantidad: m['cantidad'] as int,
        precioUnitario: (m['precio_unitario'] as num).toDouble(),
      );
}
