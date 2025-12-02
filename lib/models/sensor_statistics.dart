class SensorStatistics {
  final int totalData;
  final double avgCo2;
  final double maxCo2;
  final double minCo2;
  final double avgCo;
  final double maxCo;
  final double minCo;
  final double avgDust;
  final double maxDust;
  final double minDust;
  final int hours;

  const SensorStatistics({
    required this.totalData,
    required this.avgCo2,
    required this.maxCo2,
    required this.minCo2,
    required this.avgCo,
    required this.maxCo,
    required this.minCo,
    required this.avgDust,
    required this.maxDust,
    required this.minDust,
    required this.hours,
  });

  factory SensorStatistics.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int _toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return SensorStatistics(
      totalData: _toInt(json['total_data']),
      avgCo2: _toDouble(json['avg_co2']),
      maxCo2: _toDouble(json['max_co2']),
      minCo2: _toDouble(json['min_co2']),
      avgCo: _toDouble(json['avg_co']),
      maxCo: _toDouble(json['max_co']),
      minCo: _toDouble(json['min_co']),
      avgDust: _toDouble(json['avg_dust']),
      maxDust: _toDouble(json['max_dust']),
      minDust: _toDouble(json['min_dust']),
      hours: _toInt(json['hours']),
    );
  }

  bool get hasData => totalData > 0;

  String formatValue(double value, {int fractionDigits = 1, String placeholder = '-'}) {
    if (value.isNaN) return placeholder;
    return value.toStringAsFixed(fractionDigits);
  }
}

