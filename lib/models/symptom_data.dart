/// Model untuk tracking gejala kesehatan
class SymptomData {
  final String id;
  final String symptom;
  final int severity; // 1-5 scale
  final DateTime timestamp;
  final String? notes;
  final Map<String, double>? environmentData; // Kondisi udara saat gejala muncul

  SymptomData({
    required this.id,
    required this.symptom,
    required this.severity,
    required this.timestamp,
    this.notes,
    this.environmentData,
  });

  factory SymptomData.fromJson(Map<String, dynamic> json) {
    return SymptomData(
      id: json['id'] ?? '',
      symptom: json['symptom'] ?? '',
      severity: json['severity'] ?? 1,
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
      environmentData: json['environmentData'] != null 
          ? Map<String, double>.from(json['environmentData'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symptom': symptom,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'environmentData': environmentData,
    };
  }

  String getSeverityText() {
    switch (severity) {
      case 1:
        return 'Ringan';
      case 2:
        return 'Ringan-Sedang';
      case 3:
        return 'Sedang';
      case 4:
        return 'Berat';
      case 5:
        return 'Sangat Berat';
      default:
        return 'Tidak Diketahui';
    }
  }

  static List<String> getAvailableSymptoms() {
    return [
      'Batuk',
      'Sesak Napas',
      'Sakit Kepala',
      'Mata Berair',
      'Bersin-bersin',
      'Hidung Tersumbat',
      'Tenggorokan Gatal',
      'Kelelahan',
      'Pusing',
      'Mual',
      'Iritasi Kulit',
      'Sulit Tidur',
    ];
  }
}