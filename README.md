# 🌬️ Smart Air Monitoring System

Aplikasi monitoring kualitas udara real-time dengan Flutter, Node.js, dan PostgreSQL (Neon).

## 📱 Features

- ✅ Real-time monitoring CO₂, CO, dan Debu (PM2.5)
- ✅ Dashboard dengan grafik tren 24 jam
- ✅ Analytics page dengan historical data
- ✅ 7 level kategori kualitas udara (BAIK, MASIH AMAN, SEDANG, TIDAK SEHAT, BAHAYA, SANGAT BURUK, FATAL)
- ✅ Rekomendasi otomatis berdasarkan kualitas udara
- ✅ Notifikasi system
- ✅ Control exhaust fan (manual/auto)
- ✅ Integration dengan ESP32/Arduino

## 🏗️ Architecture

```
┌─────────────┐
│   ESP32     │ ──POST──> Backend API ──> Neon PostgreSQL
│   Sensors   │           (Node.js)       (Database)
└─────────────┘                                │
                                               │
┌─────────────┐                                │
│   Flutter   │ <──GET────────────────────────┘
│     App     │
└─────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.10+)
- Node.js (18+)
- PostgreSQL (Neon account)
- ESP32/Arduino (optional)

### 1. Setup Database

1. Buat akun di [Neon.tech](https://neon.tech)
2. Buat database baru
3. Jalankan schema SQL:
   ```bash
   # Di Neon Console SQL Editor, jalankan:
   database/neon_schema_fixed.sql
   database/add_missing_parts.sql
   database/add_views.sql
   database/add_sample_data.sql
   ```

### 2. Setup Backend API

```bash
cd backend
npm install
cp .env.example .env
# Edit .env dengan DATABASE_URL dari Neon
npm start
```

Backend akan running di `http://localhost:3000`

### 3. Setup Flutter App

```bash
flutter pub get
flutter run
```

### 4. Setup ESP32 (Optional)

1. Buka `iot/esp32_sensor.ino` di Arduino IDE
2. Update WiFi credentials dan API URL
3. Upload ke ESP32

## 📊 Database Schema

### Table: sensor_data
```sql
- id: SERIAL PRIMARY KEY
- co2: DOUBLE PRECISION (ppm)
- co: DOUBLE PRECISION (ppm)
- dust: DOUBLE PRECISION (µg/m³)
- timestamp: TIMESTAMP
```

### Functions (7 functions)
- `get_co2_category(co2)` - Kategori CO₂
- `get_co_category(co)` - Kategori CO
- `get_dust_category(dust)` - Kategori Debu
- `get_air_quality_status(co2, co, dust)` - Status keseluruhan
- `get_latest_reading()` - Data terbaru
- `get_historical_data(hours)` - Data historis
- `cleanup_old_data(days)` - Hapus data lama

### Views (2 views)
- `daily_statistics` - Statistik harian
- `latest_readings` - 100 data terbaru

## 📡 API Endpoints

### POST /api/data
Insert data sensor baru (untuk ESP32)

**Request:**
```json
{
  "co2": 450.5,
  "co": 5.2,
  "dust": 25.3
}
```

### GET /api/data/terbaru
Ambil data sensor terbaru

**Response:**
```json
{
  "id": 1,
  "co2": 450.5,
  "co": 5.2,
  "dust": 25.3,
  "timestamp": "2024-01-15T10:30:00Z",
  "co2_category": "BAIK",
  "co_category": "AMAN",
  "dust_category": "SEDANG",
  "air_quality_status": "SEDANG"
}
```

### GET /api/data/historis?hours=24
Ambil data historis untuk grafik

**Response:**
```json
{
  "data": [...],
  "count": 24,
  "hours": 24
}
```

Dokumentasi lengkap: [backend/API_DOCUMENTATION.md](backend/API_DOCUMENTATION.md)

## 🎯 Kategori Kualitas Udara

### CO₂ (5 kategori)
- ✅ BAIK: ≤ 800 ppm
- 🟢 MASIH AMAN: 801-1000 ppm
- 🟡 TIDAK SEHAT: 1001-2000 ppm
- 🟠 BAHAYA: 2001-5000 ppm
- 🔴 SANGAT BERBAHAYA: > 5000 ppm

### CO (5 kategori)
- ✅ AMAN: ≤ 9 ppm
- 🟡 TIDAK SEHAT: 10-35 ppm
- 🟠 BERBAHAYA: 36-200 ppm
- 🔴 SANGAT BERBAHAYA: 201-800 ppm
- ⚫ FATAL: > 800 ppm

### Debu/PM2.5 (4 kategori)
- ✅ BAIK: ≤ 15 µg/m³
- 🟢 SEDANG: 16-35 µg/m³
- 🟡 TIDAK SEHAT: 36-55 µg/m³
- 🔴 SANGAT TIDAK SEHAT: > 55 µg/m³

## 📁 Project Structure

```
flutter_app/
├── lib/                    # Flutter app source
│   ├── main.dart
│   ├── models/            # Data models
│   ├── pages/             # UI pages
│   ├── services/          # API services
│   ├── widgets/           # Reusable widgets
│   └── theme/             # App theme
├── backend/               # Node.js API
│   ├── server.js          # Main server file
│   ├── .env.example       # Environment template
│   └── API_DOCUMENTATION.md
├── database/              # Database scripts
│   ├── neon_schema_fixed.sql
│   ├── add_missing_parts.sql
│   ├── add_views.sql
│   └── README.md
├── iot/                   # ESP32/Arduino code
│   └── esp32_sensor.ino
└── .kiro/                 # Kiro specs
    └── specs/
        └── modern-chart-improvements/
```

## 🔧 Development

### Run Backend in Dev Mode
```bash
cd backend
npm run dev  # with nodemon
```

### Run Flutter in Debug Mode
```bash
flutter run -d chrome  # Web
flutter run -d windows # Windows
```

### Database Management
```bash
# Test connection
node database/test_connection.js

# Check schema
node database/check_existing_schema.js
```

## 🚀 Deployment

### Backend (Vercel/Railway/Heroku)
1. Push code ke GitHub
2. Connect repository ke platform
3. Set environment variable `DATABASE_URL`
4. Deploy!

### Flutter (Web)
```bash
flutter build web
# Deploy ke Firebase Hosting, Vercel, atau Netlify
```

### Flutter (Mobile)
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 📚 Documentation

- [Quick Start Guide](QUICK_START.md)
- [Database Setup](database/NEW_DATABASE_SETUP.md)
- [Database Schema](database/SCHEMA_EXPLANATION.md)
- [API Documentation](backend/API_DOCUMENTATION.md)
- [Modern Chart Spec](.kiro/specs/modern-chart-improvements/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

Created with ❤️ by [Your Name]

## 🙏 Acknowledgments

- Flutter team for amazing framework
- Neon for serverless PostgreSQL
- fl_chart for beautiful charts
- ESP32 community

---

**⭐ Star this repo if you find it helpful!**
