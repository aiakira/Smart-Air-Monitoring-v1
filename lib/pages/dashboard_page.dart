import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_widgets.dart';
import 'notifications_page.dart';
import 'medical_profile_page.dart';
import '../services/emergency_service.dart';
import '../providers/health_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Medical Profile Button
          IconButton(
            icon: const Icon(Icons.medical_services),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicalProfilePage(),
                ),
              );
            },
            tooltip: 'Profil Medis',
          ),
          
          // Emergency Button
          Consumer2<SensorProvider, HealthProvider>(
            builder: (context, sensorProvider, healthProvider, child) {
              final isEmergency = sensorProvider.currentData != null &&
                  EmergencyService.isEmergencyCondition(
                    sensorProvider.currentData!,
                    healthProvider.medicalProfile,
                  );
              
              return IconButton(
                icon: Icon(
                  Icons.emergency,
                  color: isEmergency ? Colors.red : Colors.white,
                ),
                onPressed: isEmergency
                    ? () => _handleEmergency(sensorProvider.currentData!, healthProvider.medicalProfile)
                    : null,
                tooltip: isEmergency ? 'DARURAT!' : 'Tidak ada darurat',
              );
            },
          ),
          
          // Notification Icon
          Consumer<SensorProvider>(
            builder: (context, provider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      ).then((_) {
                        context.read<SensorProvider>().loadUnreadNotificationsCount();
                      });
                    },
                  ),
                  if (provider.unreadNotifications > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${provider.unreadNotifications}',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<SensorProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(
                    currentData: provider.currentData,
                    isConnected: provider.isConnected,
                    errorMessage: provider.errorMessage,
                    isLoading: provider.isLoading,
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  if (!provider.isLoading && provider.errorMessage == null)
                    SensorGrid(currentData: provider.currentData),
                  const SizedBox(height: AppTheme.spacingLarge),
                  if (!provider.isLoading && provider.errorMessage == null)
                    ChartSection(
                      historicalData: provider.historicalData,
                      isLoading: provider.isLoading,
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleEmergency(SensorData sensorData, MedicalProfile? profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade700, size: 32),
            const SizedBox(width: 8),
            Text(
              'PERINGATAN DARURAT!',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kualitas udara sangat berbahaya:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (sensorData.co2 > 5000)
              Text('• CO₂: ${sensorData.co2.toStringAsFixed(0)} ppm (BAHAYA!)'),
            if (sensorData.co > 200)
              Text('• CO: ${sensorData.co.toStringAsFixed(1)} ppm (BAHAYA!)'),
            if (sensorData.dust > 150)
              Text('• Debu: ${sensorData.dust.toStringAsFixed(0)} µg/m³ (BAHAYA!)'),
            const SizedBox(height: 16),
            const Text(
              'SEGERA:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const Text('• Evakuasi area'),
            const Text('• Cari udara segar'),
            const Text('• Nyalakan ventilasi maksimal'),
            if (profile?.isAsthmatic == true)
              const Text('• Siapkan inhaler', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (profile?.emergencyContacts.isNotEmpty == true)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _callEmergencyContact(profile!.emergencyContacts.first);
              },
              icon: const Icon(Icons.call),
              label: const Text('Hubungi Darurat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );

    // Trigger emergency service
    EmergencyService.triggerEmergencyAlert(sensorData, profile);
  }

  void _callEmergencyContact(EmergencyContact contact) {
    EmergencyService.makeEmergencyCall(contact.phoneNumber);
  }
}
