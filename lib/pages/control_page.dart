import 'package:flutter/material.dart';

// Halaman Kontrol - untuk mengatur Fan dan Mode Operasi
class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  // Status exhaust fan (On/Off)
  bool _fanStatus = false;

  // Mode operasi (Auto/Manual)
  bool _isAutoMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrol'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kontrol Exhaust Fan
            _buildSectionTitle('Kontrol Exhaust Fan'),
            const SizedBox(height: 12),
            _buildFanControlCard(),
            const SizedBox(height: 32),

            // Mode Operasi
            _buildSectionTitle('Mode Operasi'),
            const SizedBox(height: 12),
            _buildModeControlCard(),
            const SizedBox(height: 32),

            // Informasi
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Widget untuk kontrol Exhaust Fan
  Widget _buildFanControlCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status Fan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: _fanStatus,
                  onChanged: _isAutoMode
                      ? null // Disabled jika mode Auto aktif
                      : (value) {
                          setState(() {
                            _fanStatus = value;
                          });
                          // Di sini Anda bisa menambahkan logika untuk mengirim perintah ke perangkat
                          _showSnackBar(
                            _fanStatus ? 'Fan Dinyalakan' : 'Fan Dimatikan',
                          );
                        },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _fanStatus
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _fanStatus ? Icons.power : Icons.power_off,
                    color: _fanStatus ? Colors.green : Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _fanStatus ? 'FAN ON' : 'FAN OFF',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _fanStatus ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (_isAutoMode)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Mode Auto aktif - Fan dikontrol otomatis',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget untuk kontrol Mode Operasi
  Widget _buildModeControlCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mode Operasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: _isAutoMode,
                  onChanged: (value) {
                    setState(() {
                      _isAutoMode = value;
                      // Jika mode Auto aktif, matikan fan manual
                      if (_isAutoMode) {
                        _fanStatus = false;
                      }
                    });
                    _showSnackBar(
                      _isAutoMode
                          ? 'Mode Auto Diaktifkan'
                          : 'Mode Manual Diaktifkan',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isAutoMode
                    ? Colors.blue.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isAutoMode ? Icons.auto_mode : Icons.touch_app,
                    color: _isAutoMode ? Colors.blue : Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isAutoMode ? 'AUTO' : 'MANUAL',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isAutoMode ? Colors.blue : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildModeDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeDescription() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isAutoMode ? 'Mode Auto:' : 'Mode Manual:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isAutoMode
                ? 'Fan akan menyala otomatis ketika kualitas udara buruk (CO₂ > 1000, CO > 50, atau Debu > 100)'
                : 'Anda dapat mengontrol fan secara manual menggunakan tombol di atas',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pastikan perangkat terhubung untuk mengontrol fan',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

