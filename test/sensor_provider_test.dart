import 'package:flutter_test/flutter_test.dart';
import 'package:smart_air_monitoring_room/models/sensor_data.dart';
import 'package:smart_air_monitoring_room/providers/sensor_provider.dart';
import 'package:smart_air_monitoring_room/repositories/api_repository.dart';

// Mock ApiRepository
class MockApiRepository extends ApiRepository {
  @override
  Future<SensorData?> getLatestData() async {
    return SensorData(
      co2: 500,
      co: 5,
      dust: 10,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<List<SensorData>> getHistoricalData({int hours = 24}) async {
    return [
      SensorData(
        co2: 500,
        co: 5,
        dust: 10,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    return 5;
  }
}

void main() {
  group('SensorProvider Tests', () {
    late SensorProvider provider;
    late MockApiRepository mockRepository;

    setUp(() {
      mockRepository = MockApiRepository();
      // Don't auto load for testing unless specified
      provider = SensorProvider(apiRepository: mockRepository, autoLoad: false);
    });

    tearDown(() {
      provider.dispose();
    });

    test('Initial state should be loading', () {
      expect(provider.isLoading, true);
    });

    test('loadData should populate data', () async {
      await provider.loadData();

      expect(provider.isLoading, false);
      expect(provider.isConnected, true);
      expect(provider.currentData.co2, 500);
      expect(provider.historicalData.length, 1);
      expect(provider.unreadNotifications, 5);
      expect(provider.errorMessage, null);
    });

    test('refreshLatestData should update currentData', () async {
      await provider.refreshLatestData();
      expect(provider.currentData.co2, 500);
      expect(provider.isConnected, true);
    });
  });
}
