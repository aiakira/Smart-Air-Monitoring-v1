import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';
import '../models/medical_profile.dart';
import '../models/sensor_data.dart';

class MedicationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
    
    // Initialize timezone
    try {
      tz.initializeTimeZones();
    } catch (e) {
      // Timezone already initialized or error
      print('Timezone initialization: $e');
    }
  }

  /// Schedule medication reminders
  static Future<void> scheduleMedicationReminders(List<MedicationReminder> medications) async {
    // Cancel existing reminders
    await _notifications.cancelAll();
    
    for (var medication in medications) {
      if (!medication.isActive) continue;
      
      for (int i = 0; i < medication.times.length; i++) {
        final time = medication.times[i];
        final timeParts = time.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        
        await _scheduleNotification(
          medication.id.hashCode + i,
          'Waktu Minum Obat',
          '💊 ${medication.medicationName} - ${medication.dosage}',
          hour,
          minute,
          medication.notes,
        );
      }
    }
  }

  static Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    int hour,
    int minute,
    String? notes,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'medication_channel',
      'Medication Reminders',
      channelDescription: 'Reminders for taking medication',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.blue,
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
    
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    String fullBody = body;
    if (notes != null && notes.isNotEmpty) {
      fullBody += '\n📝 $notes';
    }
    
    await _notifications.zonedSchedule(
      id,
      title,
      fullBody,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Check if medication should be taken based on air quality
  static bool shouldTakeMedicationEarly(
    MedicationReminder medication,
    SensorData currentData,
    MedicalProfile profile,
  ) {
    // For asthma medication during poor air quality
    if (profile.isAsthmatic && 
        medication.medicationName.toLowerCase().contains('inhaler') ||
        medication.medicationName.toLowerCase().contains('ventolin')) {
      
      return currentData.co2 > 1500 || 
             currentData.dust > 50 ||
             currentData.co > 25;
    }
    
    // For allergy medication during high dust
    if (profile.allergies.contains('Debu') &&
        medication.medicationName.toLowerCase().contains('antihistamin')) {
      
      return currentData.dust > 35;
    }
    
    return false;
  }

  /// Send early medication alert
  static Future<void> sendEarlyMedicationAlert(
    MedicationReminder medication,
    String reason,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'early_medication_channel',
      'Early Medication Alerts',
      channelDescription: 'Alerts for taking medication early due to air quality',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.orange,
      playSound: true,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _notifications.show(
      medication.id.hashCode + 1000,
      'Pertimbangkan Minum Obat Lebih Awal',
      '⚠️ ${medication.medicationName}\n$reason',
      details,
    );
  }

  /// Log medication taken
  static Future<void> logMedicationTaken(String medicationId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'medication_log_$today';
    
    List<String> takenMedications = prefs.getStringList(key) ?? [];
    if (!takenMedications.contains(medicationId)) {
      takenMedications.add(medicationId);
      await prefs.setStringList(key, takenMedications);
    }
  }

  /// Get medication adherence
  static Future<double> getMedicationAdherence(String medicationId, int days) async {
    final prefs = await SharedPreferences.getInstance();
    int takenDays = 0;
    
    for (int i = 0; i < days; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      final key = 'medication_log_$dateStr';
      
      List<String> takenMedications = prefs.getStringList(key) ?? [];
      if (takenMedications.contains(medicationId)) {
        takenDays++;
      }
    }
    
    return takenDays / days;
  }
}