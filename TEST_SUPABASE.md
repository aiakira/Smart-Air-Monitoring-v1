# ✅ Supabase Sudah Dikonfigurasi!

## 🎉 Konfigurasi Berhasil!

API Keys sudah diset:
- **URL**: `https://xllyhkosxnudfejkmyxa.supabase.co`
- **Key**: Configured ✅

## 🚀 Cara Test Koneksi

### Option 1: Jalankan App
```bash
flutter run
```

Lalu buka halaman **Supabase Test** di app.

### Option 2: Test Manual di Code

Tambahkan di `main.dart` atau page manapun:

```dart
import 'package:smart_air_monitoring_room/services/supabase_service.dart';
import 'package:smart_air_monitoring_room/models/sensor_data.dart';

// Test fetch data
Future<void> testSupabase() async {
  final supabase = SupabaseService();
  
  print('Testing Supabase connection...');
  
  // Test 1: Fetch latest data
  final latestData = await supabase.getLatestSensorData();
  if (latestData != null) {
    print('✅ Latest data:');
    print('   CO: ${latestData.co} ppm');
    print('   CO2: ${latestData.co2} ppm');
    print('   PM2.5: ${latestData.pm25} µg/m³');
  } else {
    print('⚠️ No data found');
  }
  
  // Test 2: Insert test data
  final testData = SensorData(
    co: 5.5,
    co2: 450.0,
    pm25: 12.5,
    timestamp: DateTime.now(),
  );
  
  final success = await supabase.insertSensorData(testData);
  print(success ? '✅ Insert successful' : '❌ Insert failed');
}
```

## 📊 Cara Menggunakan di Existing Pages

### Dashboard Page

```dart
import '../services/supabase_service.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final SupabaseService _supabase = SupabaseService();
  SensorData? _latestData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await _supabase.getLatestSensorData();
    setState(() {
      _latestData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_latestData == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Text('CO: ${_latestData!.co} ppm'),
        Text('CO2: ${_latestData!.co2} ppm'),
        Text('PM2.5: ${_latestData!.pm25} µg/m³'),
        Text('Status: ${_latestData!.getAirQualityStatus()}'),
      ],
    );
  }
}
```

## 🔄 Real-time Updates

```dart
void _startRealTimeUpdates() {
  _supabase.streamSensorData().listen((data) {
    if (data != null && mounted) {
      setState(() {
        _latestData = data;
      });
    }
  });
}
```

## 📚 Dokumentasi Lengkap

- **QUICK_START_SUPABASE.md** - Quick start guide
- **SUPABASE_SETUP.md** - Setup lengkap
- **INTEGRATION_EXAMPLE.md** - Contoh integrasi ke pages

## ✅ Next Steps

1. Run app: `flutter run`
2. Test koneksi di Supabase Test page
3. Integrate ke existing pages
4. Setup real-time updates (optional)

Selamat! Supabase sudah siap digunakan! 🎉
