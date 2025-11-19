import 'package:flutter/material.dart';

// Halaman Pengaturan - untuk mengatur ambang batas dan koneksi
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Ambang batas untuk sensor
  double _co2Threshold = 1000.0;
  double _coThreshold = 50.0;
  double _dustThreshold = 100.0;

  // Status koneksi
  bool _isConnected = false;
  String _deviceName = 'Sensor Device';

  // Pengaturan notifikasi
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Interval update data (dalam detik)
  int _updateInterval = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bagian Koneksi
          _buildSectionTitle('Koneksi Perangkat'),
          const SizedBox(height: 12),
          _buildConnectionCard(),
          const SizedBox(height: 24),

          // Bagian Ambang Batas
          _buildSectionTitle('Ambang Batas Sensor'),
          const SizedBox(height: 12),
          _buildThresholdCard('CO₂', _co2Threshold, 'ppm', (value) {
            setState(() {
              _co2Threshold = value;
            });
          }),
          const SizedBox(height: 12),
          _buildThresholdCard('CO', _coThreshold, 'ppm', (value) {
            setState(() {
              _coThreshold = value;
            });
          }),
          const SizedBox(height: 12),
          _buildThresholdCard('Debu', _dustThreshold, 'µg/m³', (value) {
            setState(() {
              _dustThreshold = value;
            });
          }),
          const SizedBox(height: 24),

          // Bagian Notifikasi
          _buildSectionTitle('Notifikasi'),
          const SizedBox(height: 12),
          _buildNotificationSettingsCard(),
          const SizedBox(height: 24),

          // Bagian Umum
          _buildSectionTitle('Umum'),
          const SizedBox(height: 12),
          _buildGeneralSettingsCard(),
          const SizedBox(height: 24),

          // Tombol Reset
          _buildResetButton(),
          const SizedBox(height: 24),

          // Informasi Aplikasi
          _buildAppInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Widget untuk kartu koneksi
  Widget _buildConnectionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Koneksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _isConnected ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isConnected ? 'Terhubung' : 'Tidak Terhubung',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isConnected = !_isConnected;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isConnected
                              ? 'Berhasil terhubung ke $_deviceName'
                              : 'Koneksi terputus',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(_isConnected ? Icons.bluetooth_disabled : Icons.bluetooth),
                  label: Text(_isConnected ? 'Putuskan' : 'Hubungkan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConnected ? Colors.red : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            if (_isConnected) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nama Perangkat',
                    style: TextStyle(fontSize: 14),
                  ),
                  Row(
                    children: [
                      Text(
                        _deviceName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        color: Colors.blue.shade700,
                        onPressed: () => _showEditDeviceNameDialog(),
                        tooltip: 'Edit nama perangkat',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget untuk kartu ambang batas
  Widget _buildThresholdCard(
    String label,
    double value,
    String unit,
    Function(double) onChanged,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: value,
              min: label == 'CO₂' ? 500 : label == 'CO' ? 10 : 20,
              max: label == 'CO₂' ? 2000 : label == 'CO' ? 100 : 200,
              divisions: 30,
              label: '${value.toStringAsFixed(1)} $unit',
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk pengaturan notifikasi
  Widget _buildNotificationSettingsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchTile(
              'Aktifkan Notifikasi',
              'Terima notifikasi tentang perubahan kualitas udara',
              _notificationsEnabled,
              (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            if (_notificationsEnabled) ...[
              const Divider(),
              _buildSwitchTile(
                'Suara',
                'Putar suara saat notifikasi diterima',
                _soundEnabled,
                (value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                },
              ),
              const Divider(),
              _buildSwitchTile(
                'Getar',
                'Getarkan perangkat saat notifikasi diterima',
                _vibrationEnabled,
                (value) {
                  setState(() {
                    _vibrationEnabled = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget untuk pengaturan umum
  Widget _buildGeneralSettingsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interval Update',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Frekuensi pembaruan data',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_updateInterval detik',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: _updateInterval.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_updateInterval detik',
              onChanged: (value) {
                setState(() {
                  _updateInterval = value.toInt();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  // Widget untuk tombol reset
  Widget _buildResetButton() {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      child: ListTile(
        leading: Icon(Icons.restore, color: Colors.red.shade700),
        title: Text(
          'Reset ke Pengaturan Default',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.red.shade700,
          ),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Reset Pengaturan?'),
              content: const Text(
                'Apakah Anda yakin ingin mengembalikan semua pengaturan ke nilai default?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _co2Threshold = 1000.0;
                      _coThreshold = 50.0;
                      _dustThreshold = 100.0;
                      _notificationsEnabled = true;
                      _soundEnabled = true;
                      _vibrationEnabled = true;
                      _updateInterval = 2;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pengaturan direset ke default'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Reset', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget untuk informasi aplikasi
  Widget _buildAppInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Informasi Aplikasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Versi', '1.0.0'),
            _buildInfoRow('Nama Aplikasi', 'Smart Air Monitoring'),
            _buildInfoRow('Developer', 'Andi Ahmad Fadhil Az'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog untuk mengedit nama perangkat
  void _showEditDeviceNameDialog() {
    final TextEditingController controller = TextEditingController(text: _deviceName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nama Perangkat'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nama Perangkat',
            hintText: 'Masukkan nama perangkat',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _deviceName = controller.text.trim();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nama perangkat diubah menjadi: $_deviceName'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

