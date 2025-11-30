# 🌬️ Smart Air Monitoring v2

Smart Air Monitoring System - Aplikasi Flutter untuk monitoring kualitas udara real-time dengan integrasi Supabase.

## 📱 Features

- ✅ Real-time air quality monitoring (CO, CO2, PM2.5)
- ✅ Dashboard dengan visualisasi data
- ✅ Analytics & Charts
- ✅ Health monitoring
- ✅ Notifications & Alerts
- ✅ Medical profile management
- ✅ Supabase integration untuk database cloud

## 🗄️ Database

Aplikasi ini menggunakan **Supabase** sebagai backend database.

### Database Structure

```sql
Table: sensor_data
- id (bigint, primary key)
- co (double precision) - Kadar CO dalam ppm
- co2 (double precision) - Kadar CO₂ dalam ppm
- pm25 (double precision) - Kadar PM2.5 dalam µg/m³
- timestamp (timestamp) - Waktu pengukuran
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.38.0 atau lebih baru)
- Dart SDK
- Android Studio / VS Code
- Supabase account

### Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/aiakira/Smart-Air-Monitoring-v1.git
   cd Smart-Air-Monitoring-v1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Supabase**
   - Buat project di [Supabase](https://supabase.com)
   - Copy Project URL dan Anon Key
   - Edit `lib/config/supabase_config.dart`:
     ```dart
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
     ```

4. **Run app**
   ```bash
   flutter run
   ```

## 📊 Supabase Integration

### Setup Database

Jalankan SQL berikut di Supabase SQL Editor:

```sql
CREATE TABLE sensor_data (
  id BIGSERIAL PRIMARY KEY,
  co DOUBLE PRECISION,
  co2 DOUBLE PRECISION,
  pm25 DOUBLE PRECISION,
  timestamp TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sensor_data_timestamp ON sensor_data(timestamp DESC);

ALTER TABLE sensor_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for all users" ON sensor_data
  FOR SELECT USING (true);

CREATE POLICY "Enable insert access for all users" ON sensor_data
  FOR INSERT WITH CHECK (true);
```

### Usage Example

```dart
import 'package:smart_air_monitoring_room/services/supabase_service.dart';

// Fetch latest data
final supabase = SupabaseService();
final data = await supabase.getLatestSensorData();

// Insert data
final newData = SensorData(
  co: 5.0,
  co2: 450.0,
  pm25: 12.5,
  timestamp: DateTime.now(),
);
await supabase.insertSensorData(newData);

// Real-time updates
supabase.streamSensorData().listen((data) {
  print('New data: ${data?.co2} ppm');
});
```

## 📚 Documentation

- [TEST_SUPABASE.md](TEST_SUPABASE.md) - Quick test guide
- [INTEGRATION_EXAMPLE.md](INTEGRATION_EXAMPLE.md) - Integration examples

## 🏗️ Project Structure

```
lib/
├── config/
│   ├── api_config.dart
│   └── supabase_config.dart
├── models/
│   ├── sensor_data.dart
│   ├── health_data.dart
│   └── medical_profile.dart
├── services/
│   ├── supabase_service.dart
│   ├── api_service.dart
│   └── emergency_service.dart
├── providers/
│   ├── sensor_provider.dart
│   ├── health_provider.dart
│   └── supabase_sensor_provider.dart
├── pages/
│   ├── dashboard_page.dart
│   ├── analytics_page.dart
│   ├── health_page.dart
│   ├── supabase_test_page.dart
│   └── settings_page.dart
└── widgets/
    ├── sensor_detail_card.dart
    ├── status_card.dart
    └── health_widgets.dart
```

## 🔧 Configuration

### API Configuration

Edit `lib/config/api_config.dart` untuk konfigurasi API endpoint.

### Supabase Configuration

Edit `lib/config/supabase_config.dart` untuk konfigurasi Supabase credentials.

**⚠️ PENTING**: Jangan commit file `supabase_config.dart` dengan credentials asli ke Git!

## 🧪 Testing

### Test Supabase Connection

1. Run app
2. Buka halaman "Supabase Test"
3. Klik "Fetch Latest Data"
4. Klik "Insert Test Data"

### Run Tests

```bash
flutter test
```

## 📱 Build APK

```bash
flutter build apk --release
```

APK akan tersedia di: `build/app/outputs/flutter-apk/app-release.apk`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**aiakira**
- GitHub: [@aiakira](https://github.com/aiakira)

## 🙏 Acknowledgments

- Flutter Team
- Supabase Team
- All contributors

---

**Made with ❤️ using Flutter & Supabase**
