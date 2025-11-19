/*
 * ESP32 Code untuk Smart Air Monitoring
 * Tugas: Membaca sensor dan mengirim data ke Backend API
 * 
 * Sensor yang digunakan:
 * - CO2 Sensor (misal: MH-Z19B)
 * - CO Sensor (misal: MQ-7)
 * - Dust Sensor (misal: GP2Y1010AU0F)
 * 
 * ALUR 1: Sensor Mengirim Data ke Neon DB
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// ============================================
// KONFIGURASI WIFI
// ============================================
const char* ssid = "NAMA_WIFI_ANDA";
const char* password = "PASSWORD_WIFI_ANDA";

// ============================================
// KONFIGURASI API
// ============================================
const char* apiUrl = "https://api.proyekanda.com/api/data/baru";
// Untuk testing lokal: "http://192.168.1.100:3000/api/data/baru"

// ============================================
// KONFIGURASI SENSOR (Pin)
// ============================================
// Sesuaikan dengan pin yang Anda gunakan
#define CO2_SENSOR_PIN A0
#define CO_SENSOR_PIN A1
#define DUST_SENSOR_PIN A2

// ============================================
// KONFIGURASI KONTROL FAN
// ============================================
#define FAN_RELAY_PIN 4  // Pin untuk relay exhaust fan
bool fanStatus = false;
bool autoMode = true;

// Interval pengiriman data (dalam milidetik)
const unsigned long SEND_INTERVAL = 60000; // 1 menit
const unsigned long POLL_INTERVAL = 30000; // 30 detik (untuk polling status kontrol)

unsigned long lastSendTime = 0;
unsigned long lastPollTime = 0;

// ============================================
// SETUP
// ============================================
void setup() {
  Serial.begin(115200);
  delay(1000);

  // Setup pin
  pinMode(FAN_RELAY_PIN, OUTPUT);
  digitalWrite(FAN_RELAY_PIN, LOW); // Fan OFF default

  // Koneksi WiFi
  Serial.println("Connecting to WiFi...");
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println("");
  Serial.println("WiFi connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  // Setup sensor (jika perlu)
  // setupSensors();
}

// ============================================
// LOOP UTAMA
// ============================================
void loop() {
  unsigned long currentTime = millis();

  // ALUR 1: Kirim data sensor setiap 1 menit
  if (currentTime - lastSendTime >= SEND_INTERVAL) {
    sendSensorData();
    lastSendTime = currentTime;
  }

  // ALUR 3: Polling status kontrol setiap 30 detik
  if (currentTime - lastPollTime >= POLL_INTERVAL) {
    pollControlStatus();
    lastPollTime = currentTime;
  }

  delay(1000); // Delay 1 detik
}

// ============================================
// FUNGSI: Baca Data Sensor
// ============================================
float readCO2() {
  // Contoh: Baca dari sensor CO2
  // Sesuaikan dengan sensor yang Anda gunakan
  int rawValue = analogRead(CO2_SENSOR_PIN);
  float co2 = map(rawValue, 0, 4095, 400, 2000); // Contoh mapping
  return co2;
}

float readCO() {
  // Contoh: Baca dari sensor CO
  int rawValue = analogRead(CO_SENSOR_PIN);
  float co = map(rawValue, 0, 4095, 0, 100); // Contoh mapping
  return co;
}

float readDust() {
  // Contoh: Baca dari sensor Debu
  int rawValue = analogRead(DUST_SENSOR_PIN);
  float dust = map(rawValue, 0, 4095, 0, 200); // Contoh mapping
  return dust;
}

// ============================================
// ALUR 1: Kirim Data ke Backend API
// ============================================
void sendSensorData() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi not connected!");
    return;
  }

  // Baca data dari sensor
  float co2 = readCO2();
  float co = readCO();
  float dust = readDust();

  Serial.println("Reading sensors...");
  Serial.printf("CO2: %.2f ppm, CO: %.2f ppm, Debu: %.2f µg/m³\n", co2, co, dust);

  // Buat JSON payload
  StaticJsonDocument<200> doc;
  doc["co2"] = co2;
  doc["co"] = co;
  doc["debu"] = dust;

  String jsonPayload;
  serializeJson(doc, jsonPayload);

  // Kirim HTTP POST ke API
  HTTPClient http;
  http.begin(apiUrl);
  http.addHeader("Content-Type", "application/json");

  int httpResponseCode = http.POST(jsonPayload);

  if (httpResponseCode > 0) {
    Serial.printf("✅ Data sent successfully! Response code: %d\n", httpResponseCode);
    String response = http.getString();
    Serial.println("Response: " + response);
  } else {
    Serial.printf("❌ Error sending data: %d\n", httpResponseCode);
  }

  http.end();
}

// ============================================
// ALUR 3: Polling Status Kontrol dari API
// ============================================
void pollControlStatus() {
  if (WiFi.status() != WL_CONNECTED) {
    return;
  }

  HTTPClient http;
  String controlUrl = String(apiUrl);
  controlUrl.replace("/api/data/baru", "/api/kontrol/status");
  
  http.begin(controlUrl);
  int httpResponseCode = http.GET();

  if (httpResponseCode == 200) {
    String response = http.getString();
    
    // Parse JSON response
    StaticJsonDocument<200> doc;
    deserializeJson(doc, response);

    String fanStatusStr = doc["fan"];
    String modeStr = doc["mode"];

    // Update status fan
    if (fanStatusStr == "ON" && !fanStatus) {
      digitalWrite(FAN_RELAY_PIN, HIGH);
      fanStatus = true;
      Serial.println("🔵 Fan turned ON");
    } else if (fanStatusStr == "OFF" && fanStatus) {
      digitalWrite(FAN_RELAY_PIN, LOW);
      fanStatus = false;
      Serial.println("⚪ Fan turned OFF");
    }

    // Update mode
    autoMode = (modeStr == "AUTO");
    
    Serial.printf("Control status: Fan=%s, Mode=%s\n", fanStatusStr.c_str(), modeStr.c_str());
  } else {
    Serial.printf("❌ Error polling control: %d\n", httpResponseCode);
  }

  http.end();
}

// ============================================
// FUNGSI: Kontrol Fan Otomatis (Mode AUTO)
// ============================================
void checkAutoMode() {
  if (!autoMode) {
    return; // Mode manual, tidak perlu kontrol otomatis
  }

  // Baca sensor
  float co2 = readCO2();
  float co = readCO();
  float dust = readDust();

  // Logika: Jika kualitas udara buruk, nyalakan fan
  bool shouldTurnOn = (co2 > 1000) || (co > 50) || (dust > 100);

  if (shouldTurnOn && !fanStatus) {
    digitalWrite(FAN_RELAY_PIN, HIGH);
    fanStatus = true;
    Serial.println("🔵 Auto: Fan turned ON (poor air quality)");
  } else if (!shouldTurnOn && fanStatus) {
    digitalWrite(FAN_RELAY_PIN, LOW);
    fanStatus = false;
    Serial.println("⚪ Auto: Fan turned OFF (air quality improved)");
  }
}

