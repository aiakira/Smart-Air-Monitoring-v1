import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_data.dart';
import '../theme/app_theme.dart';
import 'status_card.dart';
import 'sensor_detail_card.dart';

class DashboardHeader extends StatelessWidget {
  final SensorData currentData;
  final bool isConnected;
  final String? errorMessage;
  final bool isLoading;

  const DashboardHeader({
    super.key,
    required this.currentData,
    required this.isConnected,
    this.errorMessage,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage!,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    String status = currentData.getAirQualityStatus();
    int statusColor = currentData.getStatusColor();

    return StatusCard(
      status: status,
      color: Color(statusColor),
      icon: _getStatusIcon(status),
    );
  }

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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String _formatFullTimestamp(DateTime time) {
    final date =
        '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}';
    return '$date ${_formatTime(time)}';
  }
}

class SensorGrid extends StatelessWidget {
  final SensorData currentData;

  const SensorGrid({super.key, required this.currentData});

  @override
  Widget build(BuildContext context) {
    String status = currentData.getAirQualityStatus();
    int statusColor = currentData.getStatusColor();

    return Column(
      children: [
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
        SensorDetailCard(
          label: 'Karbon Dioksida (CO₂)',
          value: currentData.co2.toStringAsFixed(0),
          unit: 'ppm',
          category: currentData.getCO2Category(),
          description: currentData.getCO2Description(),
          icon: Icons.cloud_outlined,
          color: _getCO2Color(currentData.co2),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        SensorDetailCard(
          label: 'Karbon Monoksida (CO)',
          value: currentData.co.toStringAsFixed(1),
          unit: 'ppm',
          category: currentData.getCOCategory(),
          description: currentData.getCODescription(),
          icon: Icons.warning_amber_outlined,
          color: _getCOColor(currentData.co),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        SensorDetailCard(
          label: 'Partikel Debu (PM2.5)',
          value: currentData.dust.toStringAsFixed(1),
          unit: 'µg/m³',
          category: currentData.getDustCategory(),
          description: currentData.getDustDescription(),
          icon: Icons.air,
          color: _getDustColor(currentData.dust),
        ),
      ],
    );
  }

  Color _getCO2Color(double value) {
    if (value <= 800) return const Color(0xFF4CAF50);
    if (value <= 1000) return const Color(0xFF66BB6A);
    if (value <= 2000) return const Color(0xFFFFA726);
    if (value <= 5000) return const Color(0xFFFF5252);
    return const Color(0xFF8B0000);
  }

  Color _getCOColor(double value) {
    if (value <= 9) return const Color(0xFF4CAF50);
    if (value <= 35) return const Color(0xFFFFA726);
    if (value <= 200) return const Color(0xFFFF5252);
    if (value <= 800) return const Color(0xFFD32F2F);
    return const Color(0xFF8B0000);
  }

  Color _getDustColor(double value) {
    if (value <= 15) return const Color(0xFF4CAF50);
    if (value <= 35) return const Color(0xFFFFCA28);
    if (value <= 55) return const Color(0xFFFFA726);
    return const Color(0xFFFF5252);
  }
}

class ChartSection extends StatelessWidget {
  final List<SensorData> historicalData;
  final bool isLoading;

  const ChartSection({
    super.key,
    required this.historicalData,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tren Data (24 Jam Terakhir)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildSeparateChart(
          'Karbon Dioksida (CO₂)',
          historicalData.map((data) => data.co2).toList(),
          Colors.blue,
          'ppm',
          Icons.cloud_outlined,
        ),
        const SizedBox(height: 16),
        _buildSeparateChart(
          'Karbon Monoksida (CO)',
          historicalData.map((data) => data.co).toList(),
          Colors.orange,
          'ppm',
          Icons.warning_amber_outlined,
        ),
        const SizedBox(height: 16),
        _buildSeparateChart(
          'Partikel Debu (PM2.5)',
          historicalData.map((data) => data.dust).toList(),
          Colors.grey,
          'µg/m³',
          Icons.air,
        ),
      ],
    );
  }

  Widget _buildSeparateChart(
    String title,
    List<double> data,
    Color color,
    String unit,
    IconData icon,
  ) {
    if (historicalData.isEmpty || data.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Text('Belum ada data $title untuk periode ini'),
          ),
        ),
      );
    }

    double maxValue = data.reduce((a, b) => a > b ? a : b) * 1.1;
    double minValue = data.reduce((a, b) => a < b ? a : b) * 0.9;

    if (maxValue - minValue < 1) {
      maxValue = minValue + 10;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Nilai saat ini: ${data.last.toStringAsFixed(1)} $unit',
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
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxValue - minValue) / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: data.length > 6
                            ? (data.length / 6).ceilToDouble()
                            : 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < historicalData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${historicalData[index].timestamp.hour}:00',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
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
                      left: BorderSide(color: Colors.grey.shade300, width: 1),
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
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
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.3),
                            color.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Min',
                    data.reduce((a, b) => a < b ? a : b),
                    unit,
                    color,
                  ),
                  _buildStatItem(
                    'Max',
                    data.reduce((a, b) => a > b ? a : b),
                    unit,
                    color,
                  ),
                  _buildStatItem(
                    'Rata-rata',
                    data.reduce((a, b) => a + b) / data.length,
                    unit,
                    color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double value, String unit, Color color) {
      return Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      );
    }
}
