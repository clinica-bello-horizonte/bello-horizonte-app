# Clínica Bello Horizonte - App Móvil

## Requisitos previos
- Flutter SDK >= 3.22 (estable)  
- Dart SDK >= 3.3.0
- Android Studio / VS Code con extensión Flutter

## Instalación y ejecución

### 1. Instalar dependencias
```bash
cd BelloHorizonteApp
flutter pub get
```

### 2. Ejecutar la app
```bash
# En Android (emulador o dispositivo físico)
flutter run

# En Chrome (Web - modo debug)
flutter run -d chrome

# En Windows Desktop
flutter run -d windows
```

## Cuenta de demostración
Al abrir la app, en la pantalla de Login presiona el botón azul **"Modo demostración"** para rellenar automáticamente:
- **Email:** `demo@bellohorizonte.pe`
- **Contraseña:** `demo123`

También puedes registrar una cuenta nueva con tu DNI real.

## Estructura del proyecto
```
lib/
├── main.dart                      # Punto de entrada
├── app.dart                       # MaterialApp con GoRouter
├── core/
│   ├── constants/                 # Constantes globales
│   ├── database/                  # SQLite (DatabaseService + MockData)
│   ├── errors/                    # Failures y Exceptions
│   ├── extensions/                # Context extensions
│   ├── providers/                 # Providers core (DB, Security)
│   ├── router/                    # GoRouter con guards de auth
│   ├── security/                  # Hash SHA-256 + SecureStorage
│   ├── theme/                     # Material 3 (colores, tipografía, tema)
│   ├── utils/                     # Validadores, DateFormatter
│   └── widgets/                   # Widgets reutilizables
└── features/
    ├── auth/                      # Login, Registro, Recuperar contraseña
    ├── home/                      # Dashboard principal
    ├── appointments/              # Citas médicas (CRUD completo)
    ├── doctors/                   # Listado y detalle de médicos
    ├── specialties/               # Especialidades médicas
    ├── patient_history/           # Historial médico del paciente
    └── settings/                  # Perfil y configuración
```

## Decisiones técnicas

### State Management: Riverpod 2.x
- Mejor separación de capas vs Bloc
- Sin código generado: `StateNotifierProvider` y `FutureProvider` directamente
- Providers compuestos para invalidación reactiva de caché

### Base de datos: sqflite (SQLite)
- Sin generación de código (a diferencia de Drift/Moor)
- Funciona en Android, iOS, Windows, Linux, macOS
- Esquema relacional con FOREIGN KEYS habilitadas
- Datos mock sembrados automáticamente al primer arranque

### Navegación: GoRouter v14
- Rutas declarativas con ShellRoute para bottom navigation
- Guards de autenticación en `redirect`
- Deep linking preparado para futuras push notifications

### Seguridad
- Contraseñas hasheadas con SHA-256 + salt
- Sesión persistida en `flutter_secure_storage` (cifrado por el OS)
- Validación y sanitización de todos los inputs del usuario

## Datos mock incluidos
- **12 especialidades** médicas (Cardiología, Neurología, Ginecología, etc.)
- **15 médicos** especialistas con horarios y tarifas
- **6 consejos de salud** en el Home
- **3 registros médicos** del paciente demo
- **Usuario demo** para login inmediato

## Assets necesarios (reemplazar placeholders)
Los siguientes assets deben ser proporcionados por el equipo de diseño:
- `assets/images/logo_clinica.png` - Logo oficial de la clínica
- `assets/images/hero_banner.jpg` - Imagen de banner para el home
- Fotos de médicos (actualmente se usan iniciales como avatar)

## Para producción (NO implementado intencionalmente)
- Backend REST API / GraphQL
- Autenticación JWT con refresh tokens
- Notificaciones push (Firebase Cloud Messaging)
- Pagos en línea (Pasarela de pago peruana)
- Telemedicina / videollamadas
- Laboratorio de resultados
