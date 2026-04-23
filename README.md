# Clínica Bello Horizonte — App Móvil

Aplicación móvil desarrollada en **Flutter** para la Clínica Privada Bello Horizonte (Piura, Perú).  
Permite a los pacientes gestionar sus citas médicas, consultar su historial clínico y comunicarse con la clínica desde su celular.

---

## Tecnologías

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3.x (Dart) |
| Gestión de estado | Riverpod 2 |
| Navegación | GoRouter 14 |
| Cliente HTTP | Dio 5 |
| Almacenamiento seguro | FlutterSecureStorage |
| Arquitectura | Clean Architecture |

---

## Funcionalidades

- **Autenticación** — Login con DNI o correo electrónico, registro de paciente, sesión persistente con JWT y refresh automático
- **Citas médicas** — Reserva guiada en 4 pasos, reprogramación directa, cancelación con confirmación
- **Médicos** — Listado con búsqueda, perfil detallado, edición de datos (solo administrador)
- **Especialidades** — Catálogo completo con acceso rápido a reserva
- **Historial médico** — Consultas anteriores con diagnóstico y notas del médico
- **Perfil** — Edición de datos personales del paciente
- **Contacto** — FAB con acceso directo a WhatsApp y teléfono de la clínica

---

## Requisitos previos

- Flutter SDK 3.x (`flutter --version`)
- Android Studio o VS Code con extensión Flutter
- Emulador Android o dispositivo físico con Android 6+
- Backend corriendo localmente (ver [bello-horizonte-backend](https://github.com/clinica-bello-horizonte/bello-horizonte-backend))

---

## Instalación

```bash
git clone https://github.com/clinica-bello-horizonte/bello-horizonte-app.git
cd bello-horizonte-app
flutter pub get
flutter run
```

> La URL del backend se configura en `lib/core/network/api_endpoints.dart`.  
> Por defecto apunta a `http://10.0.2.2:3000/api/v1` (localhost desde emulador Android).

---

## Estructura del proyecto

```
lib/
├── core/
│   ├── network/          # ApiClient (Dio), TokenService, ApiEndpoints
│   ├── router/           # GoRouter con redirección por autenticación
│   ├── theme/            # Colores, tipografía, tema global
│   ├── providers/        # Providers de infraestructura (apiClient, secureStorage)
│   └── widgets/          # Componentes reutilizables (AppButton, AppTextField, etc.)
└── features/
    ├── auth/             # Login, registro, splash, recuperación de contraseña
    ├── appointments/     # Citas (wizard de reserva, detalle, lista, reprogramar)
    ├── doctors/          # Médicos (lista con búsqueda, detalle, edición)
    ├── specialties/      # Especialidades médicas
    ├── patient_history/  # Historial médico del paciente
    ├── home/             # Pantalla principal (dashboard)
    └── settings/         # Perfil y configuración de cuenta
```

Cada `feature` sigue Clean Architecture con tres capas: `domain/` → `data/` → `presentation/`.

---

## Credenciales de prueba

| Rol | Correo | DNI | Contraseña |
|-----|--------|-----|-----------|
| Paciente | demo@bellohorizonte.pe | 00000000 | demo123 |
| Administrador | admin@bellohorizonte.pe | 11111111 | admin123 |

---

## Contribución

Consulta [CONTRIBUTING.md](CONTRIBUTING.md) para conocer el flujo de trabajo Scrum, convenciones de ramas y formato de commits.
