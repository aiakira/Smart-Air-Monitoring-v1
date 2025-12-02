/// Model untuk profil medis pengguna
class MedicalProfile {
  final String userId;
  final String name;
  final int age;
  final String gender;
  final List<String> allergies;
  final List<String> medicalConditions;
  final List<MedicationReminder> medications;
  final List<EmergencyContact> emergencyContacts;
  final Map<String, double> personalThresholds; // Custom threshold per sensor
  final bool isAsthmatic;
  final bool isSmoker;
  final String activityLevel; // LOW, MODERATE, HIGH

  MedicalProfile({
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.allergies,
    required this.medicalConditions,
    required this.medications,
    required this.emergencyContacts,
    required this.personalThresholds,
    required this.isAsthmatic,
    required this.isSmoker,
    required this.activityLevel,
  });

  factory MedicalProfile.fromJson(Map<String, dynamic> json) {
    return MedicalProfile(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      allergies: List<String>.from(json['allergies'] ?? []),
      medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
      medications: (json['medications'] as List<dynamic>?)
          ?.map((e) => MedicationReminder.fromJson(e))
          .toList() ?? [],
      emergencyContacts: (json['emergencyContacts'] as List<dynamic>?)
          ?.map((e) => EmergencyContact.fromJson(e))
          .toList() ?? [],
      personalThresholds: Map<String, double>.from(json['personalThresholds'] ?? {}),
      isAsthmatic: json['isAsthmatic'] ?? false,
      isSmoker: json['isSmoker'] ?? false,
      activityLevel: json['activityLevel'] ?? 'MODERATE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'age': age,
      'gender': gender,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'medications': medications.map((e) => e.toJson()).toList(),
      'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
      'personalThresholds': personalThresholds,
      'isAsthmatic': isAsthmatic,
      'isSmoker': isSmoker,
      'activityLevel': activityLevel,
    };
  }

  /// Get exercise recommendation based on air quality and health profile
  String getExerciseRecommendation(Map<String, double> currentAirQuality) {
    double co2 = currentAirQuality['co2'] ?? 0;
    double co = currentAirQuality['co'] ?? 0;
    double dust = currentAirQuality['dust'] ?? 0;
    double noise = currentAirQuality['noise'] ?? 0;

    // Adjust thresholds based on health conditions
    double co2Threshold = personalThresholds['co2'] ?? (isAsthmatic ? 800 : 1000);
    double dustThreshold = personalThresholds['dust'] ?? (isAsthmatic ? 25 : 35);

    if (co2 > co2Threshold || dust > dustThreshold || co > 35) {
      if (isAsthmatic) {
        return '🚫 TIDAK DISARANKAN - Kualitas udara buruk untuk penderita asma';
      }
      return '⚠️ OLAHRAGA RINGAN SAJA - Kualitas udara kurang baik';
    }

    if (noise > 70) {
      return '🔇 OLAHRAGA INDOOR - Tingkat kebisingan tinggi';
    }

    switch (activityLevel) {
      case 'HIGH':
        return '💪 AMAN UNTUK OLAHRAGA INTENSIF - Kualitas udara baik';
      case 'MODERATE':
        return '🚶 AMAN UNTUK OLAHRAGA SEDANG - Kualitas udara baik';
      case 'LOW':
        return '🧘 AMAN UNTUK AKTIVITAS RINGAN - Kualitas udara baik';
      default:
        return '✅ AMAN UNTUK OLAHRAGA - Kualitas udara baik';
    }
  }

  /// Check if current conditions trigger allergy alert
  bool shouldTriggerAllergyAlert(Map<String, double> currentAirQuality) {
    if (!allergies.contains('Debu') && !allergies.contains('Polusi Udara')) {
      return false;
    }

    double dust = currentAirQuality['dust'] ?? 0;
    double co2 = currentAirQuality['co2'] ?? 0;

    // Lower thresholds for allergy sufferers
    return dust > 25 || co2 > 800;
  }
}

/// Model untuk pengingat obat
class MedicationReminder {
  final String id;
  final String medicationName;
  final String dosage;
  final List<String> times; // ["08:00", "20:00"]
  final String frequency; // DAILY, WEEKLY, AS_NEEDED
  final bool isActive;
  final String? notes;

  MedicationReminder({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.times,
    required this.frequency,
    required this.isActive,
    this.notes,
  });

  factory MedicationReminder.fromJson(Map<String, dynamic> json) {
    return MedicationReminder(
      id: json['id'] ?? '',
      medicationName: json['medicationName'] ?? '',
      dosage: json['dosage'] ?? '',
      times: List<String>.from(json['times'] ?? []),
      frequency: json['frequency'] ?? 'DAILY',
      isActive: json['isActive'] ?? true,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationName': medicationName,
      'dosage': dosage,
      'times': times,
      'frequency': frequency,
      'isActive': isActive,
      'notes': notes,
    };
  }
}

/// Model untuk kontak darurat
class EmergencyContact {
  final String id;
  final String name;
  final String relationship;
  final String phoneNumber;
  final String? email;
  final bool isPrimary;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email,
    required this.isPrimary,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      isPrimary: json['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'email': email,
      'isPrimary': isPrimary,
    };
  }
}