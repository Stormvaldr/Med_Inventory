# 🐧 Pinguina Med Sales

**Aplicación móvil offline para gestión de inventario farmacéutico y ventas con interfaz moderna**

Una aplicación Flutter completa para la gestión de inventarios médicos, ventas, reportes y análisis financiero con almacenamiento local SQLite y generación de recibos PDF.

## 📱 Características Principales

### 🏥 Gestión de Inventario
- ✅ Agregar, editar y eliminar medicamentos
- ✅ Control de stock en tiempo real
- ✅ Gestión de precios de compra y venta
- ✅ Categorización de productos

### 💰 Sistema de Ventas
- ✅ Carrito de compras intuitivo
- ✅ Cálculo automático de totales
- ✅ Gestión de clientes
- ✅ Generación automática de recibos PDF
- ✅ **Eliminación de ventas con restauración de stock**

### 📊 Reportes y Análisis
- ✅ Reportes diarios y mensuales
- ✅ Análisis de utilidades
- ✅ Historial de ventas por cliente
- ✅ Estadísticas de rendimiento

### 🎨 Interfaz Moderna
- ✅ **Tema oscuro/claro con toggle**
- ✅ **Diseño con colores pastel estilo Android 16**
- ✅ **Navegación flotante con esquinas redondeadas**
- ✅ **Calculadora integrada**
- ✅ Interfaz optimizada sin AppBar

### 🔧 Funcionalidades Técnicas
- ✅ Almacenamiento offline con SQLite
- ✅ Generación de PDFs
- ✅ Backup y restauración de datos
- ✅ Funciona completamente sin internet

## 🔧 Requisitos del Sistema

### Para Desarrollo
- **Flutter SDK:** 3.0.0 o superior
- **Dart SDK:** 2.17.0 o superior
- **Android Studio:** 4.1 o superior (para desarrollo Android)
- **Xcode:** 13.0 o superior (para desarrollo iOS - solo macOS)
- **Git:** Para clonar el repositorio

### Para Compilación
- **Android SDK:** API level 21 (Android 5.0) o superior
- **Java:** JDK 11 o superior
- **Gradle:** 7.0 o superior

## 📱 Compatibilidad de Dispositivos

### Android
- **Versión mínima:** Android 5.0 (API 21)
- **Versión recomendada:** Android 8.0 (API 26) o superior
- **Arquitecturas soportadas:** arm64-v8a, armeabi-v7a, x86_64
- **RAM mínima:** 2GB
- **Almacenamiento:** 50MB libres

### iOS
- **Versión mínima:** iOS 11.0
- **Versión recomendada:** iOS 13.0 o superior
- **Dispositivos compatibles:** iPhone 6s y posteriores, iPad Air 2 y posteriores

### Escritorio (Experimental)
- **Windows:** Windows 10 versión 1903 o superior
- **macOS:** macOS 10.14 o superior
- **Linux:** Ubuntu 18.04 o superior

## 🚀 Instalación y Configuración

### 1. Clonar el Repositorio
```bash
git clone https://github.com/Stormvaldr/Med_Inventory.git
cd flutter_med_sales
```

### 2. Verificar Instalación de Flutter
```bash
flutter doctor
```
**Nota:** Asegúrate de que todos los elementos estén en verde ✅

### 3. Configurar el Proyecto
```bash
# Regenerar archivos nativos (importante)
flutter create .

# Instalar dependencias
flutter pub get

# Limpiar caché (opcional)
flutter clean
```

### 4. Ejecutar en Modo Desarrollo
```bash
# Para Android
flutter run

# Para dispositivo específico
flutter devices
flutter run -d <device_id>

# Para Windows (si está disponible)
flutter run -d windows
```

## 📦 Compilación para Producción

### Android APK
```bash
# APK universal
flutter build apk --release

# APK optimizado por arquitectura
flutter build apk --split-per-abi --release

# Bundle para Google Play Store
flutter build appbundle --release
```

**Ubicación del APK:** `build/app/outputs/flutter-apk/app-release.apk`

### iOS (solo en macOS)
```bash
# Para dispositivos
flutter build ios --release

# Para simulador
flutter build ios --debug
```

### Windows
```bash
flutter build windows --release
```

## 🛠️ Desarrollo y Modificación

### Estructura del Proyecto
```
lib/
├── data/
│   └── database_helper.dart     # Gestión de base de datos SQLite
├── models/
│   ├── drug.dart               # Modelo de medicamentos
│   └── sale.dart               # Modelo de ventas
├── providers/
│   └── theme_provider.dart     # Gestión de temas
├── screens/
│   ├── calculator_screen.dart  # Pantalla de calculadora
│   ├── inventory_screen.dart   # Gestión de inventario
│   ├── sales_screen.dart       # Proceso de ventas
│   ├── sales_reports_screen.dart # Reportes de ventas
│   ├── client_history_screen.dart # Historial de clientes
│   └── reports_screen.dart     # Reportes generales
├── theme/
│   └── app_theme.dart          # Configuración de temas
├── utils/
│   └── pdf_generator.dart      # Generación de PDFs
└── main.dart                   # Punto de entrada
```

### Dependencias Principales
- **sqflite:** Base de datos SQLite
- **pdf:** Generación de documentos PDF
- **path_provider:** Acceso al sistema de archivos
- **share_plus:** Compartir archivos
- **provider:** Gestión de estado
- **flutter_launcher_icons:** Iconos de la aplicación

### Comandos de Desarrollo Útiles
```bash
# Análisis de código
flutter analyze

# Ejecutar tests
flutter test

# Generar iconos
flutter pub run flutter_launcher_icons:main

# Limpiar proyecto
flutter clean && flutter pub get

# Ver logs en tiempo real
flutter logs
```

## 🔄 Actualización de Versión

1. **Actualizar `pubspec.yaml`:**
```yaml
version: 2.2.5+9  # Incrementar número de versión
```

2. **Compilar nueva versión:**
```bash
flutter build apk --release
```

## 🐛 Solución de Problemas Comunes

### Error de Gradle
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Error de dependencias
```bash
flutter pub deps
flutter pub upgrade
```

### Error de iconos
```bash
flutter pub run flutter_launcher_icons:main
```

### Problemas de base de datos
- Eliminar la app del dispositivo
- Reinstalar para resetear la base de datos

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📞 Soporte

Para reportar bugs o solicitar features, por favor abre un issue en el repositorio de GitHub.

---

**Versión actual:** 2.2.5+9  
**Última actualización:** Enero 2025  
**Desarrollado con:** Flutter 💙
