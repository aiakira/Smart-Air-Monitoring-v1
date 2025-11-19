// Model data untuk menyimpan informasi sensor
class SensorData {
  final double co2; // Kadar CO₂ dalam ppm
  final double co; // Kadar CO dalam ppm
  final double dust; // Kadar debu dalam µg/m³
  final DateTime timestamp; // Waktu pengukuran

  SensorData({
    required this.co2,
    required this.co,
    required this.dust,
    required this.timestamp,
  });

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

  // Fungsi untuk menentukan kategori Debu (PM2.5)
  String getDustCategory() {
    if (dust <= 15) {
      return 'BAIK';
    } else if (dust <= 35) {
      return 'SEDANG';
    } else if (dust <= 55) {
      return 'TIDAK SEHAT';
    } else {
      return 'SANGAT TIDAK SEHAT';
    }
  }

  // Fungsi untuk menentukan status kualitas udara keseluruhan
  String getAirQualityStatus() {
    // Ambil kategori terburuk dari ketiga sensor
    List<String> categories = [
      getCO2Category(),
      getCOCategory(),
      getDustCategory(),
    ];

    // Prioritas: FATAL > SANGAT BERBAHAYA > BAHAYA > TIDAK SEHAT > SEDANG > MASIH AMAN > AMAN > BAIK
    if (categories.contains('FATAL')) {
      return 'FATAL';
    } else if (categories.contains('SANGAT BERBAHAYA') || categories.contains('SANGAT TIDAK SEHAT')) {
      return 'SANGAT BURUK';
    } else if (categories.contains('BAHAYA') || categories.contains('BERBAHAYA')) {
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

  // Fungsi untuk mendapatkan keterangan detail
  String getDetailedDescription() {
    String co2Desc = _getCO2Description();
    String coDesc = _getCODescription();
    String dustDesc = _getDustDescription();
    
    return 'CO₂: $co2Desc\nCO: $coDesc\nDebu: $dustDesc';
  }

  String _getCO2Description() {
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

  String _getCODescription() {
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

  String _getDustDescription() {
    if (dust <= 15) {
      return 'Kualitas udara baik';
    } else if (dust <= 35) {
      return 'Mulai tidak sehat untuk sensitif';
    } else if (dust <= 55) {
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
}

// Model untuk notifikasi
class NotificationItem {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

