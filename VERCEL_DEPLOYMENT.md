# 🚀 Panduan Deploy ke Vercel

## Langkah 1: Deploy ke Vercel

### A. Via Vercel Dashboard (Recommended)

1. **Login ke Vercel**
   - Buka https://vercel.com
   - Login dengan akun GitHub Anda

2. **Import Project**
   - Klik **Add New** → **Project**
   - Pilih repository: `aiakira/Smart-Air-Monitoring-v1`
   - Klik **Import**

3. **Configure Project**
   - **Framework Preset**: Next.js (auto-detected)
   - **Root Directory**: `./` (default)
   - **Build Command**: `pnpm build` (auto-detected)
   - **Output Directory**: `.next` (auto-detected)

4. **Environment Variables**
   Tambahkan environment variable berikut:
   
   ```
   Key: DATABASE_URL
   Value: postgresql://neondb_owner:npg_U7IHN4rFmCVs@ep-lucky-darkness-a15k13s2-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
   ```

5. **Deploy**
   - Klik **Deploy**
   - Tunggu proses build selesai (2-3 menit)
   - Setelah selesai, Anda akan mendapat URL deployment

### B. Via Vercel CLI (Alternative)

```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
vercel

# Follow the prompts:
# - Set up and deploy? Yes
# - Which scope? Your account
# - Link to existing project? No
# - Project name? smart-air-monitoring-v1
# - Directory? ./
# - Override settings? No

# Add environment variable
vercel env add DATABASE_URL
# Paste your DATABASE_URL when prompted

# Deploy to production
vercel --prod
```

## Langkah 2: Setup Database

Setelah deployment berhasil, initialize database:

1. **Buka URL Vercel Anda**
   ```
   https://your-project-name.vercel.app
   ```

2. **Setup Database**
   Akses endpoint setup:
   ```
   https://your-project-name.vercel.app/api/setup-db
   ```
   
   Atau gunakan curl:
   ```bash
   curl -X POST https://your-project-name.vercel.app/api/setup-db
   ```

3. **Verifikasi Setup**
   Anda akan melihat response:
   ```json
   {
     "success": true,
     "message": "✅ Database setup berhasil!",
     "features": [
       "✓ Tabel sensor_data dengan support MQ135, MQ5524, GP2Y1010AU0F",
       "✓ Fungsi kategorisasi otomatis untuk CO2, CO, dan Debu",
       "✓ Sistem notifikasi otomatis untuk level berbahaya",
       "✓ Kontrol kipas otomatis berdasarkan threshold",
       "✓ View analytics per jam",
       "✓ Trigger dan function untuk automasi"
     ]
   }
   ```

## Langkah 3: Update ESP32 Code

1. **Buka file `esp32_air_monitor.ino`**

2. **Update konfigurasi WiFi dan Server:**
   ```cpp
   const char* ssid = "NAMA_WIFI_ANDA";
   const char* password = "PASSWORD_WIFI_ANDA";
   const char* serverUrl = "https://your-project-name.vercel.app";  // Ganti dengan URL Vercel Anda
   ```

3. **Upload ke ESP32**
   - Buka Arduino IDE
   - Pilih board: ESP32 Dev Module
   - Pilih port yang sesuai
   - Upload code

4. **Monitor Serial**
   - Buka Serial Monitor (115200 baud)
   - Pastikan ESP32 terhubung ke WiFi
   - Pastikan data terkirim ke server

## Langkah 4: Test Endpoints

### Test Sensor Data Endpoint
```bash
curl -X POST https://your-project-name.vercel.app/api/esp/sensor \
  -H "Content-Type: application/json" \
  -d '{
    "co2": 450,
    "co": 5.2,
    "dust": 35
  }'
```

Expected response:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "co2": "450.00",
    "co": "5.20",
    "dust": "35.00",
    "timestamp": "2024-11-21T10:30:00.000Z"
  }
}
```

### Test Control Endpoint
```bash
curl https://your-project-name.vercel.app/api/esp/control
```

Expected response:
```json
{
  "fan": "OFF",
  "mode": "AUTO"
}
```

### Test Latest Sensor Data
```bash
curl https://your-project-name.vercel.app/api/sensors/latest
```

## Langkah 5: Verifikasi Web Dashboard

1. **Buka Dashboard**
   ```
   https://your-project-name.vercel.app
   ```

2. **Cek Fitur:**
   - ✓ Real-time sensor data display
   - ✓ Grafik historical data
   - ✓ Notifikasi otomatis
   - ✓ Kontrol kipas (Auto/Manual)
   - ✓ Status kualitas udara

## Troubleshooting

### Build Error di Vercel

**Problem:** Build failed
**Solution:**
1. Check build logs di Vercel dashboard
2. Pastikan semua dependencies ada di `package.json`
3. Pastikan tidak ada syntax error

### Database Connection Error

**Problem:** Database connection failed
**Solution:**
1. Pastikan `DATABASE_URL` sudah ditambahkan di Environment Variables
2. Check apakah database Neon masih aktif
3. Test connection: `https://your-url.vercel.app/api/test-db`

### ESP32 Tidak Bisa Kirim Data

**Problem:** ESP32 tidak bisa POST data
**Solution:**
1. Pastikan URL di ESP32 code benar (tanpa trailing slash `/`)
2. Check Serial Monitor untuk error messages
3. Pastikan WiFi credentials benar
4. Test endpoint dengan curl dulu

### CORS Error

**Problem:** CORS policy blocking requests
**Solution:**
Vercel Next.js API routes sudah handle CORS secara default. Jika masih ada masalah, tambahkan di `next.config.mjs`:
```javascript
async headers() {
  return [
    {
      source: '/api/:path*',
      headers: [
        { key: 'Access-Control-Allow-Origin', value: '*' },
        { key: 'Access-Control-Allow-Methods', value: 'GET,POST,PUT,DELETE,OPTIONS' },
      ],
    },
  ]
}
```

## Fitur Database yang Sudah Tersedia

### 1. Auto-Categorization
- CO2: Sangat Baik, Baik, Masih Aman, Tidak Sehat, Bahaya, Sangat Berbahaya
- CO: Aman, Tidak Sehat, Berbahaya, Sangat Berbahaya, Fatal
- Dust: Baik, Sedang, Tidak Sehat, Sangat Tidak Sehat, Berbahaya

### 2. Auto-Notifications
Sistem otomatis membuat notifikasi ketika:
- CO mencapai level berbahaya (>35 ppm)
- CO2 mencapai level bahaya (>2000 ppm)
- Debu mencapai level sangat tidak sehat (>150 µg/m³)

### 3. Auto-Fan Control
Kipas otomatis menyala ketika:
- CO2 > 1000 ppm (threshold default)
- CO > 50 ppm (threshold default)
- Dust > 150 µg/m³ (threshold default)

Kipas otomatis mati ketika semua nilai < 80% threshold

### 4. Analytics
- View per jam untuk 7 hari terakhir
- Average, max, min values
- Reading count per hour

## Next Steps

1. ✅ Deploy ke Vercel
2. ✅ Setup database
3. ✅ Update ESP32 code
4. ✅ Test endpoints
5. ✅ Verifikasi dashboard
6. 🎯 Monitor data real-time
7. 🎯 Customize thresholds sesuai kebutuhan
8. 🎯 Tambahkan sensor tambahan (DHT22, BME280)

## Support

Jika ada masalah:
1. Check Vercel deployment logs
2. Check browser console untuk errors
3. Check ESP32 Serial Monitor
4. Test endpoints dengan curl/Postman

## URL Penting

- **GitHub Repo**: https://github.com/aiakira/Smart-Air-Monitoring-v1
- **Vercel Dashboard**: https://vercel.com/dashboard
- **Neon Database**: https://console.neon.tech

---

**Selamat! Sistem monitoring kualitas udara Anda sudah siap digunakan! 🎉**
