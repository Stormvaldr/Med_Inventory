// Test básico para la aplicación PinguiMed
//
// Este test verifica que los componentes básicos funcionen correctamente

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/drug.dart';
import '../lib/models/sale.dart';

void main() {

  group('Model Tests', () {
    test('Drug model creates correctly', () {
      final drug = Drug(
        id: 1,
        nombre: 'Medicamento Test',
        precioCoste: 15.0,
        precioVentaMinorista: 25.50,
        precioVentaMayorista: 20.0,
        cantidad: 10,
      );
      
      expect(drug.nombre, 'Medicamento Test');
      expect(drug.cantidad, 10);
      expect(drug.precioVentaMinorista, 25.50);
      expect(drug.precioVentaMayorista, 20.0);
      expect(drug.id, 1);
    });

    test('Sale model creates correctly', () {
      final sale = Sale(
        id: 1,
        fecha: DateTime.now().toIso8601String(),
        total: 51.0,
        nombreCliente: 'Cliente Test',
        esMayorista: false,
      );
      
      expect(sale.nombreCliente, 'Cliente Test');
      expect(sale.total, 51.0);
      expect(sale.esMayorista, false);
      expect(sale.id, 1);
    });
  });

  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Test a simple widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Test App'),
        ),
      ),
    );

    expect(find.text('Test App'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
