import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/medical_profile.dart';
import '../models/sensor_data.dart';

class EmergencyService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
  }

  /// Check if current conditions are emergency level
  static bool isEmergencyCondition(SensorData sensorData, MedicalProfile? profile) {
    // Critical thresholds
    bool criticalCO2 = sensorData.co2 > 5000;
    bool criticalCO = sensorData.co > 200;
    bool criticalDust = sensorData.dust > 150;
    
    // Adjusted for medical conditions
    if (profile?.isAsthmatic == true) {
      criticalCO2 = sensorData.co2 > 2000;
      criticalDust = sensorData.dust > 75;
    }
    
    return criticalCO2 || criticalCO || criticalDust;
  }

  /// Trigger emergency alert
  static Future<void> triggerEmergencyAlert(SensorData sensorData, MedicalProfile? profile) async {
    // Send critical notification
    await _sendCriticalNotification(sensorData);
    
    // Auto-call emergency contact if configured
    if (profile != null) {
      final primaryContacts = profile.emergencyContacts
          .where((contact) => contact.isPrimary)
          .toList();
      final primaryContact = primaryContacts.isNotEmpty ? primaryContacts.first : null;
      
      if (primaryContact != null) {
        await _showEmergencyCallDialog(primaryContact);
      }
    }
  }

  static Future<void> _sendCriticalNotification(SensorData sensorData) async {
    const androidDetails = AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Alerts',
      channelDescription: 'Critical air quality alerts',
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.red,
      playSound: true,
      enableVibration: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    String message = '🚨 BAHAYA! Kualitas udara sangat buruk:\n';
    if (sensorData.co2 > 5000) message += 'CO₂: ${sensorData.co2.toStringAsFixed(0)} ppm\n';
    if (sensorData.co > 200) message += 'CO: ${sensorData.co.toStringAsFixed(1)} ppm\n';
    if (sensorData.dust > 150) message += 'Debu: ${sensorData.dust.toStringAsFixed(0)} µg/m³\n';
    message += 'Segera evakuasi area!';
    
    await _notifications.show(
      999, // Emergency notification ID
      'PERINGATAN DARURAT',
      message,
      details,
    );
  }

  static Future<void> _showEmergencyCallDialog(EmergencyContact contact) async {
    // This would be called from UI context
    // Implementation depends on current context
  }

  /// Make emergency call
  static Future<void> makeEmergencyCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  /// Send emergency SMS
  static Future<void> sendEmergencySMS(String phoneNumber, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  /// Generate emergency report
  static Map<String, dynamic> generateEmergencyReport(
    SensorData sensorData,
    MedicalProfile? profile,
    List<String> recentSymptoms,
  ) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'emergency_level': 'CRITICAL',
      'sensor_data': {
        'co2': sensorData.co2,
        'co': sensorData.co,
        'dust': sensorData.dust,
        'noise': sensorData.noise,
      },
      'patient_info': profile?.toJson(),
      'recent_symptoms': recentSymptoms,
      'recommendations': [
        'Segera evakuasi area',
        'Cari udara segar',
        'Hubungi layanan medis darurat',
        'Gunakan masker jika tersedia',
      ],
      'emergency_contacts': profile?.emergencyContacts.map((e) => e.toJson()).toList(),
    };
  }
}