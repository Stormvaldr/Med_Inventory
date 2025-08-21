
class Drug {
  final int? id;
  final String nombre;
  final double precioCoste;
  final double precioVenta;
  final int cantidad;

  Drug({
    this.id,
    required this.nombre,
    required this.precioCoste,
    required this.precioVenta,
    required this.cantidad,
  });

  Drug copyWith({int? id, String? nombre, double? precioCoste, double? precioVenta, int? cantidad}) {
    return Drug(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precioCoste: precioCoste ?? this.precioCoste,
      precioVenta: precioVenta ?? this.precioVenta,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'precio_coste': precioCoste,
        'precio_venta': precioVenta,
        'cantidad': cantidad,
      };

  static Drug fromMap(Map<String, dynamic> m) => Drug(
        id: m['id'] as int?,
        nombre: m['nombre'] as String,
        precioCoste: (m['precio_coste'] as num).toDouble(),
        precioVenta: (m['precio_venta'] as num).toDouble(),
        cantidad: m['cantidad'] as int,
      );
}
