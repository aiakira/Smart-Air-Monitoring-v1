import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/api_service.dart';

// Halaman Notifikasi - terhubung langsung ke backend
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  bool _isClearing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getNotifications(limit: 50);
      if (!mounted) return;
      setState(() {
        _notifications = result;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Gagal memuat notifikasi. Pastikan server berjalan dan koneksi stabil.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: _isClearing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              onPressed: _isClearing ? null : _confirmClearAllNotifications,
              tooltip: 'Hapus Semua',
            ),
        ],
      ),
      body: _buildBody(unreadCount),
    );
  }

  Widget _buildBody(int unreadCount) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, size: 56, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchNotifications,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              child: _buildEmptyState(),
            ),
          ],
        ),
      );
    }

    final hasHeader = unreadCount > 0;
    final totalItems = _notifications.length + (hasHeader ? 1 : 0);

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: totalItems,
        itemBuilder: (context, index) {
          if (hasHeader && index == 0) {
            return Container(
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
            );
          }

          final actualIndex = index - (hasHeader ? 1 : 0);
          return _buildNotificationCard(actualIndex);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'Tidak Ada Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Notifikasi terbaru akan muncul di sini.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(int index) {
    final notification = _notifications[index];
    final isUnread = !notification.isRead;
    final cardColor = _getLevelColor(notification.level, isUnread: isUnread);
    final accentColor = _getAccentColor(notification.level);
    final iconData = _getLevelIcon(notification.level);

    return Dismissible(
      key: ValueKey('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        _handleDismissNotification(index, notification);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: isUnread ? 3 : 1,
        color: cardColor,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: accentColor),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                    fontSize: 16,
                    color: Colors.grey.shade900,
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
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTimestamp(notification.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          trailing: PopupMenuButton<_NotificationMenuAction>(
            onSelected: (action) {
              switch (action) {
                case _NotificationMenuAction.markRead:
                  _markAsRead(notification);
                  break;
                case _NotificationMenuAction.delete:
                  _deleteNotification(notification);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _NotificationMenuAction.markRead,
                enabled: isUnread,
                child: Row(
                  children: [
                    Icon(
                      Icons.mark_email_read,
                      size: 20,
                      color: isUnread ? Colors.blue.shade700 : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tandai Dibaca',
                      style: TextStyle(
                        color: isUnread ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _NotificationMenuAction.delete,
                child: const Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            if (isUnread) {
              _markAsRead(notification);
            }
          },
        ),
      ),
    );
  }

  Future<void> _markAsRead(NotificationItem item) async {
    if (item.isRead) return;
    final success = await ApiService.markNotificationAsRead(item.id);
    if (!mounted) return;
    if (success) {
      setState(() {
        final idx = _notifications.indexWhere((element) => element.id == item.id);
        if (idx != -1) {
          _notifications[idx] = _notifications[idx].copyWith(isRead: true);
        }
      });
      _showSnackBar('Notifikasi ditandai sebagai dibaca');
    } else {
      _showSnackBar('Gagal menandai notifikasi');
    }
  }

  Future<void> _deleteNotification(NotificationItem item) async {
    final success = await ApiService.deleteNotification(item.id);
    if (!mounted) return;
    if (success) {
      setState(() {
        _notifications.removeWhere((element) => element.id == item.id);
      });
      _showSnackBar('Notifikasi dihapus');
    } else {
      _showSnackBar('Gagal menghapus notifikasi');
    }
  }

  Future<void> _handleDismissNotification(int index, NotificationItem item) async {
    setState(() {
      if (index >= 0 && index < _notifications.length) {
        _notifications.removeAt(index);
      } else {
        _notifications.removeWhere((element) => element.id == item.id);
      }
    });

    final success = await ApiService.deleteNotification(item.id);
    if (!mounted) return;
    if (success) {
      _showSnackBar('Notifikasi dihapus');
    } else {
      setState(() {
        _notifications.insert(index.clamp(0, _notifications.length), item);
      });
      _showSnackBar('Gagal menghapus notifikasi');
    }
  }

  Future<void> _confirmClearAllNotifications() async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Semua Notifikasi'),
            content: const Text(
              'Tindakan ini akan menghapus seluruh riwayat notifikasi. Lanjutkan?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    setState(() {
      _isClearing = true;
    });

    final success = await ApiService.clearNotifications();
    if (!mounted) return;

    if (success) {
      setState(() {
        _notifications.clear();
      });
      _showSnackBar('Semua notifikasi dihapus');
    } else {
      _showSnackBar('Gagal menghapus semua notifikasi');
    }

    setState(() {
      _isClearing = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  Color _getLevelColor(String level, {required bool isUnread}) {
    final normalized = level.toLowerCase();
    if (!isUnread) return Colors.white;

    switch (normalized) {
      case 'critical':
      case 'danger':
        return Colors.red.shade50;
      case 'warning':
        return Colors.orange.shade50;
      case 'success':
        return Colors.green.shade50;
      default:
        return Colors.blue.shade50;
    }
  }

  Color _getAccentColor(String level) {
    switch (level.toLowerCase()) {
      case 'critical':
      case 'danger':
        return Colors.red.shade600;
      case 'warning':
        return Colors.orange.shade700;
      case 'success':
        return Colors.green.shade600;
      default:
        return Colors.blue.shade700;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'critical':
      case 'danger':
        return Icons.dangerous;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }
}

enum _NotificationMenuAction { markRead, delete }
