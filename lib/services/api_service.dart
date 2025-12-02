import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';
import '../models/notification_item.dart';
import '../models/sensor_statistics.dart';
import '../config/api_config.dart';
import 'vercel_adapter.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  static Map<String, String> get headers => ApiConfig.headers;
  static const Duration _defaultTimeout = Duration(seconds: 10);

  static Future<SensorData?> getLatestData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/sensor/latest'), headers: headers)
          .timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (VercelAdapter.isValidResponse(jsonData, response.statusCode)) {
          return VercelAdapter.parseLatestData(jsonData);
        }
        debugPrint('API Error: format data tidak valid - ${response.body}');
        return null;
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getLatestData: $e');
      return null;
    }
  }

  static Future<List<SensorData>> getHistoricalData({int hours = 24}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/sensor/history?limit=$hours'),
            headers: headers,
          )
          .timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return VercelAdapter.parseHistoryData(jsonData);
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error getHistoricalData: $e');
      return [];
    }
  }

  // Statistik tidak tersedia di Vercel API
  static Future<SensorStatistics?> getSensorStatistics({int hours = 24}) async {
    return null;
  }

  static Future<bool> testConnection() async {
    try {
      // Test dengan endpoint yang ada di Vercel
      final response = await http
          .get(Uri.parse('$baseUrl/api/sensor/latest'), headers: headers)
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error testConnection: $e');
      return false;
    }
  }

  // Notifikasi tidak tersedia di Vercel API
  static Future<List<NotificationItem>> getNotifications({
    int limit = 30,
    bool unreadOnly = false,
  }) async {
    return []; // Return empty list
  }

  static Future<int> getUnreadNotificationCount() async {
    // Vercel belum punya endpoint notifikasi, return 0
    // TODO: Implementasi endpoint notifikasi di Vercel jika diperlukan
    return 0;
  }

  // Notifikasi tidak tersedia di Vercel API
  static Future<bool> markNotificationAsRead(int id) async {
    return false;
  }

  // Notifikasi tidak tersedia di Vercel API
  static Future<bool> deleteNotification(int id) async {
    return false;
  }

  // Notifikasi tidak tersedia di Vercel API
  static Future<bool> clearNotifications() async {
    return false;
  }
}
