import '../models/sensor_data.dart';
import '../models/notification_item.dart';
import '../services/api_service.dart';

class ApiRepository {
  Future<SensorData?> getLatestData() {
    return ApiService.getLatestData();
  }

  Future<List<SensorData>> getHistoricalData({int hours = 24}) {
    return ApiService.getHistoricalData(hours: hours);
  }

  Future<int> getUnreadNotificationCount() {
    return ApiService.getUnreadNotificationCount();
  }
}
