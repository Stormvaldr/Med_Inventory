# Flutter Med Sales

App offline para gestión de inventario y ventas con SQLite y generación de recibos en PDF.

## Pasos para correr en Android
1. Asegúrate de tener Flutter instalado y `flutter doctor` en verde.
2. Descomprime este proyecto: `flutter_med_sales.zip`.
3. **Muy importante:** dentro de la carpeta del proyecto corre:
   ```bash
   flutter create .
   flutter pub get
   flutter run
   ```
   El comando `flutter create .` agregará los archivos nativos que faltan para Android/iOS manteniendo nuestro código `lib/` y `pubspec.yaml`.
4. Para generar APK de instalación:
   ```bash
   flutter build apk --release
   ```
   El APK quedará en `build/app/outputs/flutter-apk/app-release.apk`.
5. Instala el APK en tu teléfono (activar "orígenes desconocidos") y listo.

## Uso
- **Inventario:** agrega/edita medicamentos con coste, venta y stock.
- **Ventas:** añade productos al carrito, coloca el envío manual, confirma la venta y se genera y comparte un PDF.
- **Reportes:** ingresos y utilidad del día y del mes.

> Los datos se guardan localmente en SQLite y la app funciona sin internet.
