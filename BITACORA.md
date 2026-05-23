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
