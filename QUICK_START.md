# ⚡ Quick Start Guide

## 🚀 Deploy dalam 5 Menit

### 1. Deploy ke Vercel
```bash
# Via Vercel Dashboard (Termudah)
1. Buka https://vercel.com
2. Login dengan GitHub
3. Import repository: aiakira/Smart-Air-Monitoring-v1
4. Tambahkan Environment Variable:
   DATABASE_URL = postgresql://neondb_owner:npg_U7IHN4rFmCVs@ep-lucky-darkness-a15k13s2-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
5. Klik Deploy
```

### 2. Setup Database
Setelah deploy selesai, akses:
```
https://your-project-name.vercel.app/api/setup-db
```

### 3. Update ESP32
Edit `esp32_air_monitor.ino`:
```cpp
const char* ssid = "WIFI_ANDA";
const char* password = "PASSWORD_ANDA";
const char* serverUrl = "https://your-project-name.vercel.app";
```

Upload ke ESP32 dan selesai! ✅

## 📊 Fitur Utama

- ✅ Real-time monitoring CO2, CO, Debu
- ✅ Auto-notification untuk level berbahaya
- ✅ Auto-control kipas berdasarkan threshold
- ✅ Grafik historical data
- ✅ Dashboard profesional

## 🔗 Endpoints

- `POST /api/esp/sensor` - ESP32 kirim data
- `GET /api/esp/control` - ESP32 cek status kipas
- `GET /api/sensors/latest` - Data sensor terbaru
- `GET /api/sensors/historical` - Data historis

## 📱 Sensor yang Didukung

- **MQ135** - CO2 (0-10000 ppm)
- **MQ5524** - CO (0-1000 ppm)
- **GP2Y1010AU0F** - Debu (0-1000 µg/m³)
- **DHT22/BME280** - Suhu & Kelembaban (opsional)

## 🎯 Threshold Default

- CO2: 1000 ppm (Auto ON fan)
- CO: 50 ppm (Auto ON fan)
- Debu: 150 µg/m³ (Auto ON fan)

Bisa diubah di dashboard!

---

**Butuh bantuan?** Lihat [VERCEL_DEPLOYMENT.md](./VERCEL_DEPLOYMENT.md) untuk panduan lengkap.
