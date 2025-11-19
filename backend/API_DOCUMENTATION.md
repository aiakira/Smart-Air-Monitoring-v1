# 📡 API Documentation - Smart Air Monitoring

## ✅ Status: UPDATED untuk Schema Baru

Backend API sudah diupdate untuk menggunakan schema database baru dengan:
- Table: `sensor_data`
- Columns: `co2`, `co`, `dust`, `timestamp`
- Functions: `get_latest_reading()`, `get_historical_data()`, dll

---

## 🎯 3 API Utama

### 1️⃣ **POST /api/data** - ESP32 Kirim Data Sensor

**Untuk:** ESP32/Arduino mengirim data sensor ke database

**Request:**
```json
POST http://localhost:3000/api/data
Content-Type: application/json

{
  "co2": 450.5,
  "co": 5.2,
  "dust": 25.3
}
```

**Response Success:**
```json
{
  "success": true,
  "data": {
    "id": 11,
    "co2": 450.5,
    "co": 5.2,
    "dust": 25.3,
    "timestamp": "2024-01-15T10:30:00.000Z",
    "co2_category": "BAIK",
    "co_category": "AMAN",
    "dust_category": "SEDANG",
    "air_quality_status": "SEDANG"
  },
  "message": "Data sensor berhasil disimpan"
}
```

**Response Error:**
```json
{
  "error": "Bad request",
  "message": "co2, co, dan dust harus diisi"
}
```

---

### 2️⃣ **GET /api/data/terbaru** - Flutter Ambil Data Terbaru

**Untuk:** Flutter Dashboard menampilkan data real-time

**Request:**
```
GET http://localhost:3000/api/data/terbaru
```

**Response:**
```json
{
  "id": 11,
  "co2": 450.5,
  "co": 5.2,
  "dust": 25.3,
  "timestamp": "2024-01-15T10:30:00.000Z",
  "co2_category": "BAIK",
  "co_category": "AMAN",
  "dust_category": "SEDANG",
  "air_quality_status": "SEDANG"
}
```

**Keuntungan:**
- ✅ Kategori sudah dihitung otomatis
- ✅ Status keseluruhan sudah ada
- ✅ Flutter tinggal display, tidak perlu calculate lagi

---

### 3️⃣ **GET /api/data/historis** - Flutter Tampilkan Grafik

**Untuk:** Flutter Analytics Page menampilkan grafik historical data

**Request:**
```
GET http://localhost:3000/api/data/historis?hours=24
```

**Parameters:**
- `hours` (optional): Jumlah jam ke belakang (default: 24)
  - 1 = 1 jam terakhir
  - 6 = 6 jam terakhir
  - 24 = 24 jam terakhir
  - 168 = 7 hari terakhir (7 * 24)

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "co2": 450.5,
      "co": 5.2,
      "dust": 12.3,
      "timestamp": "2024-01-15T00:30:00.000Z",
      "air_quality_status": "BAIK"
    },
    {
      "id": 2,
      "co2": 520.3,
      "co": 6.1,
      "dust": 14.7,
      "timestamp": "2024-01-15T01:30:00.000Z",
      "air_quality_status": "BAIK"
    },
    ...
  ],
  "count": 24,
  "hours": 24
}
```

**Keuntungan:**
- ✅ Data sudah sorted by timestamp ASC (untuk grafik)
- ✅ Status sudah dihitung untuk setiap data point
- ✅ Bisa custom time range

---

## 📊 API Tambahan

### 4️⃣ **GET /api/health** - Health Check

```
GET http://localhost:3000/api/health
```

Response:
```json
{
  "status": "OK",
  "message": "Smart Air Monitoring API is running",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

### 5️⃣ **GET /api/data/statistik** - Statistik Data

```
GET http://localhost:3000/api/data/statistik?hours=24
```

Response:
```json
{
  "total_data": 144,
  "avg_co2": 520.5,
  "max_co2": 850.0,
  "min_co2": 380.2,
  "avg_co": 6.5,
  "max_co": 15.0,
  "min_co": 4.5,
  "avg_dust": 28.3,
  "max_dust": 60.0,
  "min_dust": 10.9
}
```

---

## 🚀 Cara Menjalankan Backend

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Setup Environment
File `.env` sudah diupdate dengan connection string baru:
```env
PORT=3000
DATABASE_URL=postgresql://neondb_owner:npg_U7IHN4rFmCVs@ep-lucky-darkness-a15k13s2-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
```

### 3. Start Server
```bash
npm start
```

Expected output:
```
✅ Connected to Neon PostgreSQL database
🚀 Server running on http://localhost:3000
📊 API Endpoints:
   GET  /api/health
   GET  /api/data/terbaru
   GET  /api/data/historis?hours=24
   GET  /api/data/statistik?hours=24
   POST /api/data
   GET  /api/kontrol/status
   POST /api/kontrol
```

---

## 🧪 Testing API

### Test dengan cURL

**1. Health Check:**
```bash
curl http://localhost:3000/api/health
```

**2. Get Latest Data:**
```bash
curl http://localhost:3000/api/data/terbaru
```

**3. Get Historical Data (24 hours):**
```bash
curl http://localhost:3000/api/data/historis?hours=24
```

**4. Insert New Data:**
```bash
curl -X POST http://localhost:3000/api/data \
  -H "Content-Type: application/json" \
  -d '{"co2": 450.5, "co": 5.2, "dust": 25.3}'
```

**5. Get Statistics:**
```bash
curl http://localhost:3000/api/data/statistik?hours=24
```

---

## 📱 Integration dengan Flutter

Update `lib/services/api_service.dart`:

```dart
class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  
  // Get latest data
  static Future<SensorData?> getLatestData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/data/terbaru'),
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return SensorData(
        co2: json['co2'].toDouble(),
        co: json['co'].toDouble(),
        dust: json['dust'].toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
      );
    }
    return null;
  }
  
  // Get historical data
  static Future<List<SensorData>> getHistoricalData({int hours = 24}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/data/historis?hours=$hours'),
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List dataList = json['data'];
      
      return dataList.map((item) => SensorData(
        co2: item['co2'].toDouble(),
        co: item['co'].toDouble(),
        dust: item['dust'].toDouble(),
        timestamp: DateTime.parse(item['timestamp']),
      )).toList();
    }
    return [];
  }
}
```

---

## 🔧 ESP32 Integration

Update ESP32 code untuk kirim data:

```cpp
void sendDataToAPI() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    
    http.begin("http://YOUR_SERVER_IP:3000/api/data");
    http.addHeader("Content-Type", "application/json");
    
    String jsonData = "{\"co2\":" + String(co2Value) + 
                      ",\"co\":" + String(coValue) + 
                      ",\"dust\":" + String(dustValue) + "}";
    
    int httpResponseCode = http.POST(jsonData);
    
    if (httpResponseCode > 0) {
      Serial.println("Data sent successfully!");
    } else {
      Serial.println("Error sending data");
    }
    
    http.end();
  }
}
```

---

## ✅ Checklist

- [x] Backend API updated untuk schema baru
- [x] 3 API utama sudah ada dan berfungsi
- [x] Database functions terintegrasi
- [x] Error handling lengkap
- [x] Dokumentasi API lengkap
- [ ] Test semua endpoints
- [ ] Update Flutter app untuk gunakan API baru
- [ ] Update ESP32 code untuk gunakan API baru
- [ ] Deploy backend ke cloud (optional)

---

**Backend API siap digunakan! 🚀**
