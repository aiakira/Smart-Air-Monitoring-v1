import 'package:flutter/foundation.dart';

class ApiConfig {
  // Konfigurasi URL server - Menggunakan Vercel sebagai backend
  static String get baseUrl {
    // Cek environment variable terlebih dahulu
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Default ke Vercel untuk semua environment
    return 'https://smart-air-monitoring-v2.vercel.app';
  }
  
  // Timeout configuration
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 5);
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}