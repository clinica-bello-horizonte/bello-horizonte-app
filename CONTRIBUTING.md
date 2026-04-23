# Guía de Contribución — Clínica Bello Horizonte App

Este documento describe cómo trabajar en este proyecto siguiendo la metodología **Scrum** con GitHub.

---

## Metodología Scrum

### Roles del equipo

| Rol | Responsabilidad |
|-----|----------------|
| Product Owner | Define y prioriza el Product Backlog |
| Scrum Master | Facilita ceremonias, elimina impedimentos |
| Equipo de Desarrollo | Implementa las historias de usuario |

### Sprints

Cada sprint dura **2 semanas**. Los sprints están representados como **Milestones** en GitHub:

| Milestone | Fechas | Enfoque |
|-----------|--------|---------|
| Sprint 1 — Arquitectura y Autenticación | 26 abr – 9 may 2026 | Login, registro, sesión JWT |
| Sprint 2 — Citas y Médicos | 10 – 23 may 2026 | Reserva, reprogramar, cancelar, catálogo |
| Sprint 3 — Historial y Perfil | 24 may – 6 jun 2026 | Historial médico, edición de perfil |
| Sprint 4 — Producción y Mejoras | 7 – 20 jun 2026 | Notificaciones, tests, despliegue |

### Tipos de issues

| Etiqueta | Descripción |
|----------|-------------|
| `epic` | Funcionalidad grande que agrupa varias historias |
| `story` | Historia de usuario con criterios de aceptación |
| `task` | Tarea técnica que no es directamente visible para el usuario |
| `bug` | Comportamiento incorrecto de la aplicación |
| `enhancement` | Mejora de una funcionalidad existente |

---

## Flujo de trabajo con Git

### Convención de ramas

```
main          ← código estable, desplegado o listo para producción
develop       ← integración de features completas
feature/      ← nueva funcionalidad (desde develop)
fix/          ← corrección de bug
hotfix/       ← corrección urgente en producción
```

**Formato de nombre de rama:**

```
feature/issue-<número>-descripcion-corta
fix/issue-<número>-descripcion-corta

Ejemplos:
feature/issue-5-login-dni
fix/issue-12-overflow-reprogramar
```

### Convención de commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>(<alcance>): <descripción en imperativo>

Ejemplos:
feat(auth): agregar login con DNI de 8 dígitos
fix(appointments): corregir overflow en paso de reprogramación
refactor(router): usar router.refresh() en lugar de recrear GoRouter
test(auth): agregar prueba de refresh token expirado
docs(readme): actualizar instrucciones de instalación
```

| Tipo | Cuándo usarlo |
|------|--------------|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `refactor` | Cambio de código sin alterar comportamiento |
| `test` | Añadir o modificar pruebas |
| `docs` | Solo documentación |
| `chore` | Tareas de mantenimiento (dependencias, configuración) |
| `style` | Formato, espacios, punto y coma (sin cambio de lógica) |

---

## Proceso de desarrollo

### 1. Tomar un issue del sprint activo

- Ve al Milestone del sprint activo en GitHub
- Asígnate el issue antes de empezar
- Mueve el issue a **"In Progress"** en el tablero Scrum

### 2. Crear la rama

```bash
git checkout develop
git pull origin develop
git checkout -b feature/issue-8-reservar-cita
```

### 3. Desarrollar y hacer commits frecuentes

```bash
git add lib/features/appointments/...
git commit -m "feat(appointments): agregar paso 1 — selección de especialidad"
```

### 4. Abrir Pull Request hacia `develop`

- Usa la plantilla de PR (se carga automáticamente)
- Referencia el issue con `Closes #8`
- Solicita revisión de al menos 1 compañero

### 5. Revisión de código (Code Review)

- El revisor usa comentarios de GitHub para sugerencias
- El autor responde o implementa los cambios
- Al aprobar → se hace merge con **Squash and Merge**

### 6. Cerrar el issue

- El merge automáticamente cierra el issue si usaste `Closes #N`
- Mueve la tarjeta a **"Done"** en el tablero Scrum

---

## Ceremonias Scrum

| Ceremonia | Frecuencia | Duración máx. |
|-----------|-----------|---------------|
| Sprint Planning | Inicio de cada sprint | 2 horas |
| Daily Standup | Cada día hábil | 15 minutos |
| Sprint Review | Final de cada sprint | 1 hora |
| Retrospectiva | Final de cada sprint | 1 hora |

### Preguntas del Daily Standup

1. ¿Qué hice ayer?
2. ¿Qué haré hoy?
3. ¿Tengo algún impedimento?

---

## Definición de Terminado (DoD)

Una historia de usuario se considera **terminada** cuando:

- [ ] El código compila sin errores (`flutter analyze`)
- [ ] La funcionalidad fue probada en el emulador Android
- [ ] Se cumplen todos los criterios de aceptación del issue
- [ ] El PR fue revisado y aprobado por al menos 1 persona
- [ ] El código fue mergeado a `develop`
- [ ] El issue está cerrado y la tarjeta en "Done"
