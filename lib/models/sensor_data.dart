// Model data untuk menyimpan informasi sensor dari Supabase
class SensorData {
  final int? id; // ID dari database
  final double co; // Kadar CO dalam ppm
  final double co2; // Kadar CO₂ dalam ppm
  final double pm25; // Kadar PM2.5 dalam µg/m³
  final DateTime timestamp; // Waktu pengukuran

  SensorData({
    this.id,
    required this.co,
    required this.co2,
    required this.pm25,
    required this.timestamp,
  });

  // Factory untuk membuat SensorData dari JSON (dari Supabase)
  factory SensorData.fromJson(Map<String, dynamic> json) {
    double _coerceToDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    DateTime parsedTime;
    try {
      if (json['timestamp'] != null) {
        parsedTime = DateTime.parse(json['timestamp'].toString()).toLocal();
      } else {
        parsedTime = DateTime.now();
      }
    } catch (_) {
      parsedTime = DateTime.now();
    }

    return SensorData(
      id: json['id'] as int?,
      co: _coerceToDouble(json['co']),
      co2: _coerceToDouble(json['co2']),
      pm25: _coerceToDouble(json['pm25']),
      timestamp: parsedTime,
    );
  }

  // Convert ke JSON untuk insert ke Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'co': co,
      'co2': co2,
      'pm25': pm25,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Fungsi untuk menentukan kategori CO₂
  String getCO2Category() {
    if (co2 <= 800) {
      return 'BAIK';
    } else if (co2 <= 1000) {
      return 'MASIH AMAN';
    } else if (co2 <= 2000) {
      return 'TIDAK SEHAT';
    } else if (co2 <= 5000) {
      return 'BAHAYA';
    } else {
      return 'SANGAT BERBAHAYA';
    }
  }

  // Fungsi untuk menentukan kategori CO
  String getCOCategory() {
    if (co <= 9) {
      return 'AMAN';
    } else if (co <= 35) {
      return 'TIDAK SEHAT';
    } else if (co <= 200) {
      return 'BERBAHAYA';
    } else if (co <= 800) {
      return 'SANGAT BERBAHAYA';
    } else {
      return 'FATAL';
    }
  }

  // Fungsi untuk menentukan kategori PM2.5
  String getPM25Category() {
    if (pm25 <= 15) {
      return 'BAIK';
    } else if (pm25 <= 35) {
      return 'SEDANG';
    } else if (pm25 <= 55) {
      return 'TIDAK SEHAT';
    } else {
      return 'SANGAT TIDAK SEHAT';
    }
  }

  // Fungsi untuk menentukan status kualitas udara keseluruhan
  String getAirQualityStatus() {
    List<String> categories = [
      getCO2Category(),
      getCOCategory(),
      getPM25Category(),
    ];

    if (categories.contains('FATAL')) {
      return 'FATAL';
    } else if (categories.contains('SANGAT BERBAHAYA') ||
        categories.contains('SANGAT TIDAK SEHAT')) {
      return 'SANGAT BURUK';
    } else if (categories.contains('BAHAYA') ||
        categories.contains('BERBAHAYA')) {
      return 'BAHAYA';
    } else if (categories.contains('TIDAK SEHAT')) {
      return 'TIDAK SEHAT';
    } else if (categories.contains('SEDANG')) {
      return 'SEDANG';
    } else if (categories.contains('MASIH AMAN')) {
      return 'MASIH AMAN';
    } else {
      return 'BAIK';
    }
  }

  // Fungsi untuk mendapatkan warna berdasarkan status
  int getStatusColor() {
    String status = getAirQualityStatus();
    switch (status) {
      case 'FATAL':
        return 0xFF8B0000; // Dark Red
      case 'SANGAT BURUK':
        return 0xFFD32F2F; // Red 700
      case 'BAHAYA':
        return 0xFFFF5252; // Red 400
      case 'TIDAK SEHAT':
        return 0xFFFFA726; // Orange 400
      case 'SEDANG':
        return 0xFFFFCA28; // Amber 400
      case 'MASIH AMAN':
        return 0xFF66BB6A; // Green 400
      case 'BAIK':
        return 0xFF4CAF50; // Green 500
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  // Deskripsi untuk setiap parameter
  String getCO2Description() {
    if (co2 <= 800) {
      return 'Udara sehat, ventilasi bagus';
    } else if (co2 <= 1000) {
      return 'Ventilasi mulai kurang';
    } else if (co2 <= 2000) {
      return 'Pengap, ngantuk, konsentrasi menurun';
    } else if (co2 <= 5000) {
      return 'Sakit kepala, pusing';
    } else {
      return 'Berisiko serius pada kesehatan';
    }
  }

  String getCODescription() {
    if (co <= 9) {
      return 'Aman untuk ruangan';
    } else if (co <= 35) {
      return 'Tidak sehat jika terpapar lama';
    } else if (co <= 200) {
      return 'Berbahaya, pusing, mual';
    } else if (co <= 800) {
      return 'Sangat berbahaya';
    } else {
      return 'Bisa fatal dalam hitungan menit';
    }
  }

  String getPM25Description() {
    if (pm25 <= 15) {
      return 'Kualitas udara baik';
    } else if (pm25 <= 35) {
      return 'Mulai tidak sehat untuk sensitif';
    } else if (pm25 <= 55) {
      return 'Tidak sehat untuk semua';
    } else {
      return 'Sangat tidak sehat';
    }
  }

  // Fungsi untuk mendapatkan rekomendasi
  String getRecommendation() {
    String status = getAirQualityStatus();

    switch (status) {
      case 'FATAL':
      case 'SANGAT BURUK':
        return '⚠️ SEGERA EVAKUASI! Nyalakan exhaust fan maksimal dan buka semua ventilasi!';
      case 'BAHAYA':
        return '⚠️ Nyalakan exhaust fan dan buka jendela segera!';
      case 'TIDAK SEHAT':
        return '⚠️ Tingkatkan ventilasi, nyalakan exhaust fan.';
      case 'SEDANG':
        return 'ℹ️ Pertimbangkan untuk meningkatkan ventilasi.';
      case 'MASIH AMAN':
        return '✓ Ventilasi cukup baik, pantau terus.';
      case 'BAIK':
        return '✓ Kualitas udara sangat baik!';
      default:
        return 'Pantau kualitas udara secara berkala.';
    }
  }

  // Backward compatibility - untuk code yang masih pakai 'dust'
  double get dust => pm25;
  double get airQuality => pm25;
  double get temperature => 0.0; // Placeholder
  double get humidity => 0.0; // Placeholder
}
