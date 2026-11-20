# BITÁCORA - IPS MedIdent

## Plan de Programación ESP32 / ESP32-CAM

### Objetivo
Integrar múltiples dispositivos ESP32 (RFID, sensores) y ESP32-CAM (cámaras) con la app Flutter mediante Firebase Realtime Database para control de acceso, monitoreo y videovigilancia en la IPS.

### Arquitectura

```
ESP32/ESP32-CAM → WiFi → RTDB (comunicación real-time)
                    ↓
         onWrite trigger → Cloud Function (middleware)
                    ├── → Firestore (persistencia + histórico)
                    ├── → FCM (push notifications)
                    └── → RTDB /commands (respuesta al ESP)
                                    ↓
                           Flutter App (Firestore para negocio, RTDB para estado vivo)
```

### Componentes

#### 1. ESP32 Base (RFID + Sensores)
- **Microcontrolador**: ESP32-WROOM-32
- **Módulo RFID**: RC522 (SPI)
- **Sensores**: DHT22 (temperatura/humedad), PIR (movimiento), reed switch (puerta)
- **Actuadores**: Relé para cerradura eléctrica, buzzer, LED RGB

#### 2. ESP32-CAM (Videovigilancia)
- **Modelo**: ESP32-CAM (AI-Thinker)
- **Cámara**: OV2640 (2MP)
- **Almacenamiento**: MicroSD para buffer local
- **Funciones**: Captura por movimiento, transmisión MJPEG, snapshot a Firebase Storage

### Bases de datos (dual)

#### RTDB (comunicación ESP — tiempo real)
```
/iot/{deviceId}/
  ├── status: "online" | "offline"           # heartbeat cada 30s
  ├── rfid: { uid: string, timestamp: number } # última lectura RFID
  ├── sensors: { temperature, humidity, motion, doorOpen }
  ├── camera: { snapshotUrl: string, lastCapture: number }
  └── commands: {                            # Cloud Function → ESP
        relay: 0 | 1,
        snapshot: true,
        reboot: true
      }
```

#### Firestore (persistencia — negocio)
```
/security/{clinicId}/devices/{deviceId}
  ├── type: "esp32_rfid" | "esp32_cam"
  ├── name: string
  ├── hardwareId: string (misma que RTDB)
  ├── config: {...}  // configuración persistente
  └── firmware: { version: string, updateUrl: string }

/security/{clinicId}/access_log/{logId}
  ├── uid: string          // UID de tarjeta
  ├── userId: string       // usuario autorizado (nullable si no registrado)
  ├── deviceId: string
  ├── granted: bool
  ├── timestamp: timestamp
  └── snapshotUrl: string  // foto ESP32-CAM del evento

/security/{clinicId}/authorized_uids/{uid}
  ├── userId: string
  ├── name: string
  ├── role: "dentist" | "staff" | "admin"
  └── active: bool
```

### Flujo RFID (Control de Acceso)

1. Usuario acerca tarjeta RFID → ESP32 lee UID
2. ESP32 escribe en **RTDB**: `/iot/{deviceId}/rfid` = `{uid, timestamp}`
3. Cloud Function `processRfidScan()` se activa (onWrite):
   a. Busca UID en Firestore `authorized_uids/{uid}`
   b. Si autorizado → escribe `commands: {relay: 1}` en RTDB
   c. Si NO autorizado → escribe `commands: {relay: 0, deny: true}`
   d. Registra en Firestore `access_log` con resultado
   e. Envía Push Notification al admin (opcional, solo denegados)
4. ESP32 lee `commands` de RTDB y ejecuta (abre/deniega)
5. ESP32 borra `rfid` leído + `commands` ejecutado

### Flujo ESP32-CAM (Captura por Movimiento)

1. Sensor PIR detecta movimiento → ESP32-CAM captura foto
2. Foto guardada en MicroSD + upload a Firebase Storage
3. URL guardada en RTDB: `/security/{clinicId}/devices/{deviceId}/camera/snapshotUrl`
4. App recibe notificación push con la imagen
5. Streaming MJPEG en red local para visualización en tiempo real

### Firmware Arduino (Framework)

#### libraries necesarias:
- `WiFi.h` / `HTTPClient.h` — conexión y REST
- `Firebase_ESP_Client.h` — Firebase RTDB + Storage
- `MFRC522.h` — RFID
- `DHT.h` — sensor temp/humedad
- `esp_camera.h` — ESP32-CAM (solo para ese modelo)
- `ArduinoJson.h` — parseo JSON

#### Estructura del código Arduino:
```
medident-esp32/
├── libraries/
│   └── MedIdentWiFi/       # Conexión WiFi automática con fallback AP
├── esp32-rfid-door/
│   ├── esp32-rfid-door.ino # Loop principal RFID + relé
│   ├── config.h            # WiFi, Firebase, pines
│   └── secrets.h           # Credenciales (ignorado por git)
├── esp32-cam-snapshot/
│   ├── esp32-cam-snapshot.ino # Loop captura + upload
│   ├── config.h
│   └── secrets.h
└── shared/
    ├── firebase-helpers.h  # Funciones comunes Firebase
    └── sensor-helpers.h    # Lectura sensores común
```

### Fases de Implementación

| Fase | Descripción | Tiempo estimado |
|------|-------------|-----------------|
| 1 | Setup WiFi + Firebase RTDB desde ESP32 | 1 semana |
| 2 | RFID: lectura UID + escritura en RTDB + control relé | 1 semana |
| 3 | Sensores: DHT22 + PIR + reed switch → RTDB | 3 días |
| 4 | ESP32-CAM: captura + upload Storage + streaming local | 1.5 semanas |
| 5 | App: listener RTDB + notificaciones + control remoto | 1 semana |
| 6 | Dashboard admin: ver estado dispositivos + historial | 1 semana |
| 7 | OTA firmware updates desde Firebase | 3 días |
| 8 | Pruebas en producción (IPS) | 1 semana |

### Recursos
- Documentación Firebase ESP32: https://github.com/mobizt/Firebase-ESP-Client
- Librería ESP32-CAM: https://github.com/espressif/esp32-camera
- MFRC522: https://github.com/miguelbalboa/rfid

---

## Registro de modulos terminados (compilados sin error)

Ultima verificacion: `flutter build web --release --no-wasm-dry-run` OK.

### Providers por rol (verificado)
- Dentist: DentistMainProvider + home, profile, security, clinic, clinicStatus, delivery.
- Employee: EmployeeMainProvider + home, profile, security, delivery, clinic.
- Doctor: DoctorMainProvider + home, profile, security, shop, delivery, clinic.
- Patient: PatientMainProvider + home, profile, security, shop, delivery.
- Admin: AdminMainProvider + home, security, delivery, profile, shops, contract.
- Delivery: DeliveryMainProvider + home, profile, security.
- Todos se registran en `lib/core/auth/authgate.dart`.

### Modulos funcionales terminados
- [x] Feed del dentista con posts propios + posts de clinicas seguidas (dedupe + cache).
- [x] Seguir/dejar de seguir clinicas y explorar clinicas (`clinic-follow-service`).
- [x] Perfil publico de clinica con feed y boton seguir.
- [x] Buscador global (Todo/Usuarios/Clinicas/Posts) con filtrado instantaneo.
- [x] Crear publicacion desde AppBar movil (reemplaza icono QR).
- [x] Historial clinico por paciente con notas, edicion y eliminacion.
- [x] Pacientes por clinica (stream + busqueda) en pestana "Pacientes".
- [x] Nuevo paciente: ficha clinica completa (genero con 2 avatares, datePicker,
      dropdowns de estado civil, escolaridad, tipo de sangre, EPS, fumador,
      alcohol, antecedentes como chips, alergias, medicamentos, notas).
- [x] Nuevo empleado: buscar cuenta existente y enviar solicitud o vincular
      directamente; crear empleado sin cuenta y vincularlo.
- [x] Invitaciones de clinica visibles para el empleado (aceptar/rechazar).
- [x] Turnos: dueno vs empleado, solicitudes de cambio con aprobacion/rechazo.
- [x] Stories: tarjeta "Mi historia" con boton + grande e indicador verde de activo.
- [x] Stories: visor con soporte de video, editar texto y eliminar historias propias.
- [x] Stories: nueva pantalla de subida estilo Instagram (galeria/video/camara,
      preview, caption superpuesto, progreso de subida y publicacion).
- [x] Fix subida web a Firebase Storage: CORS del bucket con metodos
      GET/HEAD/PUT/POST/DELETE/OPTIONS y rules desplegadas desde `storage.rules`.
- [x] Stories visibles 30 segundos en el visor.
- [x] Valeria IA oculta con flag reversible (`_showValeriaAssistant = false`).

### Widgets globales reutilizables
- `MedidentCollapsingBar` (AppBar + carrusel, compartido por roles).
- `ClinicFollowButton`, `PendingClinicInvitesCard`, `Create_Newposts_Widget`.
- `GlobalSearchScreen`, `ClinicPublicScreen`, `NotificationScreen`.
- `PatientDetailScreen`, `PatientListScreen(embedInNestedScroll)`.
- `PatientSearchSheet`, `RequestTurnoChangeSheet`.

### Servicios clave
- `EmployeeLinkService` (`clinic_link_requests` + `clinics/{id}/employees`).
- `PatientService` (users + patient_profiles + clinical_records).
- `ClinicFollowService`, `GlobalSearchService`, `AgendaService`, `ClinicService`.

### Pendiente / siguiente
- [ ] Reemplazar el manager mock de empleados (`dentist-employee-manager.dart`).
- [ ] Panel del dueno para ver solicitudes enviadas y cancelarlas.
- [ ] Aceptacion de invitacion desde notificaciones (ademas del home empleado).
- [ ] Completar `firestore.rules` e indices para nuevas colecciones.
- [ ] Fase 5 IoT (listener RTDB en la app).
- [x] Clinica: encabezado muestra nombre/logo/descripcion/direccion de la clinica
      (antes usaba el usuario dueno) y contadores reales de pacientes, equipo,
      seguidores, publicaciones, likes y fotos.
- [x] Empleados: campo canManageAgenda en modelo/servicio; pestana "Equipo"
      para activar/desactivar y otorgar permiso de agenda.
- [x] Agenda/Turnos: todos los miembros ven la agenda completa; solo el dueno o
      empleados con canManageAgenda pueden crear/editar/confirmar/cancelar.
- [x] Tratamientos: la clinica carga solo sus tratamientos (clinicId) y el
      home del dentista filtra por la clinica del usuario.
- [x] Build web release y relanzamiento en puerto 5174.
- [x] Configuracion de cuenta (dentista) reescrita en espanol y conectada a
      Firestore/Auth: datos reales del usuario, formulario editable (nombre,
      usuario, telefono, especialidad, licencia, direccion, web) y
      profileCaption/bio; logout y recuperacion de contrasena reales.
- [x] Perfil: boton Editar perfil solo para el propio usuario; otros usuarios
      ven Seguir/Siguiendo con estado real de Firestore. Perfil publico muestra
      mas informacion (especialidad, licencia, telefono, direccion, web, bio).
- [x] Soporte para abrir el perfil de otro usuario (DentistProfileScreen(userId)).
- [x] Navegacion del dentista: Home, Clinica, Agenda, Turnos y Perfil
      (se retiraron Security y Delivery del bottom nav).
- [x] Nueva "Mi agenda" personal: citas propias de la clinica, avatares
      horizontales de pacientes y solicitantes pendientes (anillo naranja),
      selector de semana moderno con chevrons/calendario, vista dia/semana,
      lista agrupada y ordenada, acceso a historia clinica y nueva cita.
- [x] Nueva "Mis turnos laborales": turnos propios (`employeeId`), resumen de
      hoy/proximos, selector de semana, vista dia/semana y lista agrupada.
- [x] Estado sin clinica en la agenda con acceso a notificaciones/onboarding.
- [x] `flutter analyze` sin errores, build web release y relanzamiento.
- [x] Agenda/Turnos cableados con la arquitectura de providers: nuevo
      `DentistAgendaProvider` (citas + pacientes en tiempo real, estadisticas,
      filtros y refresh) y `DentistTurnosProvider` (turnos propios en tiempo
      real, resumen y agrupaciones), registrados como sub-secciones `agenda` y
      `turnos` de `DentistMainProvider` con lazy init y dispose.
- [x] `AgendaService.streamTurnosByEmployee` y `AppointmentProvider.refresh`.
- [x] UI con shimmer de carga, pull-to-refresh, resumen con gradiente,
      selector de semana, vista dia/semana y estado sin clinica con CTA a
      onboarding; permisos `canManageAgenda` respetados en la agenda.
- [x] Agenda/Turnos disponibles tambien para doctor y empleado reutilizando
      `PersonalAgendaView` y `PersonalTurnosView`; sub-secciones `agenda` y
      `turnos` en sus `MainProvider` y nuevos items de navegacion.
- [x] Paciente: nueva "Mis citas" con `PatientAppointmentService` (stream por
      `patientId`), sub-seccion `agenda` en `PatientMainProvider` e item de
      navegacion; sin creacion de citas desde esa pantalla.
- [x] Layout de agenda/turnos centrado y con ancho maximo para tablet/desktop.
- [x] Pacientes: codigo corto `MED-XXXXXX` generado al registrarse, busqueda por
      nombre/UID/codigo/telefono/email, QR del perfil visible en la ficha y
      lectura de QR con camara desde el buscador de pacientes al crear citas.
- [x] Nueva cita: selectores rapidos de profesional, tratamiento y hora,
      busqueda de paciente con boton QR; el profesional se elige entre los
      miembros de la clinica cuando agenda un empleado.
- [x] Turnos del empleado: confirmar/declinar asistencia (con motivo), aviso a
      la clinica, boton de novedad del dia y contador de tiempo restante.
- [x] Recordatorios in-app de asistencia una semana antes y el mismo dia del
      turno, con marcas `reminderWeekSent`/`reminderDaySent` para no repetirlos.
- [x] `flutter analyze` sin errores y build web release actualizado.
- [x] Turnos: boton flotante "Solicitud" en la pantalla de Mis turnos con
      tipos novedad, cambio de horario, cambio de turno e intercambio; permite
      elegir turno, fecha/horas nuevas y nombre/UID del companero implicado.
      Se guardan `targetEmployeeId`, `targetEmployeeName`, `targetTurnoId` y el
      horario solicitado, y se notifica al dueno y al empleado implicado.
- [x] Las solicitudes muestran el tipo real y el empleado implicado en las
      pantallas de admin y de la clinica.
- [x] Home: nueva tarjeta unica `ClinicsPromotionCard` que carga todas las
      clinicas activas y lleva a Explorar clinicas; insertada en los homes
      mobile de dentista, doctor, empleado y paciente.
- [x] Home empleado: se elimino el widget/seccion de turnos del home (la
      gestion queda en la pantalla de Mis turnos).
- [x] Imagenes: `ProductModel.fromJson` ahora acepta `imageUrls`, `images`,
      `photos`, `imageUrl`, `image`, `photo`, `photoUrl`, `thumbnail` y usa las
      slides como respaldo; corrige portadas/promos sin imagen.
- [x] Paciente: home tablet/desktop reutiliza el home mobile (antes mostraban
      un Placeholder).
- [x] Crear clinica: el logo elegido ahora se sube a Firebase Storage
      (`clinics/{uid}/logo_*`) y se guarda en `logoUrl` (antes siempre se
      enviaba null).
- [x] Join por codigo/UID: ademas de `employeeIds` y `users.clinicId`, ahora
      crea `clinics/{id}/employees/{uid}` con cargo segun rol; leaveClinic
      elimina ese registro. Los profesionales vinculados resuelven agenda,
      turnos y permisos correctamente.



- [x] Nueva publicacion: reescrito create_newposts_widget.dart. El boton de
      crear publicacion abre un selector horizontal de tipos (Pensar, Foto,
      Promo, Evento, Encuesta, Video, Enlace, Apoyo, Grupo, Streaming); al
      tocar una card se abre la pantalla de creacion de ese tipo. Soporta
      subida real de imagenes (camara/galeria, multiples) y video a Firebase
      Storage (posts/users/{uid}/... o posts/clinics/{clinicId}/...),
      guarda media, imageUrls y el resto de campos (sourceType/sourceId/
      sourceName/sourcePhoto) en la coleccion posts, por lo que las tarjetas
      del home muestran el contenido multimedia. Promo redirige al editor de
      promociones.
- [x] Perfil: nueva tarjeta ProfileClinicCard que muestra la clinica
      vinculada del usuario (logo, nombre y badge Owner/Miembro) y abre
      ClinicPublicScreen al tocarla. Insertada en los perfiles de dentista,
      doctor, empleado y paciente.
- [x] lutter analyze sin errores nuevos y build web release actualizado.

- [x] Home: la cabecera colapsable ya no deja fijado el texto del usuario ni
      el mensaje "Aun no hay promociones" cuando se colapsa; el contenido de la
      cabecera vacia se desvanece al colapsar. Se dejo de usar el email como
      nombre de usuario.
- [x] Home: corregido el mapeo del feed intercalado que duplicaba posts (cada
      tercer post aparecia dos veces). Ahora el patron es post, post, post,
      widget sin repetidos.
- [x] Media: MediaItem.fromFirestore es mas robusto: cae a imageUrls /
      imageUrl / photoUrl / image / photo / 	humbnail cuando media
      viene vacio o con tipos no estandar, por lo que los posts de imagen-texto
      vuelven a mostrar su foto.
- [x] Home: los widgets intercalados ya no dejan un shimmer permanente; solo
      muestran shimmer mientras cargan y se ocultan si no hay datos. Ademas se
      agrego un tiempo maximo para salir del shimmer de carga inicial si
      Firestore no responde.
- [x] lutter analyze sin errores nuevos y build web release actualizado.

- [x] Perfil (dentista): el boton "Editar perfil" del perfil propio ahora es
      "Crear contenido" y abre el selector de publicaciones en modo clinica
      (usa el clinicId del usuario/clinica), por lo que lo publicado queda a
      nombre de la clinica (sourceType clinic, sourceName/logo de la clinica).
- [x] Home (dentista): al crear publicaciones desde el home ya NO se envia
      clinicId, por lo que quedan a nombre del usuario actual. El feed del home
      se dejo general (no filtrado por la clinica del usuario).
- [x] Seccion de la clinica: el acceso de creacion ahora se rotula
      "Crear contenido para la clinica..." y publica como clinica.
- [x] Tarjeta de clinica en el perfil: ProfileClinicCard ahora resuelve la
      clinica por clinicId, por usuario o por ownerId/employeeIds, y al tocarla
      abre correctamente ClinicPublicScreen. Se aplica en perfiles de
      dentista, doctor, empleado y paciente.
- [x] lutter analyze sin errores nuevos y build web release actualizado.

- [x] CORRECCION: se quito el boton "Crear contenido" del perfil del usuario
      (all� no debe estar) y se agrego en la barra/encabezado del PERFIL DE LA
      CLINICA (Clinic_Header_Widget, junto a Editar), solo para el owner.
- [x] Al publicar una PROMOCION desde la clinica se guarda con scope: global,
      por lo que aparece sola en el carrusel del collapsingBar() del home de
      todos y en la tarjeta/carrusel promocional del feed del home.
- [x] Toda promocion (clinica o usuario) ahora tambien crea su documento en
      posts, de modo que se ve de inmediato en el feed del home, en el feed de
      la clinica y en la galeria del perfil.
- [x] Nuevo ProfilePostsGrid: miniaturas estilo Instagram (3 columnas) con los
      posts del usuario actual, en tiempo real (stream), debajo del perfil.
- [x] Carrusel del home muestra el nombre real del promotor (clinica) en lugar
      del usuario que esta viendo la app.
- [x] Stories: corregido el visor en blanco (ahora inicializa la lista desde
      widget.stories y ajusta el indice inicial al rango valido).
- [x] Stories: se guarda expiresAt (24 h) al crearlas, se filtran las vencidas
      en el home y en "mis historias", y se eliminan automaticamente de
      Firestore al cargar el feed (purgeExpiredStories).
- [x] Se unifico la creacion de publicaciones en UNA sola pantalla: se elimino
      el selector previo de tipos y ahora el tipo se elige con un desplegable
      (dropdown) dentro de la misma pantalla; la fecha/lugar y demas campos
      cambian segun el tipo elegido.
- [x] Las imagenes y el video se pueden quitar/agregar antes de publicar
      (vista previa con boton de eliminar y opcion de agregar mas medios).
- [x] flutter analyze limpio (solo las 5 advertencias ya aceptadas) y build web
      release actualizado.
- [x] REFACTOR de creacion de publicaciones: se eliminaron las pantallas y
      formularios por tipo (evento, encuesta, enlace, grupo, apoyo, promo,
      etc.). Ahora existe UNA sola pantalla que abre directamente el selector
      de Camara / Galeria de fotos / Video / Solo texto del dispositivo.
- [x] Las fotos y el video seleccionados se muestran en un scroll horizontal
      con miniatura; cada elemento se puede editar (imagen: filtros/ajustes y
      texto con ImageEditorScreen; video: cambiar o quitar) o eliminar antes de
      publicar.
- [x] La descripcion es opcional; ya no se exige nombre, precio, descuento ni
      ningun otro campo. Se publica solo con medios o solo con texto.
- [x] Firebase: los archivos se suben en paralelo a Storage
      (posts/users/{uid} o posts/clinics/{clinicId}) con cacheControl inmutable,
      y luego se crea el documento en Firestore con media/imageUrls, source y
      conteos. Barra de progreso durante la subida.
- [x] Calidad/velocidad: fotos tomadas de camara/galeria a 1920px y calidad 90,
      subida concurrente y miniaturas en memoria (previsualizacion inmediata).
- [x] flutter analyze limpio y build web release actualizado.
