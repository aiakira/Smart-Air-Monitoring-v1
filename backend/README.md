# Smart Air Monitoring Backend API

Backend API untuk aplikasi Smart Air Monitoring menggunakan Node.js, Express, dan Neon PostgreSQL.

## Developer
Andi Ahmad Fadhil Az

## Tech Stack
- **Node.js** - Runtime JavaScript
- **Express** - Web framework
- **PostgreSQL** - Database (Neon DB)
- **pg** - PostgreSQL client untuk Node.js
- **dotenv** - Environment variables
- **cors** - Cross-Origin Resource Sharing

## Setup & Installation

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Setup Database di Neon

#### A. Buka Neon Console
Buka https://console.neon.tech dan login

#### B. Jalankan SQL Script
1. Buka SQL Editor di Neon Console
2. Copy isi file `init-database.sql`
3. Paste dan jalankan di SQL Editor
4. Pastikan tabel `sensor_data` dan `kontrol` sudah dibuat

#### C. Verifikasi
```sql
-- Cek tabel sudah dibuat
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Cek data sample
SELECT * FROM sensor_data ORDER BY waktu DESC LIMIT 5;
SELECT * FROM kontrol ORDER BY waktu DESC LIMIT 5;
```

### 3. Konfigurasi Environment Variables

File `.env` sudah dibuat dengan koneksi ke Neon DB Anda:
```
DATABASE_URL=postgresql://neondb_owner:npg_dLzZ4IvESq7F@ep-wandering-fire-a1fkda74-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
PORT=3000
```

### 4. Jalankan Server

#### Development Mode (dengan auto-reload)
```bash
npm run dev
```

#### Production Mode
```bash
npm start
```

Server akan berjalan di `http://localhost:3000`

## API Endpoints

### 1. Health Check
```
GET /api/health
```
Response:
```json
{
  "status": "OK",
  "message": "Smart Air Monitoring API is running",
  "timestamp": "2024-11-16T10:30:00.000Z"
}
```

### 2. Data Terbaru (Dashboard)
```
GET /api/data/terbaru
```
Response:
```json
{
  "co2": 450,
  "co": 5.2,
  "debu": 25.3,
  "waktu": "2024-11-16T10:30:00.000Z"
}
```

### 3. Data Historis (Grafik)
```
GET /api/data/historis?hours=24
```
Response:
```json
{
  "data": [
    {
      "co2": 450,
      "co": 5.2,
      "debu": 25.3,
      "waktu": "2024-11-16T10:00:00.000Z"
    },
    ...
  ],
  "count": 24,
  "hours": 24
}
```

### 4. Statistik Data
```
GET /api/data/statistik?hours=24
```
Response:
```json
{
  "total_data": 24,
  "avg_co2": 457.5,
  "max_co2": 475,
  "min_co2": 440,
  "avg_co": 5.5,
  "max_co": 6.4,
  "min_co": 4.7,
  "avg_debu": 26.1,
  "max_debu": 28.0,
  "min_debu": 24.4
}
```

### 5. Insert Data Sensor (dari Arduino/ESP32)
```
POST /api/data
Content-Type: application/json

{
  "co2": 450,
  "co": 5.2,
  "debu": 25.3
}
```
Response:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "co2": 450,
    "co": 5.2,
    "debu": 25.3,
    "waktu": "2024-11-16T10:30:00.000Z"
  },
  "message": "Data sensor berhasil disimpan"
}
```

### 6. Status Kontrol
```
GET /api/kontrol/status
```
Response:
```json
{
  "fan": "OFF",
  "mode": "AUTO",
  "waktu": "2024-11-16T10:30:00.000Z"
}
```

### 7. Kirim Perintah Kontrol
```
POST /api/kontrol
Content-Type: application/json

{
  "fan": "ON",
  "mode": "MANUAL"
}
```
Response:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "fan": "ON",
    "mode": "MANUAL",
    "waktu": "2024-11-16T10:30:00.000Z"
  },
  "message": "Perintah kontrol berhasil dikirim"
}
```

## Testing API

### Menggunakan Browser
```
http://localhost:3000/api/health
http://localhost:3000/api/data/terbaru
http://localhost:3000/api/data/historis?hours=24
```

### Menggunakan curl
```bash
# Health check
curl http://localhost:3000/api/health

# Data terbaru
curl http://localhost:3000/api/data/terbaru

# Data historis
curl http://localhost:3000/api/data/historis?hours=24

# Statistik
curl http://localhost:3000/api/data/statistik?hours=24

# Insert data sensor
curl -X POST http://localhost:3000/api/data \
  -H "Content-Type: application/json" \
  -d '{"co2":450,"co":5.2,"debu":25.3}'

# Status kontrol
curl http://localhost:3000/api/kontrol/status

# Kirim perintah kontrol
curl -X POST http://localhost:3000/api/kontrol \
  -H "Content-Type: application/json" \
  -d '{"fan":"ON","mode":"MANUAL"}'
```

### Menggunakan Postman
1. Import collection dari file `postman_collection.json` (jika ada)
2. Atau buat request manual sesuai endpoint di atas

## Deploy ke Production

### Deploy ke Vercel
```bash
npm install -g vercel
vercel
```

### Deploy ke Railway
1. Push code ke GitHub
2. Connect repository di Railway
3. Set environment variables
4. Deploy

### Deploy ke Heroku
```bash
heroku create smart-air-monitoring-api
git push heroku main
```

## Menghubungkan dengan Flutter App

### 1. Update baseUrl di Flutter
Edit file `lib/services/api_service.dart`:

**Untuk Lokal:**
```dart
static const String baseUrl = 'http://localhost:3000';
```

**Untuk Production (setelah deploy):**
```dart
static const String baseUrl = 'https://your-api-domain.com';
```

### 2. Test Koneksi
Jalankan Flutter app dan lihat apakah:
- Ikon WiFi di AppBar berwarna putih (terhubung)
- Tidak ada banner orange "Mode Simulasi"
- Data sensor muncul dari database

## Troubleshooting

### Error: Cannot connect to database
- Cek koneksi internet
- Cek DATABASE_URL di `.env` sudah benar
- Cek Neon DB masih aktif (tidak suspended)

### Error: EADDRINUSE (Port sudah digunakan)
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:3000 | xargs kill
```

### Error: CORS
- Pastikan `cors()` middleware sudah diaktifkan
- Cek ALLOWED_ORIGINS di `.env`

### Data tidak muncul di Flutter
- Cek server backend sudah running
- Cek baseUrl di Flutter sudah benar
- Cek format response API sesuai dengan yang diharapkan
- Lihat log error di console

## Database Maintenance

### Backup Database
```bash
# Menggunakan Neon Console
# Export data dari SQL Editor
```

### Hapus Data Lama
```sql
DELETE FROM sensor_data WHERE waktu < NOW() - INTERVAL '30 days';
```

### Reset Database
```sql
TRUNCATE TABLE sensor_data RESTART IDENTITY CASCADE;
TRUNCATE TABLE kontrol RESTART IDENTITY CASCADE;
```

## License
MIT

## Contact
Developer: Andi Ahmad Fadhil Az
