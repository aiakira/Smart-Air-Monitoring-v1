class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String level;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    DateTime parsedTime;
    final rawTimestamp = json['created_at'] ?? json['timestamp'] ?? json['waktu'];
    try {
      parsedTime = rawTimestamp != null
          ? DateTime.parse(rawTimestamp.toString()).toLocal()
          : DateTime.now();
    } catch (_) {
      parsedTime = DateTime.now();
    }

    return NotificationItem(
      id: _coerceToInt(json['id']),
      title: (json['title'] ?? 'Tanpa judul').toString(),
      message: (json['message'] ?? '').toString(),
      level: (json['level'] ?? 'info').toString().toLowerCase(),
      isRead: (json['is_read'] ?? json['isRead'] ?? false) == true,
      createdAt: parsedTime,
    );
  }

  NotificationItem copyWith({
    int? id,
    String? title,
    String? message,
    String? level,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      level: level ?? this.level,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'level': level,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static int _coerceToInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

