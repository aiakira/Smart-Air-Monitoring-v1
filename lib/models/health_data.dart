import 'package:flutter/material.dart';

/// Model untuk data kesehatan pengguna
class HealthData {
  final int healthScore; // Skor kesehatan 0-100
  final String healthStatus; // EXCELLENT, GOOD, FAIR, POOR, DANGEROUS
  final List<String> symptoms; // Gejala yang dialami
  final DateTime lastUpdated;
  final Map<String, double> exposureHistory; // History exposure per sensor
  final List<String> recommendations; // Rekomendasi kesehatan

  HealthData({
    required this.healthScore,
    required this.healthStatus,
    required this.symptoms,
    required this.lastUpdated,
    required this.exposureHistory,
    required this.recommendations,
  });

  factory HealthData.fromSensorData(List<dynamic> sensorHistory, List<String> userSymptoms) {
    // Calculate health score based on exposure
    int score = _calculateHealthScore(sensorHistory);
    String status = _getHealthStatus(score);
    List<String> recommendations = _generateRecommendations(score, userSymptoms);

    return HealthData(
      healthScore: score,
      healthStatus: status,
      symptoms: userSymptoms,
      lastUpdated: DateTime.now(),
      exposureHistory: _calculateExposureHistory(sensorHistory),
      recommendations: recommendations,
    );
  }

  static int _calculateHealthScore(List<dynamic> sensorHistory) {
    if (sensorHistory.isEmpty) return 100;

    double totalScore = 0;
    int count = 0;

    for (var data in sensorHistory) {
      if (data is Map<String, dynamic>) {
        double co2 = (data['co2'] ?? 0).toDouble();
        double co = (data['co'] ?? 0).toDouble();
        double dust = (data['dust'] ?? 0).toDouble();
        double noise = (data['noise'] ?? 0).toDouble();

        // Score each parameter (0-100, higher is better)
        double co2Score = _scoreCO2(co2);
        double coScore = _scoreCO(co);
        double dustScore = _scoreDust(dust);
        double noiseScore = _scoreNoise(noise);

        totalScore += (co2Score + coScore + dustScore + noiseScore) / 4;
        count++;
      }
    }

    return count > 0 ? (totalScore / count).round() : 100;
  }

  static double _scoreCO2(double co2) {
    if (co2 <= 400) return 100;
    if (co2 <= 800) return 90;
    if (co2 <= 1000) return 70;
    if (co2 <= 2000) return 40;
    if (co2 <= 5000) return 20;
    return 0;
  }

  static double _scoreCO(double co) {
    if (co <= 9) return 100;
    if (co <= 35) return 60;
    if (co <= 200) return 30;
    if (co <= 800) return 10;
    return 0;
  }

  static double _scoreDust(double dust) {
    if (dust <= 15) return 100;
    if (dust <= 35) return 70;
    if (dust <= 55) return 40;
    return 20;
  }

  static double _scoreNoise(double noise) {
    if (noise <= 30) return 100;
    if (noise <= 40) return 90;
    if (noise <= 55) return 80;
    if (noise <= 70) return 60;
    if (noise <= 85) return 30;
    return 10;
  }

  static String _getHealthStatus(int score) {
    if (score >= 90) return 'EXCELLENT';
    if (score >= 75) return 'GOOD';
    if (score >= 60) return 'FAIR';
    if (score >= 40) return 'POOR';
    return 'DANGEROUS';
  }

  static Map<String, double> _calculateExposureHistory(List<dynamic> sensorHistory) {
    Map<String, List<double>> values = {
      'co2': [],
      'co': [],
      'dust': [],
      'noise': [],
    };

    for (var data in sensorHistory) {
      if (data is Map<String, dynamic>) {
        values['co2']!.add((data['co2'] ?? 0).toDouble());
        values['co']!.add((data['co'] ?? 0).toDouble());
        values['dust']!.add((data['dust'] ?? 0).toDouble());
        values['noise']!.add((data['noise'] ?? 0).toDouble());
      }
    }

    return {
      'co2': values['co2']!.isNotEmpty ? values['co2']!.reduce((a, b) => a + b) / values['co2']!.length : 0,
      'co': values['co']!.isNotEmpty ? values['co']!.reduce((a, b) => a + b) / values['co']!.length : 0,
      'dust': values['dust']!.isNotEmpty ? values['dust']!.reduce((a, b) => a + b) / values['dust']!.length : 0,
      'noise': values['noise']!.isNotEmpty ? values['noise']!.reduce((a, b) => a + b) / values['noise']!.length : 0,
    };
  }

  static List<String> _generateRecommendations(int score, List<String> symptoms) {
    List<String> recommendations = [];

    if (score < 40) {
      recommendations.add('🚨 Segera perbaiki kualitas udara ruangan');
      recommendations.add('💨 Nyalakan ventilasi atau air purifier');
      recommendations.add('🏥 Konsultasi dengan dokter jika gejala berlanjut');
    } else if (score < 60) {
      recommendations.add('⚠️ Tingkatkan ventilasi ruangan');
      recommendations.add('🌱 Tambahkan tanaman pembersih udara');
      recommendations.add('😷 Gunakan masker jika perlu');
    } else if (score < 75) {
      recommendations.add('✅ Pertahankan kualitas udara saat ini');
      recommendations.add('🔄 Monitor secara berkala');
    } else {
      recommendations.add('🎉 Kualitas udara sangat baik!');
      recommendations.add('💪 Aman untuk aktivitas normal');
    }

    // Symptom-specific recommendations
    if (symptoms.contains('Batuk')) {
      recommendations.add('🍯 Minum air hangat dengan madu');
      recommendations.add('💧 Jaga kelembaban udara 40-60%');
    }
    if (symptoms.contains('Sesak Napas')) {
      recommendations.add('🫁 Hindari aktivitas berat');
      recommendations.add('🏥 Segera konsultasi dokter');
    }
    if (symptoms.contains('Sakit Kepala')) {
      recommendations.add('💨 Perbaiki ventilasi ruangan');
      recommendations.add('💤 Istirahat yang cukup');
    }

    return recommendations;
  }

  Color getHealthColor() {
    switch (healthStatus) {
      case 'EXCELLENT':
        return const Color(0xFF4CAF50);
      case 'GOOD':
        return const Color(0xFF8BC34A);
      case 'FAIR':
        return const Color(0xFFFFEB3B);
      case 'POOR':
        return const Color(0xFFFF9800);
      case 'DANGEROUS':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String getHealthDescription() {
    switch (healthStatus) {
      case 'EXCELLENT':
        return 'Kesehatan Anda sangat baik! Kualitas udara optimal.';
      case 'GOOD':
        return 'Kesehatan Anda baik. Kualitas udara cukup baik.';
      case 'FAIR':
        return 'Kesehatan Anda cukup. Perhatikan kualitas udara.';
      case 'POOR':
        return 'Kesehatan Anda kurang baik. Perbaiki kualitas udara.';
      case 'DANGEROUS':
        return 'Kesehatan Anda dalam bahaya! Segera perbaiki udara.';
      default:
        return 'Status kesehatan tidak diketahui.';
    }
  }
}