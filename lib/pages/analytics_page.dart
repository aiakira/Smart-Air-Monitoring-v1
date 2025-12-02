import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../models/sensor_statistics.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedSensor = 'CO₂';

  List<SensorData> _historicalData = [];
  SensorStatistics? _statistics;
  bool _isLoadingData = false;
  String? _errorMessage;
  int _selectedHours = 24;
  final List<int> _hoursOptions = [6, 24, 72, 168];

  @override
  void initState() {
    super.initState();
    _loadHistoricalData(hours: _selectedHours);
  }

  Future<void> _loadHistoricalData({int? hours}) async {
    final targetHours = hours ?? _selectedHours;
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
      _selectedHours = targetHours;
    });

    try {
      final results = await Future.wait([
        ApiService.getHistoricalData(hours: targetHours),
        ApiService.getSensorStatistics(hours: targetHours),
      ]);

      if (!mounted) return;

      final data = results[0] as List<SensorData>;
      final stats = results[1] as SensorStatistics?;

      setState(() {
        _historicalData = data;
        _statistics = stats;
        _isLoadingData = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  List<double> _getSelectedData() {
    switch (_selectedSensor) {
      case 'CO₂':
        return _historicalData.map((data) => data.co2).toList();
      case 'CO':
        return _historicalData.map((data) => data.co).toList();
      case 'Debu':
        return _historicalData.map((data) => data.dust).toList();
      case 'Kebisingan':
        return _historicalData.map((data) => data.noise).toList();
      default:
        return [];
    }
  }

  String _getUnit() {
    switch (_selectedSensor) {
      case 'CO₂':
        return 'ppm';
      case 'CO':
        return 'ppm';
      case 'Debu':
        return 'µg/m³';
      case 'Kebisingan':
        return 'dB';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analitik Data'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadHistoricalData(),
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          if (!_isLoadingData && _errorMessage == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatisticsCard(),
            ),
          if (_isLoadingData)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (!_isLoadingData && _errorMessage != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _loadHistoricalData(hours: _selectedHours),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!_isLoadingData && _errorMessage == null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Tabel Riwayat $_selectedSensor',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: _buildHistoryTable()),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedSensor,
            decoration: InputDecoration(
              labelText: 'Pilih Sensor',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: ['CO₂', 'CO', 'Debu', 'Kebisingan'].map((String sensor) {
              return DropdownMenuItem<String>(
                value: sensor,
                child: Text(sensor),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null && newValue != _selectedSensor) {
                setState(() {
                  _selectedSensor = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Rentang Waktu',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _hoursOptions.map((hour) {
              return ChoiceChip(
                label: Text('$hour jam'),
                selected: _selectedHours == hour,
                onSelected: (selected) {
                  if (selected && _selectedHours != hour) {
                    _loadHistoricalData(hours: hour);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final stats = _statistics;
    if (stats == null) {
      return const SizedBox.shrink();
    }

    if (!stats.hasData) {
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Belum ada data untuk $_selectedHours jam terakhir.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan $_selectedHours jam terakhir',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSensorStatTile(
              label: 'CO₂',
              avg: stats.avgCo2,
              min: stats.minCo2,
              max: stats.maxCo2,
              unit: 'ppm',
              color: Colors.blue.shade600,
            ),
            const Divider(height: 24),
            _buildSensorStatTile(
              label: 'CO',
              avg: stats.avgCo,
              min: stats.minCo,
              max: stats.maxCo,
              unit: 'ppm',
              color: Colors.orange.shade700,
            ),
            const Divider(height: 24),
            _buildSensorStatTile(
              label: 'Debu',
              avg: stats.avgDust,
              min: stats.minDust,
              max: stats.maxDust,
              unit: 'µg/m³',
              color: Colors.green.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorStatTile({
    required String label,
    required double avg,
    required double min,
    required double max,
    required String unit,
    required Color color,
  }) {
    String format(double value) => value.isNaN ? '-' : value.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatValue('Rata-rata', '${format(avg)} $unit'),
            _buildStatValue('Min', '${format(min)} $unit'),
            _buildStatValue('Max', '${format(max)} $unit'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildHistoryTable() {
    if (_historicalData.isEmpty) {
      return Center(
        child: Text(
          'Belum ada data $_selectedSensor untuk $_selectedHours jam terakhir.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    List<double> data = _getSelectedData();
    String unit = _getUnit();

    return ListView.builder(
      itemCount: _historicalData.length,
      itemBuilder: (context, index) {
        int reverseIndex = _historicalData.length - 1 - index;
        SensorData sensorData = _historicalData[reverseIndex];
        double value = data[reverseIndex];

        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                _selectedSensor == 'CO₂'
                    ? Icons.cloud
                    : _selectedSensor == 'CO'
                    ? Icons.warning
                    : _selectedSensor == 'Kebisingan'
                    ? Icons.volume_up
                    : Icons.air,
                color: Colors.blue.shade700,
                size: 20,
              ),
            ),
            title: Text(
              '${value.toStringAsFixed(1)} $unit',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(sensorData.timestamp),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(sensorData.getStatusColor()).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                sensorData.getAirQualityStatus(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(sensorData.getStatusColor()),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
