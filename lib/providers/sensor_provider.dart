import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../repositories/api_repository.dart';

class SensorProvider extends ChangeNotifier {
  static const int _historyWindowLimit = 96; // ~4 hari data
  final ApiRepository _apiRepository;

  // State
  SensorData _currentData = SensorData(
    co2: 0,
    co: 0,
    dust: 0,
    timestamp: DateTime.now(),
  );
  List<SensorData> _historicalData = [];
  int _unreadNotifications = 0;
  bool _isConnected = false;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  // Getters
  SensorData get currentData => _currentData;
  List<SensorData> get historicalData => _historicalData;
  int get unreadNotifications => _unreadNotifications;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor
  SensorProvider({
    ApiRepository? apiRepository,
    bool autoLoad = true,
  }) : _apiRepository = apiRepository ?? ApiRepository() {
    if (autoLoad) {
      loadData();
      startAutoRefresh();
    }
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      refreshLatestData();
      loadUnreadNotificationsCount();
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiRepository.getLatestData(),
        _apiRepository.getHistoricalData(hours: 24),
        _apiRepository.getUnreadNotificationCount(),
      ]);

      final latestData = results[0] as SensorData?;
      final historicalData = results[1] as List<SensorData>;
      final unreadCount = results[2] as int;

      if (latestData != null) {
        _currentData = latestData;
        _isConnected = true;
        _errorMessage = null;
      } else {
        _isConnected = false;
        _errorMessage = 'Tidak dapat mengambil data dari server';
      }

      _historicalData = historicalData;
      _unreadNotifications = unreadCount;
    } catch (e) {
      _isConnected = false;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshLatestData() async {
    try {
      final latestData = await _apiRepository.getLatestData();

      if (latestData != null) {
        _currentData = latestData;
        _isConnected = true;
        _errorMessage = null;
        _mergeLatestIntoHistory(latestData);
      } else {
        _isConnected = false;
        _errorMessage = 'Tidak dapat mengambil data dari server';
      }
    } catch (e) {
      _isConnected = false;
      _errorMessage = 'Error koneksi: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> loadUnreadNotificationsCount() async {
    final count = await _apiRepository.getUnreadNotificationCount();
    _unreadNotifications = count;
    notifyListeners();
  }

  void _mergeLatestIntoHistory(SensorData latestData) {
    final List<SensorData> updatedHistory = List<SensorData>.from(_historicalData);
    final index = updatedHistory.indexWhere(
      (entry) => entry.timestamp.isAtSameMomentAs(latestData.timestamp),
    );

    if (index >= 0) {
      updatedHistory[index] = latestData;
    } else {
      updatedHistory.add(latestData);
      updatedHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      if (updatedHistory.length > _historyWindowLimit) {
        updatedHistory.removeRange(0, updatedHistory.length - _historyWindowLimit);
      }
    }

    _historicalData = updatedHistory;
  }
}
