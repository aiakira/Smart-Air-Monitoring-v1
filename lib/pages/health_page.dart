import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../providers/sensor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/health_widgets.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Update health data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensorProvider = context.read<SensorProvider>();
      final healthProvider = context.read<HealthProvider>();
      
      if (sensorProvider.historicalData.isNotEmpty) {
        healthProvider.updateHealthData(
          sensorProvider.historicalData.map((e) => {
            'co2': e.co2,
            'co': e.co,
            'dust': e.dust,
            'noise': e.noise,
            'timestamp': e.timestamp.toIso8601String(),
          }).toList(),
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kesehatan & Wellness'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Skor'),
            Tab(icon: Icon(Icons.sick), text: 'Gejala'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Aktivitas'),
            Tab(icon: Icon(Icons.bedtime), text: 'Tidur'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHealthScoreTab(),
          _buildSymptomsTab(),
          _buildActivityTab(),
          _buildSleepTab(),
        ],
      ),
    );
  }

  Widget _buildHealthScoreTab() {
    return Consumer2<HealthProvider, SensorProvider>(
      builder: (context, healthProvider, sensorProvider, child) {
        final healthData = healthProvider.healthData;
        
        if (healthProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Health Score Card
              HealthScoreCard(healthData: healthData),
              const SizedBox(height: 16),
              
              // Current Air Quality Impact
              if (sensorProvider.currentData != null)
                AirQualityImpactCard(
                  sensorData: sensorProvider.currentData!,
                  medicalProfile: healthProvider.medicalProfile,
                ),
              const SizedBox(height: 16),
              
              // Recommendations
              if (healthData != null)
                RecommendationsCard(recommendations: healthData.recommendations),
              const SizedBox(height: 16),
              
              // Allergy Alert
              if (healthProvider.medicalProfile != null && sensorProvider.currentData != null)
                AllergyAlertCard(
                  medicalProfile: healthProvider.medicalProfile!,
                  currentAirQuality: {
                    'co2': sensorProvider.currentData!.co2,
                    'co': sensorProvider.currentData!.co,
                    'dust': sensorProvider.currentData!.dust,
                    'noise': sensorProvider.currentData!.noise,
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSymptomsTab() {
    return Consumer2<HealthProvider, SensorProvider>(
      builder: (context, healthProvider, sensorProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Symptom Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddSymptomDialog(context, healthProvider, sensorProvider),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Gejala'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Symptoms List
              SymptomsList(
                symptoms: healthProvider.symptoms,
                onRemoveSymptom: (symptomId) => healthProvider.removeSymptom(symptomId),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTab() {
    return Consumer2<HealthProvider, SensorProvider>(
      builder: (context, healthProvider, sensorProvider, child) {
        if (sensorProvider.currentData == null) {
          return const Center(
            child: Text('Tidak ada data sensor untuk rekomendasi aktivitas'),
          );
        }

        final currentAirQuality = {
          'co2': sensorProvider.currentData!.co2,
          'co': sensorProvider.currentData!.co,
          'dust': sensorProvider.currentData!.dust,
          'noise': sensorProvider.currentData!.noise,
        };

        final exerciseRecommendation = healthProvider.getExerciseRecommendation(currentAirQuality);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Recommendation Card
              ExerciseRecommendationCard(
                recommendation: exerciseRecommendation,
                currentAirQuality: currentAirQuality,
              ),
              const SizedBox(height: 16),
              
              // Activity Guidelines
              const ActivityGuidelinesCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSleepTab() {
    return Consumer2<HealthProvider, SensorProvider>(
      builder: (context, healthProvider, sensorProvider, child) {
        // Get night time data (10 PM to 6 AM)
        final now = DateTime.now();
        final nightStart = DateTime(now.year, now.month, now.day - 1, 22); // 10 PM yesterday
        final nightEnd = DateTime(now.year, now.month, now.day, 6); // 6 AM today
        
        final nightTimeData = sensorProvider.historicalData
            .where((data) => 
                data.timestamp.isAfter(nightStart) && 
                data.timestamp.isBefore(nightEnd))
            .map((e) => {
              'co2': e.co2,
              'co': e.co,
              'dust': e.dust,
              'noise': e.noise,
              'timestamp': e.timestamp.toIso8601String(),
            })
            .toList();

        final sleepAnalysis = healthProvider.getSleepQualityAnalysis(nightTimeData);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sleep Quality Analysis
              SleepQualityCard(
                analysis: sleepAnalysis,
                nightTimeData: nightTimeData,
              ),
              const SizedBox(height: 16),
              
              // Sleep Tips
              const SleepTipsCard(),
            ],
          ),
        );
      },
    );
  }

  void _showAddSymptomDialog(BuildContext context, HealthProvider healthProvider, SensorProvider sensorProvider) {
    showDialog(
      context: context,
      builder: (context) => AddSymptomDialog(
        onAddSymptom: (symptom, severity, notes) {
          final environmentData = sensorProvider.currentData != null ? {
            'co2': sensorProvider.currentData!.co2,
            'co': sensorProvider.currentData!.co,
            'dust': sensorProvider.currentData!.dust,
            'noise': sensorProvider.currentData!.noise,
          } : null;

          healthProvider.addSymptom(symptom, severity, notes, environmentData);
        },
      ),
    );
  }
}