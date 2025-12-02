import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/health_data.dart';
import '../models/symptom_data.dart';
import '../models/medical_profile.dart';

class HealthProvider extends ChangeNotifier {
  HealthData? _healthData;
  MedicalProfile? _medicalProfile;
  List<SymptomData> _symptoms = [];
  bool _isLoading = false;

  // Getters
  HealthData? get healthData => _healthData;
  MedicalProfile? get medicalProfile => _medicalProfile;
  List<SymptomData> get symptoms => _symptoms;
  bool get isLoading => _isLoading;

  HealthProvider() {
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load medical profile
      final profileJson = prefs.getString('medical_profile');
      if (profileJson != null) {
        _medicalProfile = MedicalProfile.fromJson(json.decode(profileJson));
      }

      // Load symptoms
      final symptomsJson = prefs.getString('symptoms');
      if (symptomsJson != null) {
        final List<dynamic> symptomsList = json.decode(symptomsJson);
        _symptoms = symptomsList.map((e) => SymptomData.fromJson(e)).toList();
      }

    } catch (e) {
      debugPrint('Error loading health data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update health data based on sensor readings
  Future<void> updateHealthData(List<dynamic> sensorHistory) async {
    try {
      List<String> currentSymptoms = _symptoms
          .where((s) => s.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7))))
          .map((s) => s.symptom)
          .toList();

      _healthData = HealthData.fromSensorData(sensorHistory, currentSymptoms);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating health data: $e');
    }
  }

  /// Add new symptom
  Future<void> addSymptom(String symptom, int severity, String? notes, Map<String, double>? environmentData) async {
    try {
      final newSymptom = SymptomData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symptom: symptom,
        severity: severity,
        timestamp: DateTime.now(),
        notes: notes,
        environmentData: environmentData,
      );

      _symptoms.add(newSymptom);
      await _saveSymptoms();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding symptom: $e');
    }
  }

  /// Remove symptom
  Future<void> removeSymptom(String symptomId) async {
    try {
      _symptoms.removeWhere((s) => s.id == symptomId);
      await _saveSymptoms();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing symptom: $e');
    }
  }

  /// Save medical profile
  Future<void> saveMedicalProfile(MedicalProfile profile) async {
    try {
      _medicalProfile = profile;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('medical_profile', json.encode(profile.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving medical profile: $e');
    }
  }

  /// Save symptoms to local storage
  Future<void> _saveSymptoms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final symptomsJson = json.encode(_symptoms.map((e) => e.toJson()).toList());
      await prefs.setString('symptoms', symptomsJson);
    } catch (e) {
      debugPrint('Error saving symptoms: $e');
    }
  }

  /// Get exercise recommendation
  String getExerciseRecommendation(Map<String, double> currentAirQuality) {
    if (_medicalProfile == null) {
      // Default recommendation without profile
      double co2 = currentAirQuality['co2'] ?? 0;
      double dust = currentAirQuality['dust'] ?? 0;
      double noise = currentAirQuality['noise'] ?? 0;

      if (co2 > 1000 || dust > 35) {
        return '⚠️ OLAHRAGA RINGAN SAJA - Kualitas udara kurang baik';
      }
      if (noise > 70) {
        return '🔇 OLAHRAGA INDOOR - Tingkat kebisingan tinggi';
      }
      return '✅ AMAN UNTUK OLAHRAGA - Kualitas udara baik';
    }

    return _medicalProfile!.getExerciseRecommendation(currentAirQuality);
  }

  /// Check if should trigger allergy alert
  bool shouldTriggerAllergyAlert(Map<String, double> currentAirQuality) {
    if (_medicalProfile == null) return false;
    return _medicalProfile!.shouldTriggerAllergyAlert(currentAirQuality);
  }

  /// Get sleep quality analysis
  String getSleepQualityAnalysis(List<dynamic> nightTimeData) {
    if (nightTimeData.isEmpty) {
      return 'Tidak ada data malam hari untuk analisis tidur';
    }

    double avgCO2 = 0;
    double avgNoise = 0;
    int count = 0;

    for (var data in nightTimeData) {
      if (data is Map<String, dynamic>) {
        avgCO2 += (data['co2'] ?? 0).toDouble();
        avgNoise += (data['noise'] ?? 0).toDouble();
        count++;
      }
    }

    if (count == 0) return 'Data tidak valid untuk analisis tidur';

    avgCO2 /= count;
    avgNoise /= count;

    String analysis = '';
    
    if (avgCO2 > 1000) {
      analysis += '😴 Kualitas tidur mungkin terganggu karena CO₂ tinggi (${avgCO2.toStringAsFixed(0)} ppm). ';
    } else if (avgCO2 < 600) {
      analysis += '😊 Kualitas udara sangat baik untuk tidur (CO₂: ${avgCO2.toStringAsFixed(0)} ppm). ';
    } else {
      analysis += '✅ Kualitas udara cukup baik untuk tidur (CO₂: ${avgCO2.toStringAsFixed(0)} ppm). ';
    }

    if (avgNoise > 40) {
      analysis += '🔊 Tingkat kebisingan cukup tinggi (${avgNoise.toStringAsFixed(0)} dB) yang dapat mengganggu tidur.';
    } else {
      analysis += '🔇 Tingkat kebisingan rendah (${avgNoise.toStringAsFixed(0)} dB) mendukung tidur berkualitas.';
    }

    return analysis;
  }

  /// Generate doctor report
  Map<String, dynamic> generateDoctorReport() {
    return {
      'patient_info': _medicalProfile?.toJson(),
      'health_score': _healthData?.healthScore,
      'health_status': _healthData?.healthStatus,
      'recent_symptoms': _symptoms
          .where((s) => s.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30))))
          .map((s) => s.toJson())
          .toList(),
      'exposure_history': _healthData?.exposureHistory,
      'recommendations': _healthData?.recommendations,
      'generated_at': DateTime.now().toIso8601String(),
    };
  }
}