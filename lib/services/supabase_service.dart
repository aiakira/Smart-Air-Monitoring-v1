import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/sensor_data.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  // ==================== SENSOR DATA ====================
  
  /// Get latest sensor data
  Future<SensorData?> getLatestSensorData() async {
    try {
      final response = await client
          .from(SupabaseConfig.sensorDataTable)
          .select()
          .order('timestamp', ascending: false)
          .limit(1)
          .single();
      
      return SensorData.fromJson(response);
    } catch (e) {
      print('Error getting latest sensor data: $e');
      return null;
    }
  }

  /// Get sensor data history
  Future<List<SensorData>> getSensorDataHistory({
    int limit = 100,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = client
          .from(SupabaseConfig.sensorDataTable)
          .select()
          .order('timestamp', ascending: false);

      if (startDate != null) {
        query = query.gte('timestamp', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('timestamp', endDate.toIso8601String());
      }

      final response = await query.limit(limit);
      
      return (response as List)
          .map((json) => SensorData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting sensor data history: $e');
      return [];
    }
  }

  /// Insert new sensor data
  Future<bool> insertSensorData(SensorData data) async {
    try {
      await client
          .from(SupabaseConfig.sensorDataTable)
          .insert(data.toJson());
      return true;
    } catch (e) {
      print('Error inserting sensor data: $e');
      return false;
    }
  }

  /// Stream sensor data (real-time updates)
  Stream<SensorData?> streamSensorData() {
    return client
        .from(SupabaseConfig.sensorDataTable)
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false)
        .limit(1)
        .map((data) {
          if (data.isEmpty) return null;
          return SensorData.fromJson(data.first);
        });
  }

  /// Get sensor statistics for a date range
  Future<Map<String, dynamic>> getSensorStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await client
          .from(SupabaseConfig.sensorDataTable)
          .select()
          .gte('timestamp', startDate.toIso8601String())
          .lte('timestamp', endDate.toIso8601String());

      final data = response as List;
      
      if (data.isEmpty) {
        return {
          'avgCO': 0.0,
          'avgCO2': 0.0,
          'avgPM25': 0.0,
          'count': 0,
        };
      }

      double totalCO = 0;
      double totalCO2 = 0;
      double totalPM25 = 0;

      for (var item in data) {
        totalCO += item['co'] ?? 0;
        totalCO2 += item['co2'] ?? 0;
        totalPM25 += item['pm25'] ?? 0;
      }

      return {
        'avgCO': totalCO / data.length,
        'avgCO2': totalCO2 / data.length,
        'avgPM25': totalPM25 / data.length,
        'count': data.length,
      };
    } catch (e) {
      print('Error getting sensor statistics: $e');
      return {
        'avgCO': 0.0,
        'avgCO2': 0.0,
        'avgPM25': 0.0,
        'count': 0,
      };
    }
  }

  /// Get data for specific time range (untuk chart)
  Future<List<SensorData>> getDataForChart({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  }) async {
    try {
      var query = client
          .from(SupabaseConfig.sensorDataTable)
          .select()
          .gte('timestamp', startDate.toIso8601String())
          .lte('timestamp', endDate.toIso8601String())
          .order('timestamp', ascending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      
      return (response as List)
          .map((json) => SensorData.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting chart data: $e');
      return [];
    }
  }

  /// Delete old data (untuk maintenance)
  Future<bool> deleteOldData({required DateTime beforeDate}) async {
    try {
      await client
          .from(SupabaseConfig.sensorDataTable)
          .delete()
          .lt('timestamp', beforeDate.toIso8601String());
      return true;
    } catch (e) {
      print('Error deleting old data: $e');
      return false;
    }
  }
}
