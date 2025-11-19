import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class ApiService {
  // Ganti dengan URL Backend API Anda
  // Untuk testing lokal di emulator Android: 'http://10.0.2.2:3000'
  // Untuk testing lokal di HP (jaringan sama): 'http://192.168.X.X:3000' (ganti dengan IP PC)
  // Untuk production: 'https://your-api-domain.com'
  static const String baseUrl = 'http://10.0.2.2:3000';

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<SensorData?> getLatestData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/data/terbaru'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SensorData(
          co2: (jsonData['co2'] ?? 0).toDouble(),
          co: (jsonData['co'] ?? 0).toDouble(),
          dust: (jsonData['debu'] ?? 0).toDouble(),
          timestamp: DateTime.parse(jsonData['waktu']),
        );
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getLatestData: $e');
      return null;
    }
  }

  static Future<List<SensorData>> getHistoricalData({
    int hours = 24,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/data/historis?hours=$hours'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['data'] ?? [];

        return dataList.map((item) {
          return SensorData(
            co2: (item['co2'] ?? 0).toDouble(),
            co: (item['co'] ?? 0).toDouble(),
            dust: (item['debu'] ?? 0).toDouble(),
            timestamp: DateTime.parse(item['waktu']),
          );
        }).toList();
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error getHistoricalData: $e');
      return [];
    }
  }


  static Future<Map<String, dynamic>?> getControlStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/kontrol/status'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getControlStatus: $e');
      return null;
    }
  }

  static Future<bool> sendControlCommand({
    String? fan, // "ON" atau "OFF"
    String? mode, // "AUTO" atau "MANUAL"
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fan != null) body['fan'] = fan;
      if (mode != null) body['mode'] = mode;

      final response = await http.post(
        Uri.parse('$baseUrl/api/kontrol'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sendControlCommand: $e');
      return false;
    }
  }

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error testConnection: $e');
      return false;
    }
  }
}

