
class Drug {
  final int? id;
  final String nombre;
  final double precioCoste;
  final double precioVentaMinorista;
  final double precioVentaMayorista;
  final int cantidad;

  Drug({
    this.id,
    required this.nombre,
    required this.precioCoste,
    required this.precioVentaMinorista,
    required this.precioVentaMayorista,
    required this.cantidad,
  });

  Drug copyWith({int? id, String? nombre, double? precioCoste, double? precioVentaMinorista, double? precioVentaMayorista, int? cantidad}) {
    return Drug(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precioCoste: precioCoste ?? this.precioCoste,
      precioVentaMinorista: precioVentaMinorista ?? this.precioVentaMinorista,
      precioVentaMayorista: precioVentaMayorista ?? this.precioVentaMayorista,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'precio_coste': precioCoste,
        'precio_venta_minorista': precioVentaMinorista,
        'precio_venta_mayorista': precioVentaMayorista,
        'cantidad': cantidad,
      };

  static Drug fromMap(Map<String, dynamic> m) => Drug(
        id: m['id'] as int?,
        nombre: m['nombre'] as String,
        precioCoste: (m['precio_coste'] as num).toDouble(),
        precioVentaMinorista: (m['precio_venta_minorista'] as num).toDouble(),
        precioVentaMayorista: (m['precio_venta_mayorista'] as num).toDouble(),
        cantidad: m['cantidad'] as int,
      );
}
