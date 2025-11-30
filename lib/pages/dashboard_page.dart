import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sensor_card.dart';
import '../widgets/sensor_detail_card.dart';
import '../widgets/status_card.dart';
import '../widgets/info_banner.dart';
import 'notifications_page.dart';
import 'control_page.dart';
import 'analytics_page.dart';
import 'settings_page.dart';

// Halaman Dashboard - menampilkan data sensor secara real-time
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Data sensor dari API
  SensorData _currentData = SensorData(
    co2: 0,
    co: 0,
    dust: 0,
    timestamp: DateTime.now(),
  );

  int _unreadNotifications = 0; // Jumlah notifikasi belum dibaca
  
  // Data historis untuk grafik (24 data point terakhir)
  List<SensorData> _historicalData = [];
  
  // Status koneksi API
  bool _isConnected = false;
  bool _isLoading = true;
  bool _useSimulationData = false;

  @override
  void initState() {
    super.initState();
    _loadUnreadNotificationsCount();
    _checkApiConnection();
    _loadDataFromApi();
    // Update data setiap 5 detik
    _startDataUpdate();
  }
  
  // Cek koneksi ke API
  Future<void> _checkApiConnection() async {
    try {
      final isConnected = await ApiService.testConnection();
      setState(() {
        _isConnected = isConnected;
        _useSimulationData = !isConnected;
      });
      
      if (!isConnected) {
        _showConnectionError();
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _useSimulationData = true;
      });
      _showConnectionError();
    }
  }
  
  // Tampilkan pesan error koneksi
  void _showConnectionError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('API tidak tersedia. Menggunakan data simulasi.'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  // Load data dari API
  Future<void> _loadDataFromApi() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Ambil data terbaru
      final latestData = await ApiService.getLatestData();
      
      // Ambil data historis untuk grafik
      final historicalData = await ApiService.getHistoricalData(hours: 24);
      
      if (latestData != null) {
        setState(() {
          _currentData = latestData;
          _isConnected = true;
          _useSimulationData = false;
        });
      } else {
        // Fallback ke data simulasi
        _generateSimulationData();
      }
      
      if (historicalData.isNotEmpty) {
        setState(() {
          _historicalData = historicalData;
        });
      } else {
        // Fallback ke data simulasi untuk grafik
        _initializeHistoricalData();
      }
    } catch (e) {
      // Jika error, gunakan data simulasi
      _generateSimulationData();
      _initializeHistoricalData();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Generate data simulasi (fallback)
  void _generateSimulationData() {
    setState(() {
      _currentData = SensorData(
        co2: 400 + (DateTime.now().millisecond % 600),
        co: 3 + (DateTime.now().millisecond % 20),
        dust: 20 + (DateTime.now().millisecond % 50),
        timestamp: DateTime.now(),
      );
      _isConnected = false;
      _useSimulationData = true;
    });
  }
  
  // Inisialisasi data historis untuk grafik (simulasi)
  void _initializeHistoricalData() {
    _historicalData.clear();
    DateTime now = DateTime.now();
    for (int i = 23; i >= 0; i--) {
      _historicalData.add(
        SensorData(
          co2: 400 + (i * 10) + (i % 3) * 30,
          co: 3 + (i * 0.5) + (i % 2) * 5,
          dust: 20 + (i * 1.5) + (i % 4) * 10,
          timestamp: now.subtract(Duration(hours: i)),
        ),
      );
    }
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

  void _startDataUpdate() {
    // Update data setiap 5 detik
    Future.delayed(const Duration(seconds: 5), () async {
      if (mounted) {
        if (_useSimulationData) {
          // Jika menggunakan simulasi, generate data baru
          _generateSimulationData();
          
          // Update grafik dengan data simulasi
          setState(() {
            _historicalData.add(_currentData);
            if (_historicalData.length > 24) {
              _historicalData.removeAt(0);
            }
          });
        } else {
          // Jika menggunakan API, ambil data terbaru
          try {
            final latestData = await ApiService.getLatestData();
            
            if (latestData != null) {
              setState(() {
                _currentData = latestData;
                _isConnected = true;
                
                // Update grafik dengan data baru
                _historicalData.add(_currentData);
                if (_historicalData.length > 24) {
                  _historicalData.removeAt(0);
                }
              });
            } else {
              // Jika gagal, coba lagi atau switch ke simulasi
              setState(() {
                _isConnected = false;
              });
            }
          } catch (e) {
            setState(() {
              _isConnected = false;
            });
          }
        }
        
        _startDataUpdate(); // Update lagi
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String status = _currentData.getAirQualityStatus();
    int statusColor = _currentData.getStatusColor();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Dashboard'),
            const SizedBox(width: 12),
            // Indikator WiFi
            Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              size: 20,
              color: _isConnected ? Colors.white : Colors.red.shade200,
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Ikon notifikasi di pojok kanan atas
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
        onRefresh: () async {
          // Refresh data dari API
          await _checkApiConnection();
          await _loadDataFromApi();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indikator mode data
              if (_useSimulationData)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
                  child: InfoBanner(
                    message: 'Mode Simulasi - API tidak terhubung',
                    type: BannerType.warning,
                    actionLabel: 'Coba Lagi',
                    onAction: () async {
                      await _checkApiConnection();
                      await _loadDataFromApi();
                    },
                  ),
                ),
              
              // Loading indicator
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
              
              // Bagian 1: Status Udara
              if (!_isLoading)
                StatusCard(
                  status: status,
                  color: Color(statusColor),
                  icon: _getStatusIcon(status),
                ),
              const SizedBox(height: AppTheme.spacingLarge),

              // Bagian 2: Data Sensor dengan Detail
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Data Sensor Real-time',
                    style: AppTheme.headingMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: AppTheme.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Color(statusColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      border: Border.all(color: Color(statusColor)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(statusColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              
              // Rekomendasi
              if (!_isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  decoration: BoxDecoration(
                    color: Color(statusColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    border: Border.all(
                      color: Color(statusColor).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Color(statusColor),
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Expanded(
                        child: Text(
                          _currentData.getRecommendation(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(statusColor),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppTheme.spacingMedium),
              
              // Sensor Detail Cards
              SensorDetailCard(
                label: 'Karbon Dioksida (CO₂)',
                value: _currentData.co2.toStringAsFixed(0),
                unit: 'ppm',
                category: _currentData.getCO2Category(),
                description: _currentData.getCO2Description(),
                icon: Icons.cloud_outlined,
                color: _getCO2Color(_currentData.co2),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              SensorDetailCard(
                label: 'Karbon Monoksida (CO)',
                value: _currentData.co.toStringAsFixed(1),
                unit: 'ppm',
                category: _currentData.getCOCategory(),
                description: _currentData.getCODescription(),
                icon: Icons.warning_amber_outlined,
                color: _getCOColor(_currentData.co),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              SensorDetailCard(
                label: 'Partikel Debu (PM2.5)',
                value: _currentData.dust.toStringAsFixed(1),
                unit: 'µg/m³',
                category: _currentData.getDustCategory(),
                description: _currentData.getDustDescription(),
                icon: Icons.air,
                color: _getDustColor(_currentData.dust),
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // Bagian 3: Grafik Tren
              const Text(
                'Tren Data (24 Jam Terakhir)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildTrendChart(),
              const SizedBox(height: 20),

              // Status koneksi dan waktu update
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isConnected ? Icons.wifi : Icons.wifi_off,
                          size: 16,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isConnected ? 'Terhubung' : 'Tidak Terhubung',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terakhir update: ${_formatTime(_currentData.timestamp)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk mendapatkan icon status
  IconData _getStatusIcon(String status) {
    if (status.contains('BAIK') || status.contains('AMAN')) {
      return Icons.check_circle;
    } else if (status.contains('SEDANG')) {
      return Icons.info;
    } else if (status.contains('FATAL') || status.contains('SANGAT')) {
      return Icons.dangerous;
    } else {
      return Icons.warning;
    }
  }

  // Helper untuk mendapatkan warna CO₂
  Color _getCO2Color(double value) {
    if (value <= 800) {
      return const Color(0xFF4CAF50); // Green - Baik
    } else if (value <= 1000) {
      return const Color(0xFF66BB6A); // Light Green - Masih Aman
    } else if (value <= 2000) {
      return const Color(0xFFFFA726); // Orange - Tidak Sehat
    } else if (value <= 5000) {
      return const Color(0xFFFF5252); // Red - Bahaya
    } else {
      return const Color(0xFF8B0000); // Dark Red - Sangat Berbahaya
    }
  }

  // Helper untuk mendapatkan warna CO
  Color _getCOColor(double value) {
    if (value <= 9) {
      return const Color(0xFF4CAF50); // Green - Aman
    } else if (value <= 35) {
      return const Color(0xFFFFA726); // Orange - Tidak Sehat
    } else if (value <= 200) {
      return const Color(0xFFFF5252); // Red - Berbahaya
    } else if (value <= 800) {
      return const Color(0xFFD32F2F); // Dark Red - Sangat Berbahaya
    } else {
      return const Color(0xFF8B0000); // Very Dark Red - Fatal
    }
  }

  // Helper untuk mendapatkan warna Debu
  Color _getDustColor(double value) {
    if (value <= 15) {
      return const Color(0xFF4CAF50); // Green - Baik
    } else if (value <= 35) {
      return const Color(0xFFFFCA28); // Amber - Sedang
    } else if (value <= 55) {
      return const Color(0xFFFFA726); // Orange - Tidak Sehat
    } else {
      return const Color(0xFFFF5252); // Red - Sangat Tidak Sehat
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  // Widget untuk menampilkan grafik tren
  Widget _buildTrendChart() {
    if (_historicalData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text('Memuat data grafik...'),
          ),
        ),
      );
    }

    List<double> co2Data = _historicalData.map((data) => data.co2).toList();
    List<double> coData = _historicalData.map((data) => data.co).toList();
    List<double> dustData = _historicalData.map((data) => data.dust).toList();

    double maxCo2 = co2Data.reduce((a, b) => a > b ? a : b) * 1.1;
    double minCo2 = co2Data.reduce((a, b) => a < b ? a : b) * 0.9;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Grafik CO2
            SizedBox(
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'CO₂ (ppm)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: (maxCo2 - minCo2) / 4,
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: co2Data.length / 4,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < _historicalData.length) {
                                  return Text(
                                    '${_historicalData[index].timestamp.hour}:00',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(color: Colors.grey.shade300),
                            bottom: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        minX: 0,
                        maxX: (co2Data.length - 1).toDouble(),
                        minY: minCo2,
                        maxY: maxCo2,
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              co2Data.length,
                              (index) => FlSpot(index.toDouble(), co2Data[index]),
                            ),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Grafik CO dan Debu (mini)
            Row(
              children: [
                Expanded(
                  child: _buildMiniChart(
                    'CO',
                    coData,
                    Colors.orange,
                    'ppm',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniChart(
                    'Debu',
                    dustData,
                    Colors.grey,
                    'µg/m³',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk grafik mini
  Widget _buildMiniChart(String label, List<double> data, Color color, String unit) {
    double maxValue = data.reduce((a, b) => a > b ? a : b) * 1.1;
    double minValue = data.reduce((a, b) => a < b ? a : b) * 0.9;

    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$label ($unit)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: minValue,
                maxY: maxValue,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      data.length,
                      (index) => FlSpot(index.toDouble(), data[index]),
                    ),
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk navigasi utama dengan Bottom Navigation Bar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const DashboardPage(),
    const ControlPage(),
    const AnalyticsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_remote),
            label: 'Kontrol',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analitik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

