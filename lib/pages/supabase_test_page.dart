import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/sensor_data.dart';

class SupabaseTestPage extends StatefulWidget {
  const SupabaseTestPage({super.key});

  @override
  State<SupabaseTestPage> createState() => _SupabaseTestPageState();
}

class _SupabaseTestPageState extends State<SupabaseTestPage> {
  final SupabaseService _supabase = SupabaseService();
  SensorData? _latestData;
  List<SensorData> _history = [];
  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchLatestData();
  }

  Future<void> _fetchLatestData() async {
    setState(() {
      _isLoading = true;
      _message = 'Fetching latest data...';
    });

    try {
      final data = await _supabase.getLatestSensorData();
      setState(() {
        _latestData = data;
        _isLoading = false;
        _message = data != null ? 'Data loaded successfully!' : 'No data found';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error: $e';
      });
    }
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _message = 'Fetching history...';
    });

    try {
      final history = await _supabase.getSensorDataHistory(limit: 10);
      setState(() {
        _history = history;
        _isLoading = false;
        _message = 'Loaded ${history.length} records';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error: $e';
      });
    }
  }

  Future<void> _insertTestData() async {
    setState(() {
      _isLoading = true;
      _message = 'Inserting test data...';
    });

    try {
      final testData = SensorData(
        co: 5.0 + (DateTime.now().second % 10),
        co2: 400.0 + (DateTime.now().second % 200),
        pm25: 10.0 + (DateTime.now().second % 20),
        timestamp: DateTime.now(),
      );

      final success = await _supabase.insertSensorData(testData);
      setState(() {
        _isLoading = false;
        _message = success ? 'Data inserted successfully!' : 'Failed to insert data';
      });

      if (success) {
        _fetchLatestData();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Message
            Card(
              color: _message.contains('Error') ? Colors.red[100] : Colors.green[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('Error') ? Colors.red[900] : Colors.green[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Loading Indicator
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),

            // Latest Data Display
            if (_latestData != null && !_isLoading) ...[
              const Text(
                'Latest Sensor Data:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CO: ${_latestData!.co} ppm'),
                      Text('CO2: ${_latestData!.co2} ppm'),
                      Text('PM2.5: ${_latestData!.pm25} µg/m³'),
                      Text('Status: ${_latestData!.getAirQualityStatus()}'),
                      Text('Time: ${_latestData!.timestamp}'),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchLatestData,
              icon: const Icon(Icons.refresh),
              label: const Text('Fetch Latest Data'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchHistory,
              icon: const Icon(Icons.history),
              label: const Text('Fetch History'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _insertTestData,
              icon: const Icon(Icons.add),
              label: const Text('Insert Test Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            // History List
            if (_history.isNotEmpty) ...[
              const Text(
                'History:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final data = _history[index];
                    return Card(
                      child: ListTile(
                        title: Text('CO: ${data.co} | CO2: ${data.co2}'),
                        subtitle: Text('PM2.5: ${data.pm25} | ${data.getAirQualityStatus()}'),
                        trailing: Text(
                          '${data.timestamp.hour}:${data.timestamp.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
