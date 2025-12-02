import 'package:flutter/material.dart';
import '../models/health_data.dart';
import '../models/symptom_data.dart';
import '../models/medical_profile.dart';
import '../models/sensor_data.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Widget untuk menampilkan skor kesehatan
class HealthScoreCard extends StatelessWidget {
  final HealthData? healthData;

  const HealthScoreCard({super.key, this.healthData});

  @override
  Widget build(BuildContext context) {
    if (healthData == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.health_and_safety, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Skor Kesehatan Belum Tersedia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan data gejala dan tunggu data sensor untuk mendapatkan skor kesehatan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Health Score Circle
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: healthData!.healthScore / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          healthData!.getHealthColor(),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${healthData!.healthScore}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: healthData!.getHealthColor(),
                          ),
                        ),
                        const Text(
                          'SKOR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Health Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: healthData!.getHealthColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                healthData!.healthStatus,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: healthData!.getHealthColor(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Health Description
            Text(
              healthData!.getHealthDescription(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // Last Updated
            Text(
              'Terakhir diperbarui: ${DateFormat('dd/MM/yyyy HH:mm').format(healthData!.lastUpdated)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan dampak kualitas udara terhadap kesehatan
class AirQualityImpactCard extends StatelessWidget {
  final SensorData sensorData;
  final MedicalProfile? medicalProfile;

  const AirQualityImpactCard({
    super.key,
    required this.sensorData,
    this.medicalProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.air, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'Dampak Kualitas Udara Saat Ini',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sensor Impact Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildImpactTile('CO₂', '${sensorData.co2.toStringAsFixed(0)} ppm', 
                    sensorData.getCO2Description(), sensorData.getCO2Category()),
                _buildImpactTile('CO', '${sensorData.co.toStringAsFixed(1)} ppm', 
                    sensorData.getCODescription(), sensorData.getCOCategory()),
                _buildImpactTile('Debu', '${sensorData.dust.toStringAsFixed(0)} µg/m³', 
                    sensorData.getDustDescription(), sensorData.getDustCategory()),
                _buildImpactTile('Kebisingan', '${sensorData.noise.toStringAsFixed(0)} dB', 
                    sensorData.getNoiseDescription(), sensorData.getNoiseCategory()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactTile(String label, String value, String description, String category) {
    Color color = _getCategoryColor(category);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getNoiseDescription(double noise) {
    if (noise <= 0) return 'Data tidak tersedia';
    if (noise <= 30) return 'Sangat tenang, ideal untuk tidur';
    if (noise <= 40) return 'Tenang, nyaman untuk aktivitas';
    if (noise <= 55) return 'Normal, tidak mengganggu';
    if (noise <= 70) return 'Mulai bising, dapat mengganggu';
    if (noise <= 85) return 'Sangat bising, mengganggu konsentrasi';
    return 'Berbahaya untuk pendengaran';
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'BAIK':
      case 'AMAN':
      case 'EXCELLENT':
      case 'SANGAT TENANG':
      case 'TENANG':
        return AppTheme.healthExcellent;
      case 'MASIH AMAN':
      case 'SEDANG':
      case 'NORMAL':
        return AppTheme.healthGood;
      case 'TIDAK SEHAT':
      case 'BISING':
        return AppTheme.healthFair;
      case 'BAHAYA':
      case 'BERBAHAYA':
      case 'SANGAT BISING':
        return AppTheme.healthPoor;
      case 'SANGAT BERBAHAYA':
      case 'FATAL':
      case 'SANGAT TIDAK SEHAT':
      case 'BERBAHAYA':
        return AppTheme.healthDangerous;
      default:
        return Colors.grey;
    }
  }
}

/// Widget untuk menampilkan rekomendasi kesehatan
class RecommendationsCard extends StatelessWidget {
  final List<String> recommendations;

  const RecommendationsCard({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'Rekomendasi Kesehatan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk alert alergi
class AllergyAlertCard extends StatelessWidget {
  final MedicalProfile medicalProfile;
  final Map<String, double> currentAirQuality;

  const AllergyAlertCard({
    super.key,
    required this.medicalProfile,
    required this.currentAirQuality,
  });

  @override
  Widget build(BuildContext context) {
    if (!medicalProfile.shouldTriggerAllergyAlert(currentAirQuality)) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Peringatan Alergi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Kualitas udara saat ini dapat memicu alergi Anda (${medicalProfile.allergies.join(', ')}). '
              'Pertimbangkan untuk menggunakan masker atau menghindari aktivitas outdoor.',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk daftar gejala
class SymptomsList extends StatelessWidget {
  final List<SymptomData> symptoms;
  final Function(String) onRemoveSymptom;

  const SymptomsList({
    super.key,
    required this.symptoms,
    required this.onRemoveSymptom,
  });

  @override
  Widget build(BuildContext context) {
    if (symptoms.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.sick, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Gejala Tercatat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Catat gejala yang Anda alami untuk tracking kesehatan yang lebih baik',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    // Group symptoms by date
    Map<String, List<SymptomData>> groupedSymptoms = {};
    for (var symptom in symptoms) {
      String dateKey = DateFormat('yyyy-MM-dd').format(symptom.timestamp);
      groupedSymptoms[dateKey] ??= [];
      groupedSymptoms[dateKey]!.add(symptom);
    }

    // Sort dates descending
    var sortedDates = groupedSymptoms.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      children: sortedDates.map((date) {
        final dateSymptoms = groupedSymptoms[date]!;
        final formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.parse(date));
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ...dateSymptoms.map((symptom) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getSeverityColor(symptom.severity).withOpacity(0.2),
                  child: Icon(
                    Icons.sick,
                    color: _getSeverityColor(symptom.severity),
                  ),
                ),
                title: Text(symptom.symptom),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tingkat: ${symptom.getSeverityText()}'),
                    if (symptom.notes != null && symptom.notes!.isNotEmpty)
                      Text('Catatan: ${symptom.notes}'),
                    Text('Waktu: ${DateFormat('HH:mm').format(symptom.timestamp)}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemoveSymptom(symptom.id),
                ),
              )),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Dialog untuk menambah gejala
class AddSymptomDialog extends StatefulWidget {
  final Function(String, int, String?) onAddSymptom;

  const AddSymptomDialog({super.key, required this.onAddSymptom});

  @override
  State<AddSymptomDialog> createState() => _AddSymptomDialogState();
}

class _AddSymptomDialogState extends State<AddSymptomDialog> {
  String? selectedSymptom;
  int severity = 1;
  final TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Gejala'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Symptom Dropdown
            DropdownButtonFormField<String>(
              value: selectedSymptom,
              decoration: const InputDecoration(
                labelText: 'Pilih Gejala',
                border: OutlineInputBorder(),
              ),
              items: SymptomData.getAvailableSymptoms().map((symptom) {
                return DropdownMenuItem(
                  value: symptom,
                  child: Text(symptom),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSymptom = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Severity Slider
            Text('Tingkat Keparahan: ${_getSeverityText(severity)}'),
            Slider(
              value: severity.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _getSeverityText(severity),
              onChanged: (value) {
                setState(() {
                  severity = value.toInt();
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Notes
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: selectedSymptom != null ? () {
            widget.onAddSymptom(
              selectedSymptom!,
              severity,
              notesController.text.isEmpty ? null : notesController.text,
            );
            Navigator.pop(context);
          } : null,
          child: const Text('Tambah'),
        ),
      ],
    );
  }

  String _getSeverityText(int severity) {
    switch (severity) {
      case 1: return 'Ringan';
      case 2: return 'Ringan-Sedang';
      case 3: return 'Sedang';
      case 4: return 'Berat';
      case 5: return 'Sangat Berat';
      default: return 'Tidak Diketahui';
    }
  }
}

/// Widget untuk rekomendasi olahraga
class ExerciseRecommendationCard extends StatelessWidget {
  final String recommendation;
  final Map<String, double> currentAirQuality;

  const ExerciseRecommendationCard({
    super.key,
    required this.recommendation,
    required this.currentAirQuality,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'Rekomendasi Aktivitas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getRecommendationColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getRecommendationColor().withOpacity(0.3)),
              ),
              child: Text(
                recommendation,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _getRecommendationColor(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Current conditions
            Text(
              'Kondisi Saat Ini:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildConditionItem('CO₂', '${currentAirQuality['co2']?.toStringAsFixed(0)} ppm'),
                _buildConditionItem('Debu', '${currentAirQuality['dust']?.toStringAsFixed(0)} µg/m³'),
                _buildConditionItem('Kebisingan', '${currentAirQuality['noise']?.toStringAsFixed(0)} dB'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getRecommendationColor() {
    if (recommendation.contains('TIDAK DISARANKAN') || recommendation.contains('🚫')) {
      return Colors.red;
    } else if (recommendation.contains('RINGAN SAJA') || recommendation.contains('⚠️')) {
      return Colors.orange;
    } else if (recommendation.contains('INDOOR') || recommendation.contains('🔇')) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }
}

/// Widget untuk panduan aktivitas
class ActivityGuidelinesCard extends StatelessWidget {
  const ActivityGuidelinesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'Panduan Aktivitas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildGuidelineItem(
              '🟢 Kualitas Udara Baik',
              'Aman untuk semua aktivitas termasuk olahraga intensif outdoor',
            ),
            _buildGuidelineItem(
              '🟡 Kualitas Udara Sedang',
              'Olahraga ringan hingga sedang, hindari aktivitas intensif outdoor',
            ),
            _buildGuidelineItem(
              '🟠 Kualitas Udara Buruk',
              'Batasi aktivitas outdoor, pilih olahraga indoor',
            ),
            _buildGuidelineItem(
              '🔴 Kualitas Udara Sangat Buruk',
              'Hindari aktivitas outdoor, istirahat di dalam ruangan',
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 Tips: Penderita asma dan alergi sebaiknya lebih berhati-hati dan menggunakan threshold yang lebih rendah.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

/// Widget untuk analisis kualitas tidur
class SleepQualityCard extends StatelessWidget {
  final String analysis;
  final List<dynamic> nightTimeData;

  const SleepQualityCard({
    super.key,
    required this.analysis,
    required this.nightTimeData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bedtime, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'Analisis Kualitas Tidur',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                analysis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            
            if (nightTimeData.isNotEmpty) ...[
              Text(
                'Data Malam Hari (${nightTimeData.length} pembacaan):',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildNightDataSummary(),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tidak ada data malam hari untuk analisis. Data akan tersedia setelah sensor berjalan selama satu malam.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNightDataSummary() {
    if (nightTimeData.isEmpty) return const SizedBox.shrink();

    double avgCO2 = 0;
    double avgNoise = 0;
    int count = 0;

    for (var data in nightTimeData) {
      if (data is Map<String, dynamic>) {
        avgCO2 += (data['co2'] ?? 0).toDouble();
        avgNoise += (data['noise'] ?? 0).toDouble();
        count++;
      }
    }

    if (count == 0) return const SizedBox.shrink();

    avgCO2 /= count;
    avgNoise /= count;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNightStat('Rata-rata CO₂', '${avgCO2.toStringAsFixed(0)} ppm'),
        _buildNightStat('Rata-rata Kebisingan', '${avgNoise.toStringAsFixed(0)} dB'),
        _buildNightStat('Jumlah Data', '$count'),
      ],
    );
  }

  Widget _buildNightStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Widget untuk tips tidur
class SleepTipsCard extends StatelessWidget {
  const SleepTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'Tips Tidur Berkualitas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildTipItem('🌡️', 'Suhu Ideal', 'Jaga suhu ruangan 18-22°C untuk tidur optimal'),
            _buildTipItem('💨', 'Ventilasi', 'Pastikan sirkulasi udara baik, CO₂ < 1000 ppm'),
            _buildTipItem('🔇', 'Kebisingan', 'Tingkat kebisingan < 40 dB untuk tidur nyenyak'),
            _buildTipItem('🌱', 'Tanaman', 'Tanaman seperti lidah mertua dapat membantu membersihkan udara'),
            _buildTipItem('📱', 'Gadget', 'Matikan gadget 1 jam sebelum tidur'),
            _buildTipItem('⏰', 'Jadwal', 'Tidur dan bangun di waktu yang sama setiap hari'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}