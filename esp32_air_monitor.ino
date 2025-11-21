/*
 * ESP32 Air Quality Monitor
 * Mengirim data sensor CO2, CO, dan Debu ke database
 * Membaca status kontrol fan dari database
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// ===== KONFIGURASI WIFI =====
const char* ssid = "NAMA_WIFI_ANDA";           // Ganti dengan nama WiFi Anda
const char* password = "PASSWORD_WIFI_ANDA";   // Ganti dengan password WiFi Anda

// ===== KONFIGURASI SERVER =====
// Ganti dengan URL aplikasi Next.js Anda (setelah deploy)
// Contoh: "https://your-app.vercel.app" atau "http://192.168.1.100:3000" (local)
const char* serverUrl = "http://192.168.1.100:3000";  // Ganti dengan URL server Anda

// ===== PIN KONFIGURASI =====
const int FAN_PIN = 2;           // Pin untuk relay fan (GPIO2)
const int CO2_SENSOR_PIN = 34;   // Pin analog untuk sensor CO2 (GPIO34)
const int CO_SENSOR_PIN = 35;    // Pin analog untuk sensor CO (GPIO35)
const int DUST_SENSOR_PIN = 32;  // Pin analog untuk sensor debu (GPIO32)

// ===== VARIABEL GLOBAL =====
unsigned long lastSensorRead = 0;
unsigned long lastControlCheck = 0;
const unsigned long SENSOR_INTERVAL = 3000;    // Kirim data sensor setiap 3 detik
const unsigned long CONTROL_INTERVAL = 2000;   // Cek kontrol fan setiap 2 detik

String currentFanStatus = "OFF";
String currentMode = "AUTO";

void setup() {
  Serial.begin(115200);
  
  // Setup pin
  pinMode(FAN_PIN, OUTPUT);
  digitalWrite(FAN_PIN, LOW);
  
  // Koneksi WiFi
  connectWiFi();
}

void loop() {
  // Pastikan WiFi tetap terhubung
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi terputus, mencoba koneksi ulang...");
    connectWiFi();
  }
  
  unsigned long currentMillis = millis();
  
  // Baca dan kirim data sensor
  if (currentMillis - lastSensorRead >= SENSOR_INTERVAL) {
    lastSensorRead = currentMillis;
    readAndSendSensorData();
  }
  
  // Cek status kontrol fan
  if (currentMillis - lastControlCheck >= CONTROL_INTERVAL) {
    lastControlCheck = currentMillis;
    checkFanControl();
  }
}

void connectWiFi() {
  Serial.println();
  Serial.print("Menghubungkan ke WiFi: ");
  Serial.println(ssid);
  
  WiFi.begin(ssid, password);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println();
    Serial.println("WiFi terhubung!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println();
    Serial.println("Gagal terhubung ke WiFi!");
  }
}

void readAndSendSensorData() {
  // Baca sensor (sesuaikan dengan sensor Anda)
  float co2 = readCO2Sensor();
  float co = readCOSensor();
  float dust = readDustSensor();
  
  Serial.println("=== Data Sensor ===");
  Serial.print("CO2: "); Serial.print(co2); Serial.println(" ppm");
  Serial.print("CO: "); Serial.print(co); Serial.println(" ppm");
  Serial.print("Debu: "); Serial.print(dust); Serial.println(" µg/m³");
  
  // Kirim data ke server
  sendSensorData(co2, co, dust);
}

float readCO2Sensor() {
  // CONTOH: Baca sensor CO2 dari pin analog
  // Sesuaikan dengan sensor CO2 yang Anda gunakan (MH-Z19, CCS811, dll)
  int rawValue = analogRead(CO2_SENSOR_PIN);
  
  // Konversi ke ppm (sesuaikan dengan kalibrasi sensor Anda)
  // Ini hanya contoh, sesuaikan dengan datasheet sensor
  float co2 = map(rawValue, 0, 4095, 400, 2000);
  
  return co2;
}

float readCOSensor() {
  // CONTOH: Baca sensor CO dari pin analog
  // Sesuaikan dengan sensor CO yang Anda gunakan (MQ-7, MQ-9, dll)
  int rawValue = analogRead(CO_SENSOR_PIN);
  
  // Konversi ke ppm (sesuaikan dengan kalibrasi sensor Anda)
  float co = map(rawValue, 0, 4095, 0, 100) / 10.0;
  
  return co;
}

float readDustSensor() {
  // CONTOH: Baca sensor debu dari pin analog
  // Sesuaikan dengan sensor debu yang Anda gunakan (GP2Y1010AU0F, DSM501A, dll)
  int rawValue = analogRead(DUST_SENSOR_PIN);
  
  // Konversi ke µg/m³ (sesuaikan dengan kalibrasi sensor Anda)
  float dust = map(rawValue, 0, 4095, 0, 500);
  
  return dust;
}

void sendSensorData(float co2, float co, float dust) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi tidak terhubung, tidak bisa mengirim data");
    return;
  }
  
  HTTPClient http;
  
  // URL endpoint
  String url = String(serverUrl) + "/api/esp/sensor";
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  // Buat JSON payload
  StaticJsonDocument<200> doc;
  doc["co2"] = co2;
  doc["co"] = co;
  doc["dust"] = dust;
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  // Kirim POST request
  int httpResponseCode = http.POST(jsonString);
  
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.print("Response code: ");
    Serial.println(httpResponseCode);
    Serial.print("Response: ");
    Serial.println(response);
  } else {
    Serial.print("Error sending data: ");
    Serial.println(httpResponseCode);
  }
  
  http.end();
}

void checkFanControl() {
  if (WiFi.status() != WL_CONNECTED) {
    return;
  }
  
  HTTPClient http;
  
  // URL endpoint
  String url = String(serverUrl) + "/api/esp/control";
  
  http.begin(url);
  
  // Kirim GET request
  int httpResponseCode = http.GET();
  
  if (httpResponseCode == 200) {
    String response = http.getString();
    
    // Parse JSON response
    StaticJsonDocument<200> doc;
    DeserializationError error = deserializeJson(doc, response);
    
    if (!error) {
      String fan = doc["fan"];
      String mode = doc["mode"];
      
      // Update status jika berubah
      if (fan != currentFanStatus) {
        currentFanStatus = fan;
        Serial.print("Status Fan berubah: ");
        Serial.println(fan);
        
        // Kontrol relay fan
        if (fan == "ON") {
          digitalWrite(FAN_PIN, HIGH);
          Serial.println("Fan MENYALA");
        } else {
          digitalWrite(FAN_PIN, LOW);
          Serial.println("Fan MATI");
        }
      }
      
      if (mode != currentMode) {
        currentMode = mode;
        Serial.print("Mode berubah: ");
        Serial.println(mode);
      }
    }
  } else {
    Serial.print("Error checking control: ");
    Serial.println(httpResponseCode);
  }
  
  http.end();
}
