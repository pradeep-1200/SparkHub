enum NotificationType {
  general,
  event,
  badge,
  reminder,
  achievement,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
      'readAt': readAt?.millisecondsSinceEpoch,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['readAt'])
          : null,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}
