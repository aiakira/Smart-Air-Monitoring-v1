import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';
import 'notifications_page.dart';

// Contoh: Dashboard dengan integrasi API
// Ganti dashboard_page.dart dengan versi ini setelah Backend API siap

class DashboardPageWithApi extends StatefulWidget {
  const DashboardPageWithApi({super.key});

  @override
  State<DashboardPageWithApi> createState() => _DashboardPageWithApiState();
}

class _DashboardPageWithApiState extends State<DashboardPageWithApi> {
  SensorData? _currentData;
  bool _isLoading = true;
  bool _isError = false;
  String? _errorMessage;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUnreadNotificationsCount();
    _startPeriodicUpdate();
  }

  // Fungsi untuk menghitung jumlah notifikasi belum dibaca
  // (Dalam aplikasi nyata, ini bisa dari API atau database)
  void _loadUnreadNotificationsCount() {
    // Simulasi: hitung dari data notifikasi
    // Di aplikasi nyata, ini bisa dari API: ApiService.getUnreadNotificationsCount()
    setState(() {
      // Contoh: 2 notifikasi belum dibaca
      // Bisa diganti dengan data dari API
      _unreadNotifications = 2;
    });
  }

  // Load data dari API
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final data = await ApiService.getLatestData();
      
      if (data != null) {
        setState(() {
          _currentData = data;
          _isLoading = false;
        });
      } else {
        // Fallback ke data simulasi jika API tidak tersedia
        setState(() {
          _currentData = SensorData(
            co2: 450,
            co: 5,
            dust: 25,
            timestamp: DateTime.now(),
          );
          _isLoading = false;
          _isError = true;
          _errorMessage = 'API tidak tersedia, menggunakan data simulasi';
        });
      }
    } catch (e) {
      // Fallback ke data simulasi jika error
      setState(() {
        _currentData = SensorData(
          co2: 450,
          co: 5,
          dust: 25,
          timestamp: DateTime.now(),
        );
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Error: $e';
      });
    }
  }

  // Update data secara berkala (setiap 5 detik)
  void _startPeriodicUpdate() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _loadData();
        _startPeriodicUpdate(); // Update lagi
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading indicator jika masih loading
    if (_isLoading && _currentData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Gunakan data default jika null
    final data = _currentData ?? SensorData(
      co2: 0,
      co: 0,
      dust: 0,
      timestamp: DateTime.now(),
    );

    String status = data.getAirQualityStatus();
    int statusColor = data.getStatusColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  ).then((_) {
                    // Refresh jumlah notifikasi setelah kembali dari halaman notifikasi
                    _loadUnreadNotificationsCount();
                  });
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error message (jika ada)
              if (_isError)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage ?? 'Error',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Bagian 1: Status Udara
              _buildStatusCard(status, statusColor),
              const SizedBox(height: 20),

              // Bagian 2: Data Sensor
              const Text(
                'Data Sensor',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSensorCard(
                'CO₂',
                data.co2.toStringAsFixed(0),
                'ppm',
                Icons.cloud,
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildSensorCard(
                'CO',
                data.co.toStringAsFixed(1),
                'ppm',
                Icons.warning,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildSensorCard(
                'Debu',
                data.dust.toStringAsFixed(1),
                'µg/m³',
                Icons.air,
                Colors.grey,
              ),
              const SizedBox(height: 20),

              // Waktu update terakhir
              Center(
                child: Text(
                  'Terakhir update: ${_formatTime(data.timestamp)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status, int color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(color), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'Status Kualitas Udara',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            status,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          unit,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}

