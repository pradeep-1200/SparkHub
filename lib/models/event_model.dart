enum EventCategory {
  workshop,
  meetup,
  hackathon,
  conference,
  seminar,
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String? imageUrl;
  final List<String> attendees;
  final EventCategory category;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int maxAttendees;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    this.imageUrl,
    this.attendees = const [],
    required this.category,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.maxAttendees = 50,
    this.isActive = true,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'time': time,
      'location': location,
      'imageUrl': imageUrl,
      'attendees': attendees,
      'category': category.name,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'maxAttendees': maxAttendees,
      'isActive': isActive,
      'metadata': metadata ?? {},
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(
        json['date'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'],
      attendees: List<String>.from(json['attendees'] ?? []),
      category: EventCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => EventCategory.meetup,
      ),
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      maxAttendees: json['maxAttendees'] ?? 50,
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'],
    );
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    String? imageUrl,
    List<String>? attendees,
    EventCategory? category,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? maxAttendees,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      attendees: attendees ?? this.attendees,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isFull => attendees.length >= maxAttendees;
  bool get isUpcoming => date.isAfter(DateTime.now());
  bool get isPast => date.isBefore(DateTime.now());
  int get availableSpots => maxAttendees - attendees.length;
}
