import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_data.dart';
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
  bool _isLoadingData = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadHistoricalData();
  }

  Future<void> _loadHistoricalData({int hours = 24}) async {
    setState(() {
      _isLoadingData = true;
      _hasError = false;
    });

    try {
      final data = await ApiService.getHistoricalData(hours: hours);
      
      if (data.isNotEmpty) {
        setState(() {
          _historicalData = data;
          _isLoadingData = false;
        });
      } else {
        _generateSampleData();
        setState(() {
          _isLoadingData = false;
        });
      }
    } catch (e) {
      _generateSampleData();
      setState(() {
        _isLoadingData = false;
        _hasError = true;
      });
    }
  }

  void _generateSampleData() {
    _historicalData = [];
    DateTime now = DateTime.now();
    for (int i = 23; i >= 0; i--) {
      _historicalData.add(
        SensorData(
          co2: 400 + (i * 20) + (i % 3) * 50,
          co: 5 + (i * 1.5) + (i % 2) * 10,
          dust: 20 + (i * 2) + (i % 4) * 15,
          timestamp: now.subtract(Duration(hours: i)),
        ),
      );
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
          Container(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedSensor,
              decoration: InputDecoration(
                labelText: 'Pilih Sensor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: ['CO₂', 'CO', 'Debu'].map((String sensor) {
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
          ),

          if (_hasError)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'API tidak tersedia, menampilkan data simulasi',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grafik $_selectedSensor',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isLoadingData)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _isLoadingData && _historicalData.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : _historicalData.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.bar_chart,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Tidak ada data',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : _buildLineChart(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            flex: 2,
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
                    Expanded(
                      child: _buildHistoryTable(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    List<double> data = _getSelectedData();
    double maxValue = data.reduce((a, b) => a > b ? a : b) * 1.2;
    double minValue = data.reduce((a, b) => a < b ? a : b) * 0.8;

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
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
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < _historicalData.length) {
                  return Text(
                    DateFormat('HH:mm').format(
                      _historicalData[index].timestamp,
                    ),
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
        borderData: FlBorderData(show: true),
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
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTable() {
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
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                _selectedSensor == 'CO₂'
                    ? Icons.cloud
                    : _selectedSensor == 'CO'
                        ? Icons.warning
                        : Icons.air,
                color: Colors.blue.shade700,
                size: 20,
              ),
            ),
            title: Text(
              '${value.toStringAsFixed(1)} $unit',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(sensorData.timestamp),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(sensorData.getStatusColor()).withValues(alpha: 0.1),
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
