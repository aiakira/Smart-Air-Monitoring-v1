import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../services/supabase_service.dart';

class SupabaseSensorProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  SensorData? _latestData;
  List<SensorData> _history = [];
  bool _isLoading = false;
  String? _error;

  SensorData? get latestData => _latestData;
  List<SensorData> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch latest sensor data from Supabase
  Future<void> fetchLatestData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _latestData = await _supabaseService.getLatestSensorData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch sensor data history
  Future<void> fetchHistory({int limit = 100}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _history = await _supabaseService.getSensorDataHistory(limit: limit);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Listen to real-time sensor data updates
  void listenToSensorData() {
    _supabaseService.streamSensorData().listen(
      (data) {
        if (data != null) {
          _latestData = data;
          notifyListeners();
        }
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  /// Insert new sensor data
  Future<bool> insertSensorData(SensorData data) async {
    try {
      final success = await _supabaseService.insertSensorData(data);
      if (success) {
        await fetchLatestData();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get statistics for date range
  Future<Map<String, dynamic>> getStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _supabaseService.getSensorStatistics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }
}
