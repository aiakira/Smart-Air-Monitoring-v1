import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/sensor_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _co2Threshold = 1000.0;
  double _coThreshold = 50.0;
  double _dustThreshold = 100.0;

  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

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

            _buildSectionTitle('Notifikasi'),
            const SizedBox(height: 12),
            _buildNotificationSettingsCard(),
            const SizedBox(height: 24),

            _buildSectionTitle('Tampilan'),
            const SizedBox(height: 12),
            _buildThemeSettingsCard(),
            const SizedBox(height: 24),

            _buildSectionTitle('Umum'),
            const SizedBox(height: 12),
            _buildGeneralSettingsCard(),
            const SizedBox(height: 24),

            _buildSectionTitle('Status Sistem'),
            const SizedBox(height: 12),
            _buildSystemStatusCard(),
            const SizedBox(height: 24),

            _buildResetButton(),
            const SizedBox(height: 24),
            _buildAppInfoCard(),
          ],
        ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }



  Widget _buildThresholdCard(
    String label,
    double value,
    String unit,
    ValueChanged<double> onChanged,
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
              min: label == 'CO₂'
                  ? 500
                  : label == 'CO'
                      ? 10
                      : 20,
              max: label == 'CO₂'
                  ? 2000
                  : label == 'CO'
                      ? 100
                      : 200,
              divisions: 30,
              label: '${value.toStringAsFixed(1)} $unit',
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettingsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchTile(
              'Aktifkan Notifikasi',
              'Terima peringatan ketika kualitas udara menurun',
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

  Widget _buildThemeSettingsCard() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSwitchTile(
                  'Mode Gelap',
                  'Aktifkan tema gelap untuk penggunaan malam hari',
                  themeProvider.isDarkMode,
                  (value) {
                    themeProvider.toggleTheme();
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Warna Tema'),
                  subtitle: const Text('Pilih warna tema aplikasi'),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getThemeColor(themeProvider.themeColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () => _showThemeColorDialog(context, themeProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSystemStatusCard() {
    return Consumer<SensorProvider>(
      builder: (context, provider, child) {
        final lastUpdate = provider.currentData?.timestamp;
        final isConnected = provider.isConnected;
        final isDataOld = lastUpdate != null && 
            DateTime.now().difference(lastUpdate).inMinutes > 5;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Connection Status
                Row(
                  children: [
                    Icon(
                      isConnected ? Icons.wifi : Icons.wifi_off,
                      color: isConnected ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Koneksi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isConnected ? 'Terhubung ke server' : 'Terputus dari server',
                            style: TextStyle(
                              fontSize: 12,
                              color: isConnected ? Colors.green.shade700 : Colors.red.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isConnected ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isConnected ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Last Update
                Row(
                  children: [
                    Icon(
                      Icons.update,
                      color: isDataOld ? Colors.orange : Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pembaruan Terakhir',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastUpdate != null
                                ? _formatFullTimestamp(lastUpdate)
                                : 'Belum ada data',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isDataOld) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Data lebih dari 5 menit. Periksa koneksi sensor.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatFullTimestamp(DateTime time) {
    final date =
        '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}';
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
    return '$date $timeStr';
  }

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
                'Semua ambang batas dan preferensi notifikasi akan dikembalikan.',
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
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Versi', '1.0.0'),
            _buildInfoRow('Nama Aplikasi', 'Smart Air Monitoring'),
            _buildInfoRow('Mode', 'Monitoring Kualitas Udara'),
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

  Color _getThemeColor(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _showThemeColorDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Warna Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildColorOption('Biru', 'blue', Colors.blue, themeProvider),
            _buildColorOption('Hijau', 'green', Colors.green, themeProvider),
            _buildColorOption('Ungu', 'purple', Colors.purple, themeProvider),
            _buildColorOption('Oranye', 'orange', Colors.orange, themeProvider),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(String name, String value, Color color, ThemeProvider themeProvider) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(name),
      trailing: themeProvider.themeColor == value 
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        themeProvider.setThemeColor(value);
        Navigator.pop(context);
      },
    );
  }
}