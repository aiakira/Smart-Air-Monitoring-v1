# 🔌 Contoh Integrasi Supabase ke Existing Pages

## 📄 Cara Menggunakan di Dashboard Page

### Option 1: Ganti API Service dengan Supabase Service

Edit `lib/pages/dashboard_page.dart`:

```dart
import '../services/supabase_service.dart'; // Tambahkan import

class _DashboardPageState extends State<DashboardPage> {
  final SupabaseService _supabase = SupabaseService(); // Ganti dengan Supabase
  SensorData? _latestData;
  
  @override
  void initState() {
    super.initState();
    _fetchData();
    _startRealTimeUpdates(); // Optional: real-time
  }
  
  Future<void> _fetchData() async {
    final data = await _supabase.getLatestSensorData();
    setState(() {
      _latestData = data;
    });
  }
  
  void _startRealTimeUpdates() {
    _supabase.streamSensorData().listen((data) {
      if (data != null && mounted) {
        setState(() {
          _latestData = data;
        });
      }
    });
  }
  
  // ... rest of your code
}
```

---

## 📊 Cara Menggunakan di Analytics Page

Edit `lib/pages/analytics_page.dart`:

```dart
import '../services/supabase_service.dart';

class _AnalyticsPageState extends State<AnalyticsPage> {
  final SupabaseService _supabase = SupabaseService();
  List<SensorData> _chartData = [];
  
  Future<void> _loadChartData() async {
    // Get data for last 24 hours
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(hours: 24));
    
    final data = await _supabase.getDataForChart(
      startDate: startDate,
      endDate: endDate,
      limit: 100, // Limit untuk performa
    );
    
    setState(() {
      _chartData = data;
    });
  }
  
  // Convert to chart data
  List<FlSpot> _getCO2ChartData() {
    return _chartData.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.co2,
      );
    }).toList();
  }
  
  // ... rest of your code
}
```

---

## 🔄 Menggunakan Provider (Recommended)

### 1. Update Provider

Edit `lib/providers/sensor_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../services/supabase_service.dart';

class SensorProvider with ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  
  SensorData? _latestData;
  List<SensorData> _history = [];
  bool _isLoading = false;
  String? _error;

  SensorData? get latestData => _latestData;
  List<SensorData> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch latest data
  Future<void> fetchLatestData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _latestData = await _supabase.getLatestSensorData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch history
  Future<void> fetchHistory({int limit = 100}) async {
    try {
      _history = await _supabase.getSensorDataHistory(limit: limit);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Start real-time updates
  void startRealTimeUpdates() {
    _supabase.streamSensorData().listen(
      (data) {
        if (data != null) {
          _latestData = data;
          notifyListeners();
        }
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }
}
```

### 2. Gunakan Provider di Widget

```dart
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Fetch data saat page load
    Future.microtask(() {
      final provider = Provider.of<SensorProvider>(context, listen: false);
      provider.fetchLatestData();
      provider.startRealTimeUpdates(); // Optional: real-time
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        final data = provider.latestData;
        if (data == null) {
          return Center(child: Text('No data available'));
        }

        return Column(
          children: [
            Text('CO: ${data.co} ppm'),
            Text('CO2: ${data.co2} ppm'),
            Text('PM2.5: ${data.pm25} µg/m³'),
            Text('Status: ${data.getAirQualityStatus()}'),
          ],
        );
      },
    );
  }
}
```

---

## 📈 Contoh untuk Chart (fl_chart)

```dart
import 'package:fl_chart/fl_chart.dart';

class CO2Chart extends StatelessWidget {
  final List<SensorData> data;

  const CO2Chart({required this.data});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.co2,
              );
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final time = data[value.toInt()].timestamp;
                  return Text('${time.hour}:${time.minute}');
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}');
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Penggunaan:
class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final SupabaseService _supabase = SupabaseService();
  List<SensorData> _chartData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _supabase.getDataForChart(
      startDate: DateTime.now().subtract(Duration(hours: 24)),
      endDate: DateTime.now(),
      limit: 50,
    );
    setState(() {
      _chartData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics')),
      body: _chartData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : CO2Chart(data: _chartData),
    );
  }
}
```

---

## 🔄 Auto Refresh Data

```dart
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final SupabaseService _supabase = SupabaseService();
  SensorData? _latestData;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Auto refresh every 30 seconds
    _timer = Timer.periodic(Duration(seconds: 30), (_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final data = await _supabase.getLatestSensorData();
    if (mounted) {
      setState(() {
        _latestData = data;
      });
    }
  }

  // ... rest of code
}
```

---

## 🎯 Best Practices

1. **Gunakan Provider** untuk state management
2. **Real-time updates** untuk data yang sering berubah
3. **Auto refresh** dengan Timer untuk fallback
4. **Error handling** yang baik
5. **Loading states** untuk UX yang lebih baik
6. **Limit data** untuk performa (jangan fetch semua data sekaligus)
7. **Cache data** di local untuk offline support (optional)

---

## 📝 Checklist Integrasi

- [ ] Import SupabaseService
- [ ] Ganti API calls dengan Supabase calls
- [ ] Update model jika perlu (co, co2, pm25)
- [ ] Test fetch data
- [ ] Test insert data (jika ada)
- [ ] Setup real-time updates (optional)
- [ ] Add error handling
- [ ] Add loading states
- [ ] Test dengan data real

---

## 🆘 Troubleshooting

**Data tidak muncul**
→ Cek console untuk error, pastikan API keys benar

**Real-time tidak update**
→ Cek RLS policies di Supabase, pastikan allow SELECT

**App crash saat fetch**
→ Add try-catch dan null checks

**Chart tidak muncul**
→ Pastikan data tidak kosong, add loading state
