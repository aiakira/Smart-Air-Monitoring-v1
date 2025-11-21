# 🌬️ Smart Air Monitor

Sistem monitoring kualitas udara real-time dengan dashboard web dan integrasi ESP32.

![Next.js](https://img.shields.io/badge/Next.js-16.0-black)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Neon-green)
![License](https://img.shields.io/badge/license-MIT-blue)

## ✨ Fitur

- 📊 **Real-time Monitoring** - Data sensor diupdate setiap 5 detik
- 📈 **Grafik Historis** - Visualisasi data dalam 24 jam terakhir
- 🎛️ **Kontrol Fan** - Mode AUTO/MANUAL dengan kontrol ON/OFF
- 🔔 **Sistem Notifikasi** - Peringatan kualitas udara
- 📱 **Responsive Design** - Optimal di desktop dan mobile
- 🌙 **Dark Mode** - Tema gelap dan terang
- 🔌 **ESP32 Integration** - API untuk sensor IoT

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ 
- npm atau pnpm
- PostgreSQL database (Neon DB recommended)

### Installation

1. **Clone repository**
```bash
git clone https://github.com/yourusername/smart-air-monitor.git
cd smart-air-monitor
```

2. **Install dependencies**
```bash
npm install
```

3. **Setup environment variables**
```bash
cp .env.example .env.local
```

Edit `.env.local` dan tambahkan DATABASE_URL Anda:
```env
DATABASE_URL=postgresql://your_connection_string
```

4. **Initialize database**
```bash
npm run db:init
```

5. **Run development server**
```bash
npm run dev
```

Buka [http://localhost:3000](http://localhost:3000) di browser.

## 📁 Struktur Project

```
smart-air-monitor/
├── app/                      # Next.js App Router
│   ├── api/                  # API Routes
│   │   ├── sensors/          # Sensor data endpoints
│   │   ├── control/          # Fan control endpoints
│   │   ├── notifications/    # Notification endpoints
│   │   └── esp/              # ESP32 integration
│   ├── grafik/               # Charts page
│   ├── notifikasi/           # Notifications page
│   └── page.tsx              # Dashboard (home)
├── components/               # React components
│   ├── ui/                   # UI components (shadcn)
│   ├── header.tsx
│   ├── sidebar.tsx
│   └── ...
├── hooks/                    # Custom React hooks
├── lib/                      # Utilities
│   ├── db.ts                 # Database connection
│   └── types.ts              # TypeScript types
├── scripts/                  # Utility scripts
└── public/                   # Static files
```

## 🗄️ Database Schema

### Tables

**sensor_data**
- `id` - BIGINT (Primary Key)
- `co2` - NUMERIC (CO₂ dalam ppm)
- `co` - NUMERIC (CO dalam ppm)
- `dust` - NUMERIC (Debu dalam µg/m³)
- `timestamp` - TIMESTAMP WITH TIME ZONE

**kontrol**
- `id` - BIGINT (Primary Key)
- `fan` - VARCHAR (ON/OFF)
- `mode` - VARCHAR (AUTO/MANUAL)
- `waktu` - TIMESTAMP WITH TIME ZONE

**notifications**
- `id` - BIGINT (Primary Key)
- `title` - VARCHAR
- `message` - TEXT
- `type` - VARCHAR (info/warning/danger/success)
- `is_read` - BOOLEAN
- `created_at` - TIMESTAMP WITH TIME ZONE

## 🔌 API Endpoints

### Sensor Data
- `GET /api/sensors/latest` - Data sensor terbaru
- `GET /api/sensors/historical?hours=24` - Data historis

### Control
- `GET /api/control` - Status kontrol fan
- `POST /api/control` - Update kontrol fan

### Notifications
- `GET /api/notifications` - Semua notifikasi
- `PATCH /api/notifications` - Tandai sebagai dibaca

### ESP32 Integration
- `POST /api/esp/sensor` - Kirim data sensor
- `GET /api/esp/control` - Ambil status kontrol

### Utility
- `GET /api/test-db` - Test koneksi database
- `POST /api/init-db` - Initialize database functions
- `POST /api/cleanup` - Cleanup old data

## 🛠️ Development

### Available Scripts

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run ESLint
npm run db:init      # Initialize database
npm run db:cleanup   # Cleanup old data
```

### Environment Variables

```env
DATABASE_URL=postgresql://...    # Required: Database connection
NEXT_PUBLIC_API_URL=...         # Optional: API URL
ESP32_API_KEY=...               # Optional: ESP32 auth key
```

## 📊 Performance Optimization

1. **Database Indexes** - Jalankan `DATABASE_INDEXES.sql`
2. **Caching** - SWR untuk client-side caching
3. **Cleanup** - Jalankan `npm run db:cleanup` setiap minggu
4. **Monitoring** - Setup Vercel Analytics

Lihat [OPTIMIZATION_GUIDE.md](OPTIMIZATION_GUIDE.md) untuk detail lengkap.

## 🚀 Deployment

### Deploy ke Vercel

1. **Push ke GitHub**
```bash
git add .
git commit -m "Initial commit"
git push origin main
```

2. **Import di Vercel**
   - Buka [vercel.com](https://vercel.com)
   - Import repository GitHub
   - Tambahkan environment variable `DATABASE_URL`
   - Deploy!

3. **Setup Database Indexes**
   - Buka Neon DB Console
   - Jalankan query dari `DATABASE_INDEXES.sql`

### Environment Variables di Vercel

Tambahkan di Vercel Dashboard → Settings → Environment Variables:
```
DATABASE_URL=your_production_database_url
```

## 🔧 ESP32 Integration

### Arduino Code

Lihat `esp32_air_monitor.ino` untuk kode lengkap.

### Kirim Data Sensor

```cpp
POST /api/esp/sensor
Content-Type: application/json

{
  "co2": 450,
  "co": 5.5,
  "dust": 28
}
```

### Ambil Status Kontrol

```cpp
GET /api/esp/control

Response:
{
  "fan": "ON",
  "mode": "AUTO"
}
```

## 📱 Screenshots

### Dashboard
![Dashboard](docs/screenshots/dashboard.png)

### Grafik
![Grafik](docs/screenshots/grafik.png)

### Notifikasi
![Notifikasi](docs/screenshots/notifikasi.png)

## 🧪 Testing

Lihat [TESTING_RESULTS.md](TESTING_RESULTS.md) untuk hasil testing lengkap.

### Manual Testing

```bash
# Test database connection
curl http://localhost:3000/api/test-db

# Test sensor data
curl http://localhost:3000/api/sensors/latest

# Test control
curl http://localhost:3000/api/control
```

## 📚 Documentation

- [QUICK_START.md](QUICK_START.md) - Panduan cepat
- [SETUP.md](SETUP.md) - Setup lengkap
- [OPTIMIZATION_GUIDE.md](OPTIMIZATION_GUIDE.md) - Panduan optimasi
- [TESTING_RESULTS.md](TESTING_RESULTS.md) - Hasil testing
- [DATABASE_INDEXES.sql](DATABASE_INDEXES.sql) - Query optimasi

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 Acknowledgments

- [Next.js](https://nextjs.org/) - React framework
- [shadcn/ui](https://ui.shadcn.com/) - UI components
- [Neon](https://neon.tech/) - Serverless PostgreSQL
- [Vercel](https://vercel.com/) - Deployment platform
- [Recharts](https://recharts.org/) - Chart library

## 📞 Support

Jika ada pertanyaan atau masalah:
1. Cek [OPTIMIZATION_GUIDE.md](OPTIMIZATION_GUIDE.md)
2. Buka [Issues](https://github.com/yourusername/smart-air-monitor/issues)
3. Email: your.email@example.com

---

**Status:** ✅ Production Ready  
**Version:** 1.0.0  
**Last Updated:** November 2025

Made with ❤️ for better air quality monitoring
