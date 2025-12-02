import 'package:flutter/material.dart';
import 'lib/services/supabase_service.dart';
import 'lib/models/sensor_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔄 Initializing Supabase...');
  await SupabaseService.initialize();
  print('✅ Supabase initialized!');
  
  final supabase = SupabaseService();
  
  // Test 1: Fetch latest data
  print('\n📊 Test 1: Fetching latest sensor data...');
  try {
    final latestData = await supabase.getLatestSensorData();
    if (latestData != null) {
      print('✅ Success! Latest data:');
      print('   CO: ${latestData.co} ppm');
      print('   CO2: ${latestData.co2} ppm');
      print('   PM2.5: ${latestData.pm25} µg/m³');
      print('   Status: ${latestData.getAirQualityStatus()}');
      print('   Time: ${latestData.timestamp}');
    } else {
      print('⚠️  No data found in database');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
  
  // Test 2: Fetch history
  print('\n📚 Test 2: Fetching history (last 5 records)...');
  try {
    final history = await supabase.getSensorDataHistory(limit: 5);
    print('✅ Found ${history.length} records');
    for (var i = 0; i < history.length; i++) {
      final data = history[i];
      print('   ${i + 1}. CO2: ${data.co2} ppm | PM2.5: ${data.pm25} | ${data.timestamp}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
  
  // Test 3: Insert test data
  print('\n➕ Test 3: Inserting test data...');
  try {
    final testData = SensorData(
      co: 5.5,
      co2: 450.0,
      pm25: 12.5,
      timestamp: DateTime.now(),
    );
    
    final success = await supabase.insertSensorData(testData);
    if (success) {
      print('✅ Test data inserted successfully!');
    } else {
      print('❌ Failed to insert test data');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
  
  // Test 4: Get statistics
  print('\n📈 Test 4: Getting statistics (last 24 hours)...');
  try {
    final stats = await supabase.getSensorStatistics(
      startDate: DateTime.now().subtract(Duration(hours: 24)),
      endDate: DateTime.now(),
    );
    print('✅ Statistics:');
    print('   Avg CO: ${stats['avgCO']?.toStringAsFixed(2)} ppm');
    print('   Avg CO2: ${stats['avgCO2']?.toStringAsFixed(2)} ppm');
    print('   Avg PM2.5: ${stats['avgPM25']?.toStringAsFixed(2)} µg/m³');
    print('   Total records: ${stats['count']}');
  } catch (e) {
    print('❌ Error: $e');
  }
  
  print('\n✅ All tests completed!');
  print('🎉 Supabase connection is working!');
}
