import 'package:flutter/material.dart';
import '../models/sensor_data.dart';

// Halaman Notifikasi - menampilkan notifikasi tentang kualitas udara
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Daftar notifikasi simulasi
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Fungsi untuk memuat notifikasi (dalam aplikasi nyata, ini dari database)
  void _loadNotifications() {
    _notifications = [
      NotificationItem(
        title: 'Kualitas Udara BURUK',
        message: 'Kadar CO₂ melebihi ambang batas (1000 ppm). Exhaust fan telah dinyalakan otomatis.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
      NotificationItem(
        title: 'Kualitas Udara SEDANG',
        message: 'Kadar debu meningkat menjadi 75 µg/m³. Perhatikan ventilasi ruangan.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationItem(
        title: 'Kualitas Udara BAIK',
        message: 'Semua parameter sensor dalam batas normal.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      NotificationItem(
        title: 'Perangkat Terhubung',
        message: 'Sensor berhasil terhubung dan mulai mengirim data.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }

  // Fungsi untuk menandai notifikasi sebagai sudah dibaca
  void _markAsRead(int index) {
    setState(() {
      NotificationItem item = _notifications[index];
      _notifications[index] = NotificationItem(
        title: item.title,
        message: item.message,
        timestamp: item.timestamp,
        isRead: true,
      );
    });
    
    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifikasi ditandai sebagai sudah dibaca'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Fungsi untuk menghapus notifikasi
  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifikasi dihapus'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Fungsi untuk menghapus semua notifikasi
  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi?'),
        content: const Text('Apakah Anda yakin ingin menghapus semua notifikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua notifikasi dihapus'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearAllNotifications,
              tooltip: 'Hapus Semua',
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Header dengan jumlah notifikasi belum dibaca
                if (unreadCount > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Text(
                      '$unreadCount notifikasi belum dibaca',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                // Daftar notifikasi
                Expanded(
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(index);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // Widget untuk menampilkan state kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan kartu notifikasi
  Widget _buildNotificationCard(int index) {
    NotificationItem notification = _notifications[index];
    bool isUnread = !notification.isRead;

    // Tentukan warna berdasarkan jenis notifikasi
    Color cardColor;
    IconData iconData;
    if (notification.title.contains('BURUK')) {
      cardColor = Colors.red.shade50;
      iconData = Icons.warning;
    } else if (notification.title.contains('SEDANG')) {
      cardColor = Colors.orange.shade50;
      iconData = Icons.info;
    } else {
      cardColor = Colors.green.shade50;
      iconData = Icons.check_circle;
    }

    return Dismissible(
      key: Key('notification_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(index);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: isUnread ? 3 : 1,
        color: isUnread ? cardColor : Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              color: Colors.blue.shade700,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isUnread)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTimestamp(notification.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: isUnread,
                onTap: isUnread
                    ? () {
                        Navigator.pop(context); // Tutup popup menu
                        _markAsRead(index);
                      }
                    : null,
                child: Row(
                  children: [
                    Icon(
                      Icons.mark_email_read,
                      size: 20,
                      color: isUnread ? null : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tandai Dibaca',
                      style: TextStyle(
                        color: isUnread ? null : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context); // Tutup popup menu
                  _deleteNotification(index);
                },
              ),
            ],
          ),
          onTap: () {
            if (isUnread) {
              _markAsRead(index);
            }
          },
        ),
      ),
    );
  }

  // Fungsi untuk memformat timestamp
  String _formatTimestamp(DateTime timestamp) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}

