# GitHub Actions para Compilación iOS

Este directorio contiene workflows de GitHub Actions para compilar automáticamente la aplicación iOS.

## Workflows Disponibles

### 1. `ios-build.yml` - Compilación Básica
- **Trigger**: Push a main, Pull Requests, Manual
- **Función**: Genera un IPA sin firmar para pruebas
- **Salida**: `app-unsigned.ipa` en artifacts

### 2. `ios-release.yml` - Compilación para Distribución
- **Trigger**: Releases, Manual
- **Función**: Genera IPA firmado para App Store
- **Salida**: `Runner.ipa` firmado

## Configuración Inicial

### Paso 1: Configurar Secrets en GitHub

Ve a tu repositorio → Settings → Secrets and variables → Actions y añade:

#### Para compilación firmada (ios-release.yml):
```
IOS_CERTIFICATE_BASE64          # Certificado de distribución en base64
IOS_CERTIFICATE_PASSWORD        # Contraseña del certificado
IOS_PROVISIONING_PROFILE_BASE64 # Perfil de aprovisionamiento en base64
APPLE_ID                        # Tu Apple ID
APPLE_PASSWORD                  # Contraseña específica de la app
APPLE_TEAM_ID                   # ID del equipo de desarrollador
APPLE_ISSUER_ID                 # Issuer ID de App Store Connect
APPLE_API_KEY_ID                # API Key ID
APPLE_API_PRIVATE_KEY           # API Private Key
```

### Paso 2: Obtener Certificados de Apple

1. **Certificado de Distribución:**
   ```bash
   # Exportar certificado desde Keychain
   # Convertir a base64
   base64 -i certificate.p12 | pbcopy
   ```

2. **Perfil de Aprovisionamiento:**
   - Descargar desde Apple Developer Portal
   - Convertir a base64:
   ```bash
   base64 -i profile.mobileprovision | pbcopy
   ```

### Paso 3: Configurar Bundle ID

Edita `ios/Runner/Info.plist` y asegúrate de que el Bundle ID coincida:
```xml
<key>CFBundleIdentifier</key>
<string>com.pinguina.medsales</string>
```

### Paso 4: Actualizar ExportOptions.plist

Edita `ios/ExportOptions.plist` con tus datos:
```xml
<key>teamID</key>
<string>TU_TEAM_ID_AQUI</string>
<key>provisioningProfiles</key>
<dict>
    <key>com.pinguina.medsales</key>
    <string>NOMBRE_DE_TU_PERFIL</string>
</dict>
```

## Uso

### Compilación de Prueba (Sin Firmar)
1. Haz push a la rama `main`
2. Ve a Actions → "Build iOS App"
3. Descarga el artifact `ios-app-unsigned`

### Compilación para Distribución
1. Crea un release en GitHub, o
2. Ve a Actions → "Build and Release iOS App" → "Run workflow"
3. Descarga el artifact `ios-app-release`

## Instalación del IPA

### IPA Sin Firmar (Solo para pruebas)
- Requiere dispositivo con jailbreak o simulador
- No se puede instalar en dispositivos normales

### IPA Firmado
- Se puede instalar vía TestFlight
- Se puede subir a App Store
- Se puede instalar con herramientas como AltStore (con certificado de desarrollador)

## Troubleshooting

### Error: "No signing certificate"
- Verifica que `IOS_CERTIFICATE_BASE64` esté configurado
- Asegúrate de que el certificado no haya expirado

### Error: "Provisioning profile not found"
- Verifica que el Bundle ID coincida
- Asegúrate de que el perfil incluya el dispositivo de destino

### Error: "Team ID mismatch"
- Verifica que `APPLE_TEAM_ID` sea correcto
- Actualiza `ExportOptions.plist` con el Team ID correcto

## Notas Importantes

1. **Certificados**: Los certificados de Apple expiran anualmente
2. **Perfiles**: Los perfiles de aprovisionamiento pueden expirar
3. **Límites**: Apple limita el número de dispositivos por perfil de desarrollador
4. **Costos**: Necesitas una cuenta de Apple Developer ($99/año)

## Alternativas Rápidas

Si solo necesitas probar la app:
1. Usa el simulador de iOS en Xcode
2. Usa Flutter Web: `flutter run -d chrome`
3. Usa la versión Android que ya tienes compilada