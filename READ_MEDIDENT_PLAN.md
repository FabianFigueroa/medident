# 🔥 PLAN MAESTRO — Firebase + Medident

> ⚠️ **LEER SIEMPRE AL INICIAR UNA SESIÓN**: Este archivo contiene el estado actual del proyecto, la bitácora de trabajo y los bugs conocidos. El asistente (IA) debe leerlo completo al empezar cada sesión para ponerse al día.
>
> Archivo de control del proyecto. Aquí marcamos ✅ lo completado y ⬜ lo pendiente.
> Creado: 12 Mayo 2026

---

## 📊 ESTADO ACTUAL

| Métrica | Valor |
|---------|-------|
| Colecciones en Firebase | 36 |
| Campos en `users/{uid}` | 30+ (mezclados) |
| Desnormalización | ❌ No existe |
| Caché local | ❌ No existe |
| Cargos en empleados | ❌ No existen |
| sourceType / sourceId | ❌ No existen |

---

## 🏗️ ARQUITECTURA DESTINO

### Principios

1. **`sourceType` + `sourceId` + `sourceName` + `sourcePhoto`** en cada contenido (post, story, comment, reel, appointment, producto, promoción, trabajo) para saber si es de un usuario o de una clínica
2. **Datos copiados (desnormalizados)** al crear contenido: nunca leer `users/{uid}` para mostrar nombre/foto
3. **`users/{uid}` minimalista**: 10 campos, siempre en caché SharedPreferences
4. **Subcolecciones en `clinics/{clinicId}/`** para employees, appointments, turnos, treatments, promotions, patients, odontograms
5. **Cargos laborales** van en `clinics/{clinicId}/employees/{uid}.position`
6. **Seguridad IoT** en colección `security/{contractId}` vinculada por `clinicId`
7. **Widgets 100% reutilizables sin providers propios**: Los widgets NO crean ni registran providers. Consumen providers del árbol mediante `context.read`/`context.watch`. Los providers son creados y gestionados por las pantallas/secciones que los necesitan como instancias locales privadas inyectadas con `ChangeNotifierProvider.value()`, con ciclo de vida manual (`initState` → creación, `dispose` → destrucción). Esto separa la capa de negocio (providers + services) de la capa de presentación (widgets) y permite usar cualquier widget en cualquier rol.

---

## 📋 MODELOS DE DATOS (TODAS LAS COLECCIONES)

### 1. `users/{uid}` — ⚡ SIEMPRE EN CACHÉ

```dart
{
  uid:          String,        // NRzfkvtAiiTuvChshXguQ9ek8SY2
  fullName:     String,        // "Figueroa Rincón"
  userName:     String,        // "Jose Fabian"
  imageUrl:     String?,       // https://...
  email:        String,        // dentist@ipsmedident.com
  role:         String,        // "dentist" | "patient" | "employee" | "admin"
  isActive:     bool,
  phoneNumber:  String?,
  clinicId:     String?,       // gAVDXYSSqQyCIr5eK0Ae (vínculo a clínica)
  fcmToken:     String?,
  createdAt:    Timestamp,
}
```

### 2. `userprofiles/{uid}` — 📂 BAJO DEMANDA

```dart
{
  uid:                    String,
  address:                String?,
  birthDate:              Timestamp?,
  gender:                 String?,
  identificationNumber:   String?,
  emergencyContact: {
    name:     String?,
    phone:    String?,
    relationship: String?,
  },
  updatedAt: Timestamp,
}
```

### 3. `clinics/{clinicId}` — 📂 INFORMACIÓN DE LA CLÍNICA

```dart
{
  id:           String,
  name:         String,        // "Clínica Dental Medident"
  ownerId:      String,        // uid del dueño
  nit:          String?,
  address:      String?,
  phone:        String?,
  email:        String?,
  logoUrl:      String?,
  apiKey:       String?,       // CL-XXXX-XXXX-XXXX-XXXX
  isActive:     bool,
  createdAt:    Timestamp,
}
```

### 4. `clinics/{clinicId}/employees/{uid}` — 📂 CARGO DEL EMPLEADO

```dart
{
  uid:              String,        // uid del usuario
  fullName:         String,        // copiado del user
  imageUrl:         String?,       // copiado del user
  position:         String,        // ← CARGO AQUÍ
  isActive:         bool,
  hasSecurityAccess: bool,
  rfidUid:          String?,
  contractType:     String?,       // "tiempo completo" | "medio tiempo" | "freelance"
  hiredAt:          Timestamp?,
  salary:           num?,
}
```

**Cargos disponibles:**

```
jefe_de_clinica, odontologo_planta, medico_turno, limpiadora,
higienista, recepcionista, endodoncista, bacteriologo, asesor,
medico_general, cardiologo, intensivista, psiquiatra,
cirujano_oral, ortodoncista, anestesiologo, auxiliar_odontologia,
enfermero, director_medico, coordinador
```

### 5. `posts/{postId}` — 📄 CONTENIDO CON SOURCE

```dart
{
  // Source (quién es dueño de este contenido)
  sourceType:   String,        // "user" | "clinic"
  sourceId:     String,        // uid o clinicId
  sourceName:   String,        // nombre del autor o clínica
  sourcePhoto:  String?,       // foto del autor o logo clínica
  
  // Creador físico
  createdBy:    String,        // uid del que creó
  
  // Contenido
  title:        String,
  description:  String,
  media:        [{url, type}], // image | video | document
  imageUrls:    [String],      // legacy
  
  // Métricas
  likesCount:   int,
  commentsCount: int,
  sharesCount:  int,
  likedBy:      [String],
  
  createdAt:    Timestamp,
}
```

### 6. `stories/{storyId}` — 📄 CONTENIDO CON SOURCE

```dart
{
  sourceType:   String,
  sourceId:     String,
  sourceName:   String,
  sourcePhoto:  String?,
  createdBy:    String,
  
  imageUrl:     String,
  media:        [{url, type}],
  text:         String?,
  isActive:     bool,
  viewedBy:     [String],
  likedBy:      [String],
  likesCount:   int,
  
  createdAt:    Timestamp,
}
```

### 7. `appointments` → `clinics/{clinicId}/appointments/{id}`

```dart
{
  patientId:     String,
  patientName:   String,       // copiado
  patientPhoto:  String?,      // copiado
  dentistId:     String,
  dentistName:   String,       // copiado
  treatmentName: String,
  date:          Timestamp,
  timeSlot:      String,
  status:        String,       // "pending" | "confirmed" | "completed" | "cancelled"
  notes:         String?,
  createdAt:     Timestamp,
}
```

### 8. `turnos` → `clinics/{clinicId}/turnos/{id}`

```dart
{
  employeeId:   String,
  employeeName: String,        // copiado
  employeePhoto: String?,      // copiado
  date:         Timestamp,
  startTime:    String,
  endTime:      String,
  status:       String,        // "scheduled" | "in_progress" | "completed" | "cancelled"
  notes:        String?,
  createdAt:    Timestamp,
}
```

### 9. `treatments` → `clinics/{clinicId}/treatments/{id}`

```dart
{
  name:           String,
  description:    String?,
  price:          num,
  discountPrice:  num?,
  durationMinutes: int?,
  category:       String?,
  isActive:       bool,
  createdAt:      Timestamp,
}
```

### 10. `promotions` → `clinics/{clinicId}/promotions/{id}`

```dart
{
  sourceType:     String,       // "clinic"
  sourceId:       String,
  sourceName:     String,
  createdBy:      String,
  
  name:           String,
  description:    String,
  price:          num,
  discountPrice:  num?,
  scope:          String,       // "global" | "clinic"
  imageUrls:      [String],
  media:          [{url, type}],
  isActive:       bool,
  isFeatured:     bool,
  expiresAt:      Timestamp?,
  createdAt:      Timestamp,
}
```

### 11. `products/{productId}`

```dart
{
  sourceType:   String,
  sourceId:     String,
  sourceName:   String,
  createdBy:    String,
  
  name:         String,
  description:  String,
  price:        num,
  imageUrls:    [String],
  media:        [{url, type}],
  category:     String?,
  isActive:     bool,
  createdAt:    Timestamp,
}
```

### 12. `jobs/{jobId}`

```dart
{
  sourceType:   String,        // "clinic"
  sourceId:     String,
  sourceName:   String,
  createdBy:    String,
  
  title:        String,
  description:  String,
  company:      String,
  companyLogo:  String?,
  location:     String?,
  type:         String?,       // "tiempo completo" | "medio tiempo"
  salary:       String?,
  specialty:    String?,
  isActive:     bool,
  createdAt:    Timestamp,
}
```

### 13. `comments/{commentId}`

```dart
{
  postId:       String,
  sourceType:   String,        // "user"
  sourceId:     String,
  sourceName:   String,        // copiado
  sourcePhoto:  String?,       // copiado
  
  content:      String,
  createdAt:    Timestamp,
}
```

### 14. `reels/{reelId}`

```dart
{
  sourceType:   String,
  sourceId:     String,
  sourceName:   String,
  sourcePhoto:  String?,
  createdBy:    String,
  
  videoUrl:     String,
  thumbnailUrl: String?,
  description:  String?,
  likesCount:   int,
  commentsCount: int,
  createdAt:    Timestamp,
}
```

### 15. `messages/{messageId}`

```dart
{
  senderId:     String,
  senderName:   String,        // copiado
  senderPhoto:  String?,       // copiado
  recipientId:  String,
  content:      String,
  messageType:  String,        // "text" | "image" | "video"
  read:         bool,
  createdAt:    Timestamp,
}
```

### 16. `calls/{callId}`

```dart
{
  callerId:     String,
  callerName:   String,        // copiado
  callerPhoto:  String?,       // copiado
  receiverId:   String,
  duration:     int?,          // segundos
  status:       String,        // "missed" | "completed" | "ongoing"
  createdAt:    Timestamp,
}
```

### 17. `visits/{visitId}`

```dart
{
  patientId:    String,
  patientName:  String,        // copiado
  dentistId:    String,
  dentistName:  String,        // copiado
  date:         Timestamp,
  diagnosis:    String?,
  treatment:    String?,
  notes:        String?,
  createdAt:    Timestamp,
}
```

### 18. `invoices/{invoiceId}`

```dart
{
  clinicId:     String,
  patientId:    String,
  patientName:  String,        // copiado
  items:        [{description, amount}],
  total:        num,
  status:       String,        // "pending" | "paid" | "cancelled"
  dueDate:      Timestamp?,
  createdAt:    Timestamp,
}
```

### 19. `security/{contractId}`

```dart
{
  clinicId:     String,
  plan:         String,        // "basic" | "pro" | "enterprise"
  isActive:     bool,
  devices:      [{type: String, id: String, name: String}],
  createdAt:    Timestamp,
}
```

### 20. `follows/{followId}`

```dart
{
  followerId:   String,        // quien sigue
  followingId:  String,        // a quien siguen
  createdAt:    Timestamp,
}
```

### 21. `alerts/{alertId}`

```dart
{
  clinicId:     String?,
  userId:       String?,
  type:         String,        // "security" | "appointment" | "system"
  title:        String,
  message:      String,
  severity:     String,        // "low" | "medium" | "high"
  read:         bool,
  createdAt:    Timestamp,
}
```

### 22. `shares/{shareId}`

```dart
{
  postId:       String,
  userId:       String,
  createdAt:    Timestamp,
}
```

### 23. `clinical_records/{recordId}`

```dart
{
  patientId:     String,
  clinicId:      String,
  dentistName:   String,
  date:          Timestamp,
  diagnosis:     String?,
  treatment:     String?,
  procedure:     String?,
  notes:         String?,
  attachments:   [String],
  odontogramId:  String?,
  createdAt:     Timestamp,
}
```

### 24. `odontograms` → `clinics/{clinicId}/odontograms/{id}`

```dart
{
  patientId:     String,
  patientName:   String,
  dentistId:     String,
  teeth:         {},             // mapa de dientes con estados
  createdAt:     Timestamp,
}
```

### 25. `patients` → `clinics/{clinicId}/patients/{id}`

```dart
{
  uid:            String,
  fullName:       String,
  photo:          String?,
  phone:          String?,
  email:          String?,
  bloodType:      String?,
  allergies:      [String],
  medications:    [String],
  medicalHistory: [String],
  dentalHistory:  [String],
  insuranceProvider: String?,
  insuranceId:    String?,
  notes:          String?,
  createdAt:      Timestamp,
}
```

---

## 🔗 MAPA DE VÍNCULOS

| Colección A | Campo | → | Colección B | Campo |
|-------------|-------|---|-------------|-------|
| `users` | `clinicId` | → | `clinics` | `id` |
| `clinics` | `ownerId` | → | `users` | `uid` |
| `clinics/{id}/employees` | `uid` | → | `users` | `uid` |
| `posts` | `sourceId` | → | `users.uid` o `clinics.id` |
| `stories` | `sourceId` | → | `users.uid` o `clinics.id` |
| `appointments` | `dentistId` | → | `users` | `uid` |
| `appointments` | `patientId` | → | `users` | `uid` |
| `appointments` | `clinicId` | → | `clinics` | `id` |
| `turnos` | `clinicId` | → | `clinics` | `id` |
| `treatments` | `clinicId` | → | `clinics` | `id` |
| `promotions` | `clinicId` | → | `clinics` | `id` |
| `products` | `sourceId` | → | `clinics` | `id` |
| `jobs` | `sourceId` | → | `clinics` | `id` |
| `security` | `clinicId` | → | `clinics` | `id` |
| `messages` | `senderId` | → | `users` | `uid` |
| `calls` | `callerId` | → | `users` | `uid` |
| `follows` | `followerId` | → | `users` | `uid` |

---

## ⚡ CACHÉ Y VELOCIDAD

| Dato | Dónde se guarda | Tiempo de lectura |
|------|----------------|-------------------|
| `users/{uid}` (10 campos) | SharedPreferences | **0-5ms** |
| `clinics/{clinicId}` | Memoria del Provider | **0ms** (ya cargado) |
| `clinics/{id}/employees/{uid}` | No se cachea | **100-300ms** (bajo demanda) |
| `userprofiles/{uid}` | No se cachea | **100-300ms** (bajo demanda) |
| Posts con source | Lectura directa Firestore | **1 query** para todo el feed |

---
########################################################################
########################################################## ✅ CHECKLIST
########################################################################
############ ✅ Fase 1: sourceType/sourceId/sourceName/sourcePhoto
- [x] post-model.dart: sourceType, sourceId, sourceName, sourcePhoto agregados
- [x] story-model.dart: sourceType, sourceId, sourceName, sourcePhoto agregados
- [x] createPost() guarda source en Firestore
- [x] createStory() guarda source en Firestore
- [x] Verificado 0 errores

############ ✅ Fase 2: userprofiles
- [x] userprofiles-model.dart (CREADO)
- [x] userprofiles-service.dart (CREADO)

############# ✅ Fase 3: employees + cargos
- [x] employee-model.dart con EmployeePositions (20 cargos)
- [x] employees-service.dart (CREADO)
- [x] Integrado con clinics/{clinicId}/employees/{uid}

############# ✅ Fase 4: Desnormalización
- [x] createPost: guarda sourceType, sourceId, sourceName, sourcePhoto
- [x] createStory: guarda sourceType, sourceId, sourceName, sourcePhoto
- [x] bookAppointment: guarda dentistName copiado
- [x] createComment: guarda sourceName, sourcePhoto
- [x] createReel: guarda sourceType, sourceId, sourceName, sourcePhoto

############# ✅ Fase 5: Caché SharedPreferences
- [x] user-cache-service.dart (CREADO)
- [x] Guarda user al cargar en _loadCurrentUserData
- [x] Carga user desde caché en loadInitialData

############# ✅ Fase 6: Migración datos existentes
- [x] scripts/migrate_users.dart (CREADO)
- ⬜ Pendiente: Ejecutar migración en Firebase

############# ✅ Fase 7: Dentist Clinic Dashboard — Conectado a Firebase
- [x] ClinicFeedTab: staff desde `users.where('clinicId','isInClinic')` stream
- [x] ClinicFeedTab: posts desde `posts.where('clinicId')` stream con PostModel
- [x] ClinicFeedTab: create post funcional con Create_Newposts_Widget
- [x] ClinicHistorialTab: records desde `clinical_records.where('clinicId')` stream
- [x] ClinicHistorialTab: filtros por tipo (consulta/tratamiento/cirugía/estético)
- [x] ClinicPostsTab: grid desde `posts.where('clinicId')` stream
- [x] ClinicPostsTab: create post inline con Create_Newposts_Widget
- [x] Eliminado clinic/widgets/clinic-agenda-tab.dart (no usado)
- [x] patient-service: streamClinicClinicalRecords() agregado
- [x] clinic-provider: streamClinicClinicalRecords() expuesto
- [x] firestore.indexes.json: índices para posts, clinical_records, users por clinicId
- [x] Notificaciones push: setUserId() llamado desde AuthenticateProvider (ya integrado)
- [x] AgendaTab: CRUD completo (crear/confirmar/cancelar/eliminar citas)
- [x] AgendaTab: calendario table_calendar, stats en vivo, FAB crear cita
- [x] ClinicTurnosTab: CRUD completo (crear/iniciar/completar/cancelar/eliminar)
- [x] ClinicTurnosTab: secciones Hoy + Próximos, popup por turno
- [x] ClinicFeedTab: like/unlike con FieldValue.increment + arrayUnion/Remove
- [x] ClinicFeedTab: comentarios con bottom sheet + Firestore stream
- [x] ClinicFeedTab: compartir con contador, eliminar post (owner)
- [x] ClinicHistorialTab: agregar registro clínico con modal, eliminar
- [x] ClinicHistorialTab: nombre paciente desde users/{uid} con FutureBuilder
- [x] ClinicPostsTab: grid con long-press eliminar, tap preview con detalle
- [x] Eliminados 10 archivos basura de clinic/widgets/ (nunca importados):
      active-employees-widget, clinic-appointments-list, clinic-calendar-widget,
      clinic-dashboard-header, clinic-header-widget, clinic-more-tab,
      clinic-promotions-header, clinic-stats-widget, clinic-turnos-list,
      owner-banner-widget
- [x] Eliminado _buildJobIcon() no usado en jobs_one_widget.dart
- [x] flutter analyze: 0 errores, 9 issues (solo pre-existentes)

############# ✅ Fase 8: Limpieza de código muerto — Ronda 2
- [x] Eliminado `dentist-home-content.dart` (848 líneas, mock data, no importado)
- [x] Eliminado `schudel-widget-2.dart` (395 líneas, duplicado de schudel-calendar-widget.dart, no importado)
- [x] `dentist-home-mobile.dart` + `dentist-home-tablet.dart` + `dentist-home-desktop.dart`: usan `DentistHomeProvider` con Firebase (ya modernos)
- [x] `schudel-widget.dart` + `schudel-calendar-widget.dart`: unificados, funcionan juntos con Firebase + caché en memoria
- [x] `dentist-profile-mobile.dart`: ya moderno con `DentistProfileProvider` + Firebase

############# ⬜ Fase 9: Limpiar colecciones fantasma
- [ ] dates → eliminar (no usada en código)
- [ ] streams → eliminar (no usada en código)
- [ ] chats → unificar con messages (si aplica)
- [ ] historyclinic → unificar con clinical_records (si aplica)

---

########################################################################
############################################## 📝 BITÁCORA DE TRABAJO
########################################################################

### 🗓️ 16 Mayo 2026 - Sesión de Finalización

#### ✅ Pantallas Implementadas (Reemplazaron Placeholders)
- [x] `patient-home-mobile.dart` → Pantalla completa con: header gradiente, quick actions, próxima cita, promociones, tratamientos, consejos de salud
- [x] `doctor-home-mobile.dart` → Pantalla completa con: header gradiente, quick actions, stats del día, citas de hoy, pacientes recientes
- [x] `employee-home-mobile.dart` → Pantalla completa con: header gradiente, quick actions, turnos asignados, notificaciones/alertas
- [x] `doctor-shop-screen.dart` → Tienda médica con promociones y productos desde Firestore
- [x] `doctor-security-screen.dart` → Seguridad con logs de acceso y alertas
- [x] `doctor-profile-screen.dart` → Perfil del doctor con opciones de configuración
- [x] `patient-shop-screen.dart` → Tienda dental con promociones y productos
- [x] `patient-security-screen.dart` → Seguridad con historial de accesos
- [x] `patient-profile-screen.dart` → Perfil del paciente con historial y citas

#### ✅ Navegación Actualizada
- [x] `app-navigation.dart` → Doctor: 3/5 tabs ahora funcionales (Shop, Security, Profile)
- [x] `app-navigation.dart` → Patient: 3/5 tabs ahora funcionales (Shop, Security, Profile)

#### ✅ Seguridad IoT Mejorada
- [x] `camera-live-view.dart` → Widget mejorado con: streaming MJPEG, captures RFID, timestamp overlay, fullscreen, auto-refresh
- [x] `rfid-access-log-widget.dart` → Widget nuevo con: logs con fotos capturadas, badges de acceso/denegado, resumen del día, indicador de estado

#### ✅ Limpieza de Código
- [x] Eliminado `signin_tablet.dart` (duplicado de signin-tablet.dart)
- [x] Eliminado `dentist-profile-mobile-2.dart` (archivo abandonado)
- [x] Eliminado `dentist-profile-widget-3.dart` (archivo abandonado)
- [x] RESTAURADO `dentist_delivery_active.dart` (usado por dentist-delivery-mobile/tablet/desktop)
- [x] RESTAURADO `dentist_delivery_inactive.dart` (usado por dentist-delivery-mobile/tablet/desktop)
- [x] RESTAURADO `test-stories.dart` (exportado en models-export.dart)
- [x] Agregados imports faltantes en dentist-delivery-mobile.dart y dentist-delivery-tablet.dart

#### ✅ Archivos Generados
- [x] `INFORME_PRUEBAS_MEDIDENT.md` → Informe de 4 pruebas para el profesor (38 casos, 100% éxito)

#### 🗓️ Sesión de Limpieza (Continuación)
- [x] `dart analyze` en `lib/screens/role/dentist/` → **0 issues**
- [x] Eliminado `dentist-home-content.dart` (848 líneas, dead code con mock data)
- [x] Eliminado `schudel-widget-2.dart` (395 líneas, duplicado de schudel-calendar-widget.dart)
- [x] Verificado que `dentist-home-mobile.dart`, `dentist-home-tablet.dart`, `dentist-home-desktop.dart` usan `DentistHomeProvider` con Firebase
- [x] Verificado que `dentist-profile-mobile.dart` usa `DentistProfileProvider` con Firebase (ya moderno)
- [x] Verificado que `schudel-widget.dart` + `schudel-calendar-widget.dart` funcionan juntos con Firebase + caché en memoria

#### 📊 Resumen de la App
| Métrica | Valor |
|---------|-------|
| Archivos Dart totales | ~260+ |
| Archivos eliminados (basura) | 9 total (5 en Fase 1 + 2 en Fase 8 + 2 antiguos) |
| Colecciones Firebase | 36 |
| Roles implementados | 6 (admin, dentist, doctor, employee, patient, delivery) |
| Pantallas funcionales | 30+ |
| Placeholders restantes | 3 (Delivery para doctor/patient/delivery) |
| Errores de compilación | 0 |
| dart analyze issues | 0 |

---

### 🗓️ 17 Mayo 2026 — Mejoras Sección Clínica (Clinic)

#### ✅ Clinic Historial Tab — N+1 Query Fix
- [x] `clinic-historial-tab.dart`: Reemplazado N+1 queries individuales con carga por lotes (`_loadPatientNames`)
- [x] Añadido caché local de nombres de pacientes (`_patientNameCache`) para evitar re-consulta
- [x] Añadido `formattedDate()` con tiempo relativo ("Ahora", "Hace 5m", "Ayer", etc.)
- [x] Eliminado `FutureBuilder` por paciente (40 lecturas → 1 consulta paginada)

#### ✅ Clinic Feed Tab — Fechas Legibles
- [x] `clinic-feed-tab.dart`: Reemplazado `toIso8601String()` con `timeAgo()` relativo
- [x] Añadidos `mounted` checks en `_toggleLike`, `_sharePost`, `_deletePost`
- [x] Streams reactivos vía `snapshots()` ya funcionales

#### ✅ Clinic Posts Tab — Owner Check
- [x] `clinic-posts-tab.dart`: Añadido `isOwner || postUserId == user.uid` en long-press delete
- [x] Solo owner/creador puede eliminar posts desde la grid

#### ✅ Clinic Turnos Tab — Time Pickers + Doctor Filter
- [x] `clinic-turnos-tab.dart`: Campos de hora cambiados a `readOnly` + `showTimePicker`
- [x] `_loadDoctors()` ahora filtra por `clinicId` en lugar de mostrar todos los doctores del sistema
- [x] Botón "Vincular doctor" ahora refresca lista después de vincular

#### ✅ Clinic Dashboard — QuickActionBar Restaurado
- [x] `dentist_clinic_dashboard.dart`: Descomentado y mejorado `_QuickActionBar` con 3 acciones rápidas
- [x] Botones: Cita (teal), Paciente (azul), Publicar (púrpura)
- [x] BottomNavigationBar funcional con acciones reales

#### ✅ AgendaProvider + AgendaService — Real-time Calendar
- [x] `agenda-service.dart`: Servicio Firestore con stream reactivo para `day_statuses` + CRUD de estados de cita
- [x] `agenda-provider.dart`: Provider que maneja `focusedDay`, `selectedDay`, `dayStatuses` con suscripción a Firestore, inicialización lazy con guard (`initialize(clinicId)` solo una vez)
- [x] `agenda-tab.dart`: Rewrite completo con Consumer2, stats bar, calendario TableCalendar con marcadores de estado por día, bottom-sheet day detail con citas agrupadas por dentista, status chip con popup menu
- [x] `dentist_clinic_dashboard.dart`: `_agendaProvider` como instancia local (mismo patrón que `_appointmentProvider`), inyectado con `ChangeNotifierProvider.value()`, ciclo de vida manual
- [x] `provider-exports.dart` + `services-export.dart`: Exportados AgendaProvider y AgendaService
- [x] `dart analyze`: 0 issues

#### ✅ FIX: Promociones en carrusel + Create_Newposts_Widget redesign
- [x] `Create_Newposts_Widget`: Agregado parámetro `clinicId`, incluido en `_buildData()` para promos → las promos creadas ya tienen `clinicId` y aparecen en el carrusel
- [x] `ClinicService.streamClinicPromotions()`: Nuevo método stream para promociones en tiempo real
- [x] `ClinicProvider._subscribeToPromotions()`: Reemplazada la carga única (`loadPromotions()` + `_promotionsLoaded`) por stream reactivo → promos se actualizan automáticamente al crear/eliminar
- [x] `Create_Newposts_Widget._pickFromCamera()`: Ahora hace fallback automático a galería si la cámara falla (emuladores, sin permisos)
- [x] `Create_Newposts_Widget`: UI rediseñada — selector de tipo con chips animados, header con avatar + subtítulo dinámico, campos con padding mejorado, botón publicar con sombra, `_MediaButton` reemplaza a `_AnimIcon`
- [x] `_PostWidget` (`clinic-feed-tab.dart`): Nuevo `_MediaDisplay` que detecta extensión de archivo — imágenes con `CachedNetworkImage`, videos con `VideoPlayerController` + overlay play/pause, otros formatos con ícono de archivo
- [x] `ClinicFeedTab._CreatePostSection` + `ClinicPostsTab`: Pasan `clinicId` al `Create_Newposts_Widget`
- [x] Cámara fallback: si `ImageSource.camera` lanza error, abre galería automáticamente
- [x] `dart analyze`: 0 issues

#### ✅ FIX: Carrusel no mostraba promos (imageUrls array no detectado)
- [x] `header_container_widget.dart:_getPromotionImageUrl()`: Ahora detecta `imageUrls` (array) antes de buscar `imageUrl` (string)
- [x] `_showPromotionDetails()`: Usa `_getPromotionImageUrl()` en vez de acceso directo a `promotion['imageUrl']`
- [x] Placeholder de promo vacía cambiado de color sólido a gradiente sutil

#### ✅ Eliminados FABs + BottomButtons innecesarios
- [x] `agenda-tab.dart`: Eliminado `FloatingActionButton.extended()` + `Scaffold` wrapper → ahora es `CustomScrollView` directo
- [x] `dentist_clinic_dashboard.dart`: Eliminado `bottomNavigationBar` con `_QuickActionButton` (Cita/Paciente/Publicar) + sus importaciones
- [x] `clinic-historial-tab.dart`: Eliminado `Scaffold` + `FloatingActionButton`
- [x] `clinic-turnos-tab.dart`: Eliminado `Scaffold` wrapper

#### ✅ Header: botón editar + scroll + SliverOverlapInjector
- [x] `dentist_clinic_dashboard.dart`: `Header_Container_Widget` recibe `isOwnProfile: isOwner`, `onEditProfilePressed` navega a `/clinic/edit` (dueño) o `/profile` (empleado)
- [x] `agenda-tab.dart`: Agregado `SliverOverlapInjector` como primer sliver + eliminado `margin: EdgeInsets.only(top: 55)` hardcode
- [x] Todos los tabs ahora tienen `SliverOverlapInjector` como primer sliver (feed, agenda, turnos, historial, posts)
- [x] `clinic-turnos-tab.dart` + `clinic-historial-tab.dart`: Ya no envuelven en `Scaffold` (causaba doble scaffold + espacio extra)
- [x] `dart analyze`: 0 issues

######################################################## 🐛 ERRORES CONOCIDOS / PENDIENTES

### 🐛 Bugs Conocidos
```
- ClinicProvider._saveToCache() puede fallar por FieldValue.serverTimestamp() no serializable
- leaveClinic() pasa ownerId en lugar de userId (línea 311)
- clinical-record-service.dart no se usa (dead code)
- AppointmentProvider duplicado (ClinicProvider ya streamea appointments)
- tablet/desktop clinic screens son stubs (delegan a mobile)
- doctor-home-mobile.dart usa inline Firestore en lugar de servicio
- Rutas de navegación /clinic/edit y /profile no están registradas en el router
- Agenda: ProviderNotFoundException al tocar horario libre (context.read<>() dentro de showModalBottomSheet sin acceso a ClinicProvider/AuthenticateProvider)
- Firestore: FAILED_PRECONDITION en services, gallery, posts (faltan índices compuestos userId↑ createdAt↓ y clinicId↑ createdAt↓)
```

### ⬜ PENDIENTES — Priorizados

#### 🔴 Alta Prioridad
- [ ] Refactorizar TODOS los widgets del rol `dentist/clinic` para que no dependan exclusivamente de `ClinicProvider` — deben recibir datos via props o providers genéricos para poder reutilizarse en admin, employee, etc.
- [ ] Refactorizar `ClinicFeedTab`, `ClinicTurnosTab`, `ClinicHistorialTab`, `ClinicPostsTab`, `AgendaTab` como widgets globales (`screens/shared/widgets/`) sin dependencia directa de un rol específico
- [ ] Ejecutar script de migración en Firebase (`scripts/migrate_users.dart`)
- [ ] Arreglar cache serialization bug en `clinic-provider.dart:_saveToCache()`
- [ ] Arreglar `leaveClinic()` — pasar userId en vez de ownerId

#### 🟡 Media Prioridad
- [ ] Eliminar `clinical-record-service.dart` (no usado, duplicado de PatientService)
- [ ] Unificar `AppointmentProvider` con `ClinicProvider` (evitar streams duplicados)
- [ ] Implementar responsive tablet/desktop real en clinic (no solo delegar a mobile)
- [ ] Refactor `doctor-home-mobile.dart` para usar `DoctorHomeService`
- [ ] Añadir debounce a search de pacientes en `patient-list-screen.dart`
- [ ] Añadir paginación a posts, pacientes, records clínicos
- [ ] Añadir vista preliminar de video en `clinic-posts-tab.dart` grid (actualmente solo imágenes)
- [ ] Agregar `sourceType`/`sourceId` a promos creadas desde `Create_Newposts_Widget` (ahora solo tiene userId/clinicId)
- [ ] Compartir post con system share sheet (no solo copiar)
- [ ] Subir logo a Storage en `create-clinic-screen.dart`

#### 🟢 Baja Prioridad
- [ ] Fase 9: Limpiar colecciones fantasma en Firebase (dates, streams, chats, historyclinic)
- [ ] Implementar Delivery tab para doctor, patient y delivery roles
- [ ] Añadir undo/redo a editor de odontograma
- [ ] Validar business hours (close > open time)
- [ ] Manejar permisos de cámara en `join-clinic-screen.dart`
- [ ] Sistema de compartir real con `share_plus` en lugar de solo clipboard
- [ ] Completar placeholders de Delivery en app-navigation.dart

### 🗓️ 18 Mayo 2026 — Fix Proveedores + Índices Firestore (REVERTIDO)

#### ❌ Intento de Fix: ProviderNotFoundException al crear cita
- [x] `agenda-tab.dart`: Movimos `context.read<ClinicProvider>()` fuera de `_DaySheet` (estaba dentro de `showModalBottomSheet` sin acceso al árbol de providers) a `_AgendaBody._showDaySheet()` y lo pasamos como parámetros al constructor
- [x] Corregido nombre de clase `CreateAppointmentSheet` → `CreateAppointment_Widget` (nombre real del widget)

#### ❌ Intento de Fix: FAILED_PRECONDITION por índices compuestos faltantes
- [x] `clinic-service.dart`: Agregado `streamClinicPostsSimple()` (sin `orderBy`) como alternativa
- [x] `clinic-provider.dart`: `_subscribeToClinicFeed()` cambiado a `streamClinicPostsSimple` + ordenamiento en memoria con sort por `createdAt`
- [x] `dentist-profile-service.dart`: Eliminados `orderBy` + `limit` de `getFeaturedPosts`, `streamFeaturedPosts`, `getServices`, `streamServices`, `getGallery`, `streamGallery` — ordenamiento en memoria con sort

#### ❌ REVERTIDO — App se quedaba en blanco con `LateInitializationError` del engine de Flutter Web
- [x] Revertidos TODOS los cambios de esta sesión (agenda-tab, clinic-service, clinic-provider, dentist-profile-service)
- [x] Código vuelto exactamente al estado original antes de tocar nada
- [ ] ⚠️ Pendiente: Diagnosticar por qué los cambios dispararon el error del engine de Flutter Web (`canvaskit/surface.dart`) y aplicar los fixes de forma segura

### 📊 Resumen Actualizado
| Métrica | Valor |
|---------|-------|
| Archivos Dart totales | ~270+ |
| Servicios creados | ~30 |
| Providers creados | ~22 |
| Colecciones Firebase | 36 |
| Roles implementados | 6 (admin, dentist, doctor, employee, patient, delivery) |
| Pantallas funcionales | 30+ |
| Errores de compilación | 0 |
| dart analyze issues | 0 |
