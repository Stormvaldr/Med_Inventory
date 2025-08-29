import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _cubanPesoFormatter = NumberFormat.currency(
    locale: 'es_CU',
    symbol: 'CUP ',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compact(
    locale: 'es_CU',
  );

  /// Formatea un número como pesos cubanos
  /// Ejemplo: 1234.56 -> "CUP 1,234.56"
  static String formatCubanPesos(double amount) {
    return _cubanPesoFormatter.format(amount);
  }

  /// Formatea un número de forma compacta para espacios pequeños
  /// Ejemplo: 1234567 -> "1.2M", 1234 -> "1.2K"
  static String formatCompact(double amount) {
    if (amount < 1000) {
      return amount.toStringAsFixed(0);
    }
    return _compactFormatter.format(amount);
  }

  /// Formatea un número con separadores de miles pero sin símbolo de moneda
  /// Ejemplo: 1234.56 -> "1,234.56"
  static String formatNumber(double amount) {
    final formatter = NumberFormat('#,##0.00', 'es_CU');
    return formatter.format(amount);
  }

  /// Formatea para mostrar en tablas responsivas
  /// Usa formato compacto en pantallas pequeñas, formato completo en pantallas grandes
  static String formatForTable(double amount, bool isSmallScreen) {
    if (isSmallScreen && amount >= 1000) {
      return formatCompact(amount);
    }
    return formatCubanPesos(amount);
  }

  /// Determina si la pantalla es pequeña basado en el ancho
  static bool isSmallScreen(double screenWidth) {
    return screenWidth < 600;
  }

  /// Formatea cantidad de compras de forma legible
  static String formatPurchaseCount(int count) {
    if (count < 1000) {
      return count.toString();
    }
    return _compactFormatter.format(count);
  }
}