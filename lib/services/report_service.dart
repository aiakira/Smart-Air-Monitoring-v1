import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/health_data.dart';
import '../models/medical_profile.dart';
import '../models/symptom_data.dart';
import '../models/sensor_data.dart';
import 'package:intl/intl.dart';

class ReportService {
  /// Generate comprehensive doctor report
  static Future<String> generateDoctorReport({
    required MedicalProfile? medicalProfile,
    required HealthData? healthData,
    required List<SymptomData> symptoms,
    required List<SensorData> sensorHistory,
    int daysBack = 30,
  }) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: daysBack));
    
    // Filter data for the specified period
    final recentSymptoms = symptoms
        .where((s) => s.timestamp.isAfter(startDate))
        .toList();
    
    final recentSensorData = sensorHistory
        .where((s) => s.timestamp.isAfter(startDate))
        .toList();
    
    final report = StringBuffer();
    
    // Header
    report.writeln('LAPORAN KESEHATAN LINGKUNGAN');
    report.writeln('Smart Air Monitoring System');
    report.writeln('=' * 50);
    report.writeln('Tanggal Laporan: ${DateFormat('dd MMMM yyyy', 'id_ID').format(now)}');
    report.writeln('Periode Analisis: ${DateFormat('dd MMM yyyy', 'id_ID').format(startDate)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(now)}');
    report.writeln('');
    
    // Patient Information
    if (medicalProfile != null) {
      report.writeln('INFORMASI PASIEN');
      report.writeln('-' * 20);
      report.writeln('Nama: ${medicalProfile.name}');
      report.writeln('Usia: ${medicalProfile.age} tahun');
      report.writeln('Jenis Kelamin: ${medicalProfile.gender}');
      report.writeln('Status Asma: ${medicalProfile.isAsthmatic ? "Ya" : "Tidak"}');
      report.writeln('Status Perokok: ${medicalProfile.isSmoker ? "Ya" : "Tidak"}');
      report.writeln('Level Aktivitas: ${medicalProfile.activityLevel}');
      
      if (medicalProfile.allergies.isNotEmpty) {
        report.writeln('Alergi: ${medicalProfile.allergies.join(", ")}');
      }
      
      if (medicalProfile.medicalConditions.isNotEmpty) {
        report.writeln('Kondisi Medis: ${medicalProfile.medicalConditions.join(", ")}');
      }
      report.writeln('');
    }
    
    // Health Score Summary
    if (healthData != null) {
      report.writeln('RINGKASAN KESEHATAN');
      report.writeln('-' * 20);
      report.writeln('Skor Kesehatan: ${healthData.healthScore}/100');
      report.writeln('Status Kesehatan: ${healthData.healthStatus}');
      report.writeln('Deskripsi: ${healthData.getHealthDescription()}');
      report.writeln('');
      
      if (healthData.exposureHistory.isNotEmpty) {
        report.writeln('Rata-rata Paparan:');
        healthData.exposureHistory.forEach((sensor, value) {
          String unit = _getSensorUnit(sensor);
          report.writeln('  $sensor: ${value.toStringAsFixed(1)} $unit');
        });
        report.writeln('');
      }
    }
    
    // Symptoms Analysis
    if (recentSymptoms.isNotEmpty) {
      report.writeln('ANALISIS GEJALA ($daysBack HARI TERAKHIR)');
      report.writeln('-' * 30);
      
      // Group symptoms by type
      Map<String, List<SymptomData>> groupedSymptoms = {};
      for (var symptom in recentSymptoms) {
        groupedSymptoms[symptom.symptom] ??= [];
        groupedSymptoms[symptom.symptom]!.add(symptom);
      }
      
      groupedSymptoms.forEach((symptomType, occurrences) {
        report.writeln('$symptomType: ${occurrences.length} kali');
        
        // Calculate average severity
        double avgSeverity = occurrences
            .map((s) => s.severity)
            .reduce((a, b) => a + b) / occurrences.length;
        report.writeln('  Tingkat keparahan rata-rata: ${avgSeverity.toStringAsFixed(1)}/5');
        
        // Most recent occurrence
        var latest = occurrences.reduce((a, b) => 
            a.timestamp.isAfter(b.timestamp) ? a : b);
        report.writeln('  Terakhir: ${DateFormat('dd/MM/yyyy HH:mm').format(latest.timestamp)}');
        
        if (latest.notes != null && latest.notes!.isNotEmpty) {
          report.writeln('  Catatan: ${latest.notes}');
        }
        report.writeln('');
      });
    }
    
    // Environmental Analysis
    if (recentSensorData.isNotEmpty) {
      report.writeln('ANALISIS LINGKUNGAN ($daysBack HARI TERAKHIR)');
      report.writeln('-' * 30);
      
      final stats = _calculateSensorStatistics(recentSensorData);
      
      report.writeln('CO₂ (ppm):');
      report.writeln('  Rata-rata: ${stats['co2_avg']?.toStringAsFixed(1)}');
      report.writeln('  Minimum: ${stats['co2_min']?.toStringAsFixed(1)}');
      report.writeln('  Maksimum: ${stats['co2_max']?.toStringAsFixed(1)}');
      report.writeln('  Status: ${_getCO2Status(stats['co2_avg'] ?? 0)}');
      report.writeln('');
      
      report.writeln('CO (ppm):');
      report.writeln('  Rata-rata: ${stats['co_avg']?.toStringAsFixed(2)}');
      report.writeln('  Minimum: ${stats['co_min']?.toStringAsFixed(2)}');
      report.writeln('  Maksimum: ${stats['co_max']?.toStringAsFixed(2)}');
      report.writeln('  Status: ${_getCOStatus(stats['co_avg'] ?? 0)}');
      report.writeln('');
      
      report.writeln('Debu PM2.5 (µg/m³):');
      report.writeln('  Rata-rata: ${stats['dust_avg']?.toStringAsFixed(1)}');
      report.writeln('  Minimum: ${stats['dust_min']?.toStringAsFixed(1)}');
      report.writeln('  Maksimum: ${stats['dust_max']?.toStringAsFixed(1)}');
      report.writeln('  Status: ${_getDustStatus(stats['dust_avg'] ?? 0)}');
      report.writeln('');
      
      report.writeln('Kebisingan (dB):');
      report.writeln('  Rata-rata: ${stats['noise_avg']?.toStringAsFixed(1)}');
      report.writeln('  Minimum: ${stats['noise_min']?.toStringAsFixed(1)}');
      report.writeln('  Maksimum: ${stats['noise_max']?.toStringAsFixed(1)}');
      report.writeln('  Status: ${_getNoiseStatus(stats['noise_avg'] ?? 0)}');
      report.writeln('');
    }
    
    // Correlations
    if (recentSymptoms.isNotEmpty && recentSensorData.isNotEmpty) {
      report.writeln('KORELASI GEJALA DAN LINGKUNGAN');
      report.writeln('-' * 30);
      
      final correlations = _analyzeSymptomCorrelations(recentSymptoms, recentSensorData);
      correlations.forEach((correlation) {
        report.writeln('• $correlation');
      });
      report.writeln('');
    }
    
    // Recommendations
    if (healthData != null && healthData.recommendations.isNotEmpty) {
      report.writeln('REKOMENDASI');
      report.writeln('-' * 15);
      for (int i = 0; i < healthData.recommendations.length; i++) {
        report.writeln('${i + 1}. ${healthData.recommendations[i]}');
      }
      report.writeln('');
    }
    
    // Medical Recommendations
    report.writeln('REKOMENDASI MEDIS');
    report.writeln('-' * 20);
    
    if (medicalProfile?.isAsthmatic == true) {
      report.writeln('• Pasien asma: Monitor ketat paparan debu dan CO₂');
      report.writeln('• Pertimbangkan penggunaan inhaler preventif saat kualitas udara buruk');
    }
    
    if (recentSymptoms.any((s) => s.symptom == 'Sesak Napas')) {
      report.writeln('• Gejala sesak napas berulang: Evaluasi fungsi paru');
      report.writeln('• Pertimbangkan spirometri dan tes alergi');
    }
    
    if (recentSymptoms.any((s) => s.symptom == 'Sakit Kepala')) {
      report.writeln('• Sakit kepala berulang: Periksa korelasi dengan kadar CO₂');
      report.writeln('• Evaluasi ventilasi ruangan tempat tinggal/kerja');
    }
    
    report.writeln('• Lanjutkan monitoring kualitas udara secara berkala');
    report.writeln('• Konsultasi rutin dengan dokter spesialis paru jika diperlukan');
    report.writeln('');
    
    // Footer
    report.writeln('=' * 50);
    report.writeln('Laporan ini dibuat secara otomatis oleh Smart Air Monitoring System');
    report.writeln('Untuk konsultasi lebih lanjut, hubungi dokter Anda');
    report.writeln('');
    
    return report.toString();
  }
  
  /// Save report to file and share
  static Future<void> shareReport(String reportContent, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.txt');
      await file.writeAsString(reportContent);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Laporan Kesehatan Lingkungan',
      );
    } catch (e) {
      // Fallback to sharing text content
      await Share.share(
        reportContent,
        subject: 'Laporan Kesehatan Lingkungan',
      );
    }
  }
  
  static Map<String, double> _calculateSensorStatistics(List<SensorData> data) {
    if (data.isEmpty) return {};
    
    double co2Sum = 0, coSum = 0, dustSum = 0, noiseSum = 0;
    double co2Min = data.first.co2, co2Max = data.first.co2;
    double coMin = data.first.co, coMax = data.first.co;
    double dustMin = data.first.dust, dustMax = data.first.dust;
    double noiseMin = data.first.noise, noiseMax = data.first.noise;
    
    for (var reading in data) {
      co2Sum += reading.co2;
      coSum += reading.co;
      dustSum += reading.dust;
      noiseSum += reading.noise;
      
      if (reading.co2 < co2Min) co2Min = reading.co2;
      if (reading.co2 > co2Max) co2Max = reading.co2;
      if (reading.co < coMin) coMin = reading.co;
      if (reading.co > coMax) coMax = reading.co;
      if (reading.dust < dustMin) dustMin = reading.dust;
      if (reading.dust > dustMax) dustMax = reading.dust;
      if (reading.noise < noiseMin) noiseMin = reading.noise;
      if (reading.noise > noiseMax) noiseMax = reading.noise;
    }
    
    int count = data.length;
    return {
      'co2_avg': co2Sum / count,
      'co2_min': co2Min,
      'co2_max': co2Max,
      'co_avg': coSum / count,
      'co_min': coMin,
      'co_max': coMax,
      'dust_avg': dustSum / count,
      'dust_min': dustMin,
      'dust_max': dustMax,
      'noise_avg': noiseSum / count,
      'noise_min': noiseMin,
      'noise_max': noiseMax,
    };
  }
  
  static List<String> _analyzeSymptomCorrelations(
    List<SymptomData> symptoms,
    List<SensorData> sensorData,
  ) {
    List<String> correlations = [];
    
    // Simple correlation analysis
    for (var symptom in symptoms) {
      // Find sensor data around symptom time (±2 hours)
      final symptomTime = symptom.timestamp;
      final relevantData = sensorData.where((data) {
        final diff = data.timestamp.difference(symptomTime).abs();
        return diff.inHours <= 2;
      }).toList();
      
      if (relevantData.isNotEmpty) {
        final avgData = relevantData.first; // Simplified - use first match
        
        if (symptom.symptom == 'Batuk' && avgData.dust > 35) {
          correlations.add('Batuk berkorelasi dengan tingginya kadar debu (${avgData.dust.toStringAsFixed(0)} µg/m³)');
        }
        
        if (symptom.symptom == 'Sakit Kepala' && avgData.co2 > 1000) {
          correlations.add('Sakit kepala berkorelasi dengan tingginya CO₂ (${avgData.co2.toStringAsFixed(0)} ppm)');
        }
        
        if (symptom.symptom == 'Sesak Napas' && (avgData.co2 > 1200 || avgData.dust > 50)) {
          correlations.add('Sesak napas berkorelasi dengan kualitas udara buruk');
        }
      }
    }
    
    if (correlations.isEmpty) {
      correlations.add('Tidak ditemukan korelasi yang signifikan dalam periode ini');
    }
    
    return correlations;
  }
  
  static String _getSensorUnit(String sensor) {
    switch (sensor.toLowerCase()) {
      case 'co2': return 'ppm';
      case 'co': return 'ppm';
      case 'dust': return 'µg/m³';
      case 'noise': return 'dB';
      default: return '';
    }
  }
  
  static String _getCO2Status(double co2) {
    if (co2 <= 800) return 'Baik';
    if (co2 <= 1000) return 'Masih Aman';
    if (co2 <= 2000) return 'Tidak Sehat';
    if (co2 <= 5000) return 'Bahaya';
    return 'Sangat Berbahaya';
  }
  
  static String _getCOStatus(double co) {
    if (co <= 9) return 'Aman';
    if (co <= 35) return 'Tidak Sehat';
    if (co <= 200) return 'Berbahaya';
    if (co <= 800) return 'Sangat Berbahaya';
    return 'Fatal';
  }
  
  static String _getDustStatus(double dust) {
    if (dust <= 15) return 'Baik';
    if (dust <= 35) return 'Sedang';
    if (dust <= 55) return 'Tidak Sehat';
    return 'Sangat Tidak Sehat';
  }
  
  static String _getNoiseStatus(double noise) {
    if (noise <= 30) return 'Sangat Tenang';
    if (noise <= 40) return 'Tenang';
    if (noise <= 55) return 'Normal';
    if (noise <= 70) return 'Bising';
    if (noise <= 85) return 'Sangat Bising';
    return 'Berbahaya';
  }
}