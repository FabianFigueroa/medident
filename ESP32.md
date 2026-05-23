# ESP32 - Firmware para Control de Acceso IPS MedIdent

## Índice
1. [ESP32-RFID (Control de Acceso Completo)](#1-esp32-rfid)
2. [ESP32-CAM (Captura y Streaming)](#2-esp32-cam)
3. [Configuración Inicial](#3-configuracion)
4. [Diagrama de Conexiones](#4-diagrama)
5. [Cloud Functions](#5-cloud-functions)

---

## 1. ESP32-RFID

### Componentes
| Pin | Componente |
|-----|------------|
| D18 | RC522 - SCK |
| D19 | RC522 - MISO |
| D23 | RC522 - MOSI |
| D5  | RC522 - SDA |
| D4  | RC522 - RST |
| D15 | Relay (cerradura) |
| D2  | Buzzer |
| D12 | Sirena |
| D13 | LED Verde (acceso OK) |
| D14 | LED Rojo (acceso denegado) |
| D27 | PIR (movimiento) |
| D33 | Sensor Humo/Gas (analógico) |
| D32 | DHT22 - DATA |
| D21 | LCD I2C - SDA |
| D22 | LCD I2C - SCL |
| D34 | Keypad - R1 |
| D35 | Keypad - R2 |
| D25 | Keypad - R3 |
| D26 | Keypad - R4 |
| D16 | Keypad - C1 |
| D17 | Keypad - C2 |
| D36 | Keypad - C3 |

### Firmware Completo

```cpp
// ===== esp32-rfid-door.ino =====
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <MFRC522.h>
#include <DHT.h>
#include <LiquidCrystal_I2C.h>
#include <Keypad.h>
#include <ArduinoJson.h>
#include "config.h"
#include "secrets.h"

// ===== PIN DEFINITIONS =====
#define RST_PIN         4
#define SS_PIN          5
#define RELAY_PIN       15
#define BUZZER_PIN      2
#define SIREN_PIN       12
#define LED_GREEN       13
#define LED_RED         14
#define PIR_PIN         27
#define SMOKE_PIN       33
#define DHT_PIN         32

// ===== GLOBALS =====
MFRC522 rfid(SS_PIN, RST_PIN);
DHT dht(DHT_PIN, DHT22);
LiquidCrystal_I2C lcd(0x27, 16, 2);

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig fbConfig;

// Keypad
const byte KEYPAD_ROWS = 4;
const byte KEYPAD_COLS = 3;
byte rowPins[KEYPAD_ROWS] = {34, 35, 25, 26};
byte colPins[KEYPAD_COLS] = {16, 17, 36};
char keys[KEYPAD_ROWS][KEYPAD_COLS] = {
  {'1','2','3'},
  {'4','5','6'},
  {'7','8','9'},
  {'*','0','#'}
};
Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, KEYPAD_ROWS, KEYPAD_COLS);

// State
String deviceId;
String masterCardUID = "";
unsigned long lastHeartbeat = 0;
unsigned long lastSensorRead = 0;
unsigned long lastCommandCheck = 0;
unsigned long sirenStartTime = 0;
bool sirenActive = false;
bool doorOpen = false;

// ============================================================
void setup() {
  Serial.begin(115200);
  pinMode(RELAY_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(SIREN_PIN, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_RED, OUTPUT);
  pinMode(PIR_PIN, INPUT);
  pinMode(SMOKE_PIN, INPUT);

  digitalWrite(RELAY_PIN, HIGH); // NC - relay off
  digitalWrite(SIREN_PIN, LOW);

  deviceId = "door_" + String((uint32_t)ESP.getEfuseMac(), HEX);

  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("MedIdent IPS");
  lcd.setCursor(0, 1);
  lcd.print("Iniciando...");

  SPI.begin();
  rfid.PCD_Init();

  dht.begin();

  connectWiFi();
  initFirebase();
  loadMasterCard();

  digitalWrite(LED_GREEN, HIGH);
  delay(300);
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_RED, HIGH);
  delay(300);
  digitalWrite(LED_RED, LOW);

  lcd.clear();
  lcd.print("  Listo!");
  delay(1000);
  lcd.clear();
}

// ============================================================
void loop() {
  unsigned long now = millis();

  // Heartbeat cada 30s
  if (now - lastHeartbeat > 30000) {
    lastHeartbeat = now;
    sendHeartbeat();
  }

  // Sensores cada 10s
  if (now - lastSensorRead > 10000) {
    lastSensorRead = now;
    readSensors();
  }

  // Comandos cada 2s
  if (now - lastCommandCheck > 2000) {
    lastCommandCheck = now;
    checkCommands();
  }

  // Sirena timeout 30s
  if (sirenActive && now - sirenStartTime > 30000) {
    digitalWrite(SIREN_PIN, LOW);
    sirenActive = false;
  }

  // Keypad
  char key = keypad.getKey();
  if (key) handleKeypad(key);

  // RFID
  if (rfid.PICC_IsNewCardPresent() && rfid.PICC_ReadCardSerial()) {
    String uid = "";
    for (byte i = 0; i < rfid.uid.size; i++) {
      uid += String(rfid.uid.uidByte[i], HEX);
      if (i < rfid.uid.size - 1) uid += ":";
    }
    uid.toUpperCase();
    handleRFID(uid);
    rfid.PICC_HaltA();
  }

  // PIR - detect motion
  if (digitalRead(PIR_PIN) == HIGH) {
    logMotion();
    delay(2000); // debounce
  }
}

// ============================================================
void connectWiFi() {
  lcd.clear();
  lcd.print("WiFi...");
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 40) {
    delay(500);
    lcd.setCursor(0, 1);
    lcd.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    lcd.clear();
    lcd.print("WiFi OK");
    lcd.setCursor(0, 1);
    lcd.print(WiFi.localIP().toString());
    delay(1500);
  } else {
    lcd.clear();
    lcd.print("WiFi ERROR");
    lcd.setCursor(0, 1);
    lcd.print("Reintentando...");
    // AP mode fallback
    WiFi.mode(WIFI_AP);
    WiFi.softAP("MedIdent_" + deviceId, "12345678");
  }
}

// ============================================================
void initFirebase() {
  fbConfig.api_key = API_KEY;
  fbConfig.database_url = DATABASE_URL;

  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  Firebase.begin(&fbConfig, &auth);
  Firebase.reconnectWiFi(true);
  fbdo.setResponseSize(1024);
}

// ============================================================
void loadMasterCard() {
  if (Firebase.ready()) {
    String path = "/iot/" + deviceId + "/config/masterCardUID";
    if (Firebase.RTDB.getString(&fbdo, path)) {
      masterCardUID = fbdo.to<const char *>();
    }
  }
}

// ============================================================
void sendHeartbeat() {
  if (!Firebase.ready()) return;
  String path = "/iot/" + deviceId;
  FirebaseJson json;
  json.set("status", "online");
  json.set("heartbeat", String(millis()));
  Firebase.RTDB.setJSON(&fbdo, path, &json);
}

// ============================================================
void readSensors() {
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();
  int smokeRaw = analogRead(SMOKE_PIN);
  bool smoke = smokeRaw > 500;
  bool motion = digitalRead(PIR_PIN) == HIGH;

  if (isnan(temp) || isnan(hum)) return;

  if (!Firebase.ready()) return;
  String path = "/iot/" + deviceId + "/sensors";
  FirebaseJson json;
  json.set("temperature", temp);
  json.set("humidity", hum);
  json.set("smoke", smoke);
  json.set("smokeRaw", smokeRaw);
  json.set("motion", motion);
  Firebase.RTDB.setJSON(&fbdo, path, &json);

  // LCD update
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Temp: " + String(temp, 1) + "C");
  lcd.setCursor(0, 1);
  lcd.print("Hum: " + String(hum, 0) + "%");

  // Smoke alarm
  if (smoke && !sirenActive) {
    activateSiren();
  }
}

// ============================================================
void handleRFID(String uid) {
  // Beep on read
  digitalWrite(BUZZER_PIN, HIGH);
  delay(100);
  digitalWrite(BUZZER_PIN, LOW);

  // Master card - toggle registration mode
  if (uid == masterCardUID && masterCardUID != "") {
    lcd.clear();
    lcd.print("Tarjeta MAESTRA");
    lcd.setCursor(0, 1);
    lcd.print("Modo registro");
    digitalWrite(LED_GREEN, HIGH);
    delay(2000);
    digitalWrite(LED_GREEN, LOW);
    lcd.clear();
    return;
  }

  // Check if card is authorized in Firestore
  checkAndGrantAccess(uid);
}

// ============================================================
void checkAndGrantAccess(String uid) {
  if (!Firebase.ready()) return;

  // Write RFID scan to RTDB for Cloud Function to process
  String path = "/iot/" + deviceId + "/rfid";
  FirebaseJson json;
  json.set("uid", uid);
  json.set("timestamp", String(millis()));
  Firebase.RTDB.setJSON(&fbdo, path, &json);

  lcd.clear();
  lcd.print("Verificando...");
  lcd.setCursor(0, 1);
  lcd.print(uid);

  // Wait for Cloud Function to respond via commands
  unsigned long start = millis();
  bool granted = false;
  while (millis() - start < 5000) {
    String cmdPath = "/iot/" + deviceId + "/commands";
    if (Firebase.RTDB.getInt(&fbdo, cmdPath + "/relay")) {
      int cmd = fbdo.to<int>();
      if (cmd == 1) {
        granted = true;
        break;
      } else if (cmd == 0 && fbdo.dataPath().indexOf("deny") > 0) {
        break;
      }
    }
    // Also check direct grant result
    String grantPath = "/iot/" + deviceId + "/rfid/granted";
    if (Firebase.RTDB.getBool(&fbdo, grantPath)) {
      granted = fbdo.to<bool>();
      break;
    }
    delay(100);
  }

  if (granted) {
    grantAccess();
  } else {
    denyAccess();
  }

  // Clean up the rfid node
  Firebase.RTDB.deleteNode(&fbdo, path);
  Firebase.RTDB.setInt(&fbdo, "/iot/" + deviceId + "/commands/relay", 99);
}

// ============================================================
void grantAccess() {
  lcd.clear();
  lcd.print("  ACCESO OK");
  digitalWrite(LED_GREEN, HIGH);
  digitalWrite(RELAY_PIN, LOW); // Open door
  tone(BUZZER_PIN, 2000, 200);

  doorOpen = true;
  unsigned long start = millis();
  while (millis() - start < 4000) {
    // Wait 4 seconds
    delay(10);
    // Check if door closed (reed switch would go here)
  }
  digitalWrite(RELAY_PIN, HIGH); // Close door
  digitalWrite(LED_GREEN, LOW);
  doorOpen = false;
  lcd.clear();
}

// ============================================================
void denyAccess() {
  lcd.clear();
  lcd.print(" ACCESO DENEGADO");
  digitalWrite(LED_RED, HIGH);
  tone(BUZZER_PIN, 500, 500);
  delay(200);
  tone(BUZZER_PIN, 300, 500);
  delay(1000);
  digitalWrite(LED_RED, LOW);
  lcd.clear();
}

// ============================================================
void activateSiren() {
  digitalWrite(SIREN_PIN, HIGH);
  sirenActive = true;
  sirenStartTime = millis();
}

// ============================================================
void logMotion() {
  if (!Firebase.ready()) return;
  String path = "/iot/" + deviceId + "/sensors/motionEvent";
  FirebaseJson json;
  json.set("detected", true);
  json.set("timestamp", String(millis()));
  Firebase.RTDB.setJSON(&fbdo, path, &json);
}

// ============================================================
void checkCommands() {
  if (!Firebase.ready()) return;
  String cmdPath = "/iot/" + deviceId + "/commands";

  if (Firebase.RTDB.getInt(&fbdo, cmdPath + "/relay")) {
    int cmd = fbdo.to<int>();
    if (cmd == 1) {
      grantAccess();
      Firebase.RTDB.setInt(&fbdo, cmdPath + "/relay", 99);
    }
  }

  if (Firebase.RTDB.getBool(&fbdo, cmdPath + "/reboot")) {
    bool reboot = fbdo.to<bool>();
    if (reboot) {
      Firebase.RTDB.setBool(&fbdo, cmdPath + "/reboot", false);
      ESP.restart();
    }
  }

  if (Firebase.RTDB.getInt(&fbdo, cmdPath + "/siren")) {
    int cmd = fbdo.to<int>();
    if (cmd == 1) {
      activateSiren();
      Firebase.RTDB.setInt(&fbdo, cmdPath + "/siren", 99);
    } else if (cmd == 0) {
      digitalWrite(SIREN_PIN, LOW);
      sirenActive = false;
      Firebase.RTDB.setInt(&fbdo, cmdPath + "/siren", 99);
    }
  }
}

// ============================================================
void handleKeypad(char key) {
  static String pinBuffer = "";
  static unsigned long lastKeyTime = 0;

  if (millis() - lastKeyTime > 10000) pinBuffer = "";
  lastKeyTime = millis();

  if (key == '#') {
    if (pinBuffer.length() > 0) {
      checkPINCode(pinBuffer);
      pinBuffer = "";
    }
  } else if (key == '*') {
    pinBuffer = "";
    lcd.clear();
    lcd.print("PIN borrado");
    delay(500);
    lcd.clear();
  } else {
    pinBuffer += key;
    lcd.clear();
    lcd.print("PIN: ");
    for (int i = 0; i < pinBuffer.length(); i++) lcd.print("*");
  }
}

// ============================================================
void checkPINCode(String pin) {
  if (!Firebase.ready()) return;
  String path = "/iot/" + deviceId + "/rfid";
  FirebaseJson json;
  json.set("pin", pin);
  json.set("timestamp", String(millis()));
  Firebase.RTDB.setJSON(&fbdo, path, &json);

  lcd.clear();
  lcd.print("Verificando PIN...");
  delay(1000);

  // Same flow as RFID - Cloud Function responds
  checkAndGrantAccess("PIN_" + pin);
}
```

### Config header (secrets.h)
```cpp
// ===== secrets.h =====
// RENOMBRA este archivo a secrets.h y pon tus credenciales reales

#ifndef SECRETS_H
#define SECRETS_H

#define WIFI_SSID        "TU_WIFI_SSID"
#define WIFI_PASSWORD    "TU_WIFI_PASSWORD"
#define API_KEY          "AIzaSyAHP5CQ5xF4ktBJF85f7b8CHtUUnbEdNM8"
#define DATABASE_URL     "https://ips-medident-default-rtdb.firebaseio.com/"
#define USER_EMAIL       "esp32@medident.app"
#define USER_PASSWORD    "tu_password_segura"

#endif
```

### Config header (config.h)
```cpp
// ===== config.h =====
#ifndef CONFIG_H
#define CONFIG_H

#define FIRMWARE_VERSION "1.0.0"
#define DEVICE_TYPE "esp32_rfid"
#define HEARTBEAT_INTERVAL 30000
#define SENSOR_INTERVAL 10000

#endif
```

---

## 2. ESP32-CAM

### Componentes
| Pin | Componente |
|-----|------------|
| GPIO4 | PIR Sensor |
| GPIO12 | LED Flash |
| GPIO13 | LED Status |
| microSD | Almacenamiento local |

### Firmware Completo

```cpp
// ===== esp32-cam-capture.ino =====
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "esp_camera.h"
#include "SD_MMC.h"
#include "config.h"
#include "secrets.h"

// ===== CAMERA MODEL =====
// AI-Thinker ESP32-CAM
#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27
#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

#define PIR_PIN            4
#define FLASH_PIN         12
#define LED_STATUS        13

// ===== GLOBALS =====
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig fbConfig;

String deviceId;
unsigned long lastHeartbeat = 0;
unsigned long lastSnapshotCheck = 0;
int snapshotInProgress = 0;

// ============================================================
void setup() {
  Serial.begin(115200);

  pinMode(PIR_PIN, INPUT);
  pinMode(FLASH_PIN, OUTPUT);
  pinMode(LED_STATUS, OUTPUT);
  digitalWrite(FLASH_PIN, LOW);
  digitalWrite(LED_STATUS, LOW);

  deviceId = "cam_" + String((uint32_t)ESP.getEfuseMac(), HEX);

  // Init camera
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;
  config.frame_size = FRAMESIZE_SVGA; // 800x600 - balance quality/memory
  config.jpeg_quality = 12;
  config.fb_count = 1;
  config.grab_mode = CAMERA_GRAB_LATEST;

  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed: 0x%x", err);
    return;
  }

  // Init microSD
  if (!SD_MMC.begin()) {
    Serial.println("SD Card init failed");
  }

  connectWiFi();
  initFirebase();
  sendHeartbeat();

  digitalWrite(LED_STATUS, HIGH);
  delay(300);
  digitalWrite(LED_STATUS, LOW);
}

// ============================================================
void loop() {
  unsigned long now = millis();

  if (now - lastHeartbeat > 30000) {
    lastHeartbeat = now;
    sendHeartbeat();
  }

  // Check for snapshot command every 2s
  if (now - lastSnapshotCheck > 2000) {
    lastSnapshotCheck = now;
    checkSnapshotCommand();
  }

  // PIR motion - auto capture
  if (digitalRead(PIR_PIN) == HIGH && snapshotInProgress == 0) {
    digitalWrite(FLASH_PIN, HIGH);
    delay(100);
    captureAndUpload("motion");
    digitalWrite(FLASH_PIN, LOW);
    delay(5000); // debounce
  }

  // MJPEG stream handler (for local network access)
  handleStream();
}

// ============================================================
void connectWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 40) {
    delay(500);
    attempts++;
  }
}

// ============================================================
void initFirebase() {
  fbConfig.api_key = API_KEY;
  fbConfig.database_url = DATABASE_URL;

  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  Firebase.begin(&fbConfig, &auth);
  Firebase.reconnectWiFi(true);
  fbdo.setResponseSize(2048);
}

// ============================================================
void sendHeartbeat() {
  if (!Firebase.ready()) return;
  FirebaseJson json;
  json.set("status", "online");
  json.set("heartbeat", String(millis()));
  Firebase.RTDB.setJSON(&fbdo, "/iot/" + deviceId, &json);
}

// ============================================================
void checkSnapshotCommand() {
  if (!Firebase.ready() || snapshotInProgress > 0) return;

  String cmdPath = "/iot/" + deviceId + "/commands";
  if (Firebase.RTDB.getBool(&fbdo, cmdPath + "/snapshot")) {
    bool cmd = fbdo.to<bool>();
    if (cmd) {
      digitalWrite(FLASH_PIN, HIGH);
      delay(100);
      captureAndUpload("command");
      digitalWrite(FLASH_PIN, LOW);
      Firebase.RTDB.setBool(&fbdo, cmdPath + "/snapshot", false);
    }
  }
}

// ============================================================
void captureAndUpload(String trigger) {
  snapshotInProgress++;

  camera_fb_t *fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Camera capture failed");
    snapshotInProgress--;
    return;
  }

  digitalWrite(LED_STATUS, HIGH);

  // Save to SD first (fallback)
  String fileName = "/capture_" + String(millis()) + ".jpg";
  File file = SD_MMC.open(fileName, FILE_WRITE);
  if (file) {
    file.write(fb->buf, fb->len);
    file.close();
  }

  // Upload to Firebase Storage
  String storagePath = "iot/" + deviceId + "/captures/capture_" + String(millis()) + ".jpg";
  if (Firebase.Storage.upload(&fbdo, storagePath, fb->buf, fb->len, "image/jpeg")) {
    String downloadUrl = fbdo.downloadURL();
    digitalWrite(LED_STATUS, LOW);

    // Write URL to RTDB
    if (Firebase.ready()) {
      String rtdbPath = "/iot/" + deviceId + "/camera";
      FirebaseJson json;
      json.set("snapshotUrl", downloadUrl);
      json.set("trigger", trigger);
      json.set("timestamp", String(millis()));
      Firebase.RTDB.setJSON(&fbdo, rtdbPath, &json);
    }

    // Small delay for RAM recovery
    delay(500);
  } else {
    Serial.printf("Storage upload failed: %s\n", fbdo.errorReason().c_str());
    // On failure, still write the local path
    if (Firebase.ready()) {
      Firebase.RTDB.setString(&fbdo, "/iot/" + deviceId + "/camera/lastLocalFile", fileName);
    }
  }

  esp_camera_fb_return(fb);
  snapshotInProgress--;
}

// ============================================================
// MJPEG Streaming - accesible via http://esp32-cam-ip:81/stream
void handleStream() {
  static WiFiServer streamServer(81);
  static bool serverStarted = false;

  if (!serverStarted) {
    streamServer.begin();
    serverStarted = true;
  }

  WiFiClient client = streamServer.available();
  if (!client) return;

  // Simple MJPEG stream
  client.println("HTTP/1.1 200 OK");
  client.println("Content-Type: multipart/x-mixed-replace; boundary=frame");
  client.println("Connection: close");
  client.println();

  unsigned long streamStart = millis();
  while (client.connected() && millis() - streamStart < 30000) { // max 30s per connection
    camera_fb_t *fb = esp_camera_fb_get();
    if (!fb) continue;

    client.println("--frame");
    client.println("Content-Type: image/jpeg");
    client.print("Content-Length: ");
    client.println(fb->len);
    client.println();
    client.write(fb->buf, fb->len);
    client.println();

    esp_camera_fb_return(fb);
    delay(50); // ~20fps
  }
  client.stop();
}
```

### Config for ESP32-CAM (secrets.h - same as RFID)
```cpp
// ===== secrets.h (ESP32-CAM) =====
#ifndef SECRETS_H
#define SECRETS_H

#define WIFI_SSID        "TU_WIFI_SSID"
#define WIFI_PASSWORD    "TU_WIFI_PASSWORD"
#define API_KEY          "AIzaSyAHP5CQ5xF4ktBJF85f7b8CHtUUnbEdNM8"
#define DATABASE_URL     "https://ips-medident-default-rtdb.firebaseio.com/"
#define USER_EMAIL       "esp32cam@medident.app"
#define USER_PASSWORD    "tu_password_segura"

#endif
```

---

## 3. Configuración Inicial

### Hardware
1. Conecta los componentes según la tabla de pines
2. Alimentación: 5V 2A para ESP32-CAM, 5V 1A para ESP32-RFID
3. RC522: usar 3.3V (NO 5V)

### Software (IDE Arduino)
1. Instalar ESP32 board: `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json`
2. Instalar librerías:
   - `Firebase_ESP_Client` por mobizt
   - `MFRC522` por miguelbalboa
   - `DHT sensor library` por Adafruit
   - `LiquidCrystal_I2C`
   - `Keypad`
   - `ArduinoJson`

### Firebase Setup
1. Crear usuario en Firebase Auth para ESP32
2. Dar permisos en RTDB:
```json
{
  "rules": {
    "iot": {
      ".read": "auth.uid != null",
      ".write": "auth.uid != null"
    }
  }
}
```

---

## 4. Cloud Functions (TypeScript)

```typescript
// ===== functions/src/index.ts =====
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();
const rtdb = admin.database();

// ============================================================
// Trigger: cuando un ESP32 escribe un RFID en RTDB
// ============================================================
export const processRfidScan = functions.database
  .ref('/iot/{deviceId}/rfid')
  .onWrite(async (change, context) => {
    const { deviceId } = context.params;
    const data = change.after.val();
    if (!data || !data.uid) return;

    const uid = data.uid;
    const timestamp = data.timestamp || Date.now();

    try {
      // Buscar UID en Firestore
      const uidDoc = await db
        .collection('security')
        .doc('main')
        .collection('authorized_uids')
        .doc(uid)
        .get();

      const granted = uidDoc.exists && uidDoc.data()?.active === true;
      const userData = uidDoc.data();

      // Escribir respuesta en RTDB
      await rtdb.ref(`/iot/${deviceId}/commands`).update({
        relay: granted ? 1 : 0,
        deny: !granted,
      });

      // Registrar en Firestore access_log
      await db.collection('security').doc('main')
        .collection('access_log').add({
          uid,
          deviceId,
          granted,
          userId: userData?.userId || null,
          name: userData?.name || 'Desconocido',
          timestamp: admin.firestore.Timestamp.fromMillis(timestamp),
        });

      // Trigger snapshot en ESP32-CAM si hay una asociada
      const camDeviceId = deviceId.replace('door_', 'cam_');
      await rtdb.ref(`/iot/${camDeviceId}/commands`).update({
        snapshot: true,
      });

      // Push notification si acceso denegado
      if (!granted) {
        const payload = {
          topic: 'security_alerts',
          notification: {
            title: '⚠️ Acceso Denegado',
            body: `Tarjeta ${uid} intentó acceder por ${deviceId}`,
          },
        };
        await admin.messaging().send(payload);
      }
    } catch (error) {
      console.error('processRfidScan error:', error);
    }
  });

// ============================================================
// Trigger: cuando ESP32-CAM sube una foto
// ============================================================
export const processCameraCapture = functions.database
  .ref('/iot/{deviceId}/camera')
  .onWrite(async (change, context) => {
    const { deviceId } = context.params;
    const data = change.after.val();
    if (!data || !data.snapshotUrl) return;

    try {
      await db.collection('security').doc('main')
        .collection('captures').add({
          deviceId,
          snapshotUrl: data.snapshotUrl,
          trigger: data.trigger || 'motion',
          localFile: data.lastLocalFile || null,
          timestamp: admin.firestore.Timestamp.now(),
        });
    } catch (error) {
      console.error('processCameraCapture error:', error);
    }
  });

// ============================================================
// Trigger: heartbeat offline detection
// ============================================================
export const checkDeviceOffline = functions.database
  .ref('/iot/{deviceId}/heartbeat')
  .onWrite(async (change, context) => {
    const { deviceId } = context.params;
    const after = change.after.val();

    // Actualizar último seen en Firestore
    await db.collection('security').doc('main')
      .collection('devices').doc(deviceId).update({
        lastSeen: admin.firestore.FieldValue.serverTimestamp(),
        status: 'online',
      }).catch(() => {
        // Si el doc no existe, crearlo
        return db.collection('security').doc('main')
          .collection('devices').doc(deviceId).set({
            deviceId,
            lastSeen: admin.firestore.FieldValue.serverTimestamp(),
            status: 'online',
          });
      });
  });
```

---

## 5. Diagrama de Conexiones

```
ESP32-RFID:
┌─────────────────────────────────────────────────┐
│ ESP32 WROOM                                    │
│                                                 │
│ D18 ──── SCK  (RC522)                          │
│ D19 ──── MISO (RC522)                          │
│ D23 ──── MOSI (RC522)                          │
│ D5  ──── SDA  (RC522)                          │
│ D4  ──── RST  (RC522)                          │
│                                                 │
│ D15 ──── IN1  (Relay Module) ──── Cerradura     │
│ D2  ──── +    (Buzzer activo)                   │
│ D12 ──── SIG  (Sirena)                          │
│ D13 ──── Ánodo (LED Verde)                      │
│ D14 ──── Ánodo (LED Rojo)                       │
│                                                 │
│ D27 ──── OUT  (PIR Sensor)                      │
│ D33 ──── A0   (MQ-2/Smoke Sensor)               │
│ D32 ──── DATA (DHT22)                           │
│                                                 │
│ D21 ──── SDA  (LCD I2C)                         │
│ D22 ──── SCL  (LCD I2C)                         │
│                                                 │
│ D34-D36 ──── Keypad 4x3                         │
└─────────────────────────────────────────────────┘

ESP32-CAM:
┌─────────────────────────────────────────────────┐
│ ESP32-CAM (AI-Thinker)                          │
│                                                 │
│ GPIO4  ──── PIR Sensor                          │
│ GPIO12 ──── LED Flash                           │
│ GPIO13 ──── LED Status                          │
│                                                 │
│ microSD ──── built-in slot                      │
│ Camera  ──── OV2640 (built-in)                  │
│                                                 │
│ Alimentación: 5V 2A (NO 3.3V!)                 │
└─────────────────────────────────────────────────┘
```
