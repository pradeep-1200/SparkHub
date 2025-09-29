enum BadgeType {
  participation,
  achievement,
  milestone,
  special,
}

class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int pointsRequired;
  final BadgeType type;
  final bool isActive;
  final DateTime createdAt;
  final Map<String, dynamic>? criteria;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.pointsRequired,
    required this.type,
    this.isActive = true,
    required this.createdAt,
    this.criteria,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'pointsRequired': pointsRequired,
      'type': type.name,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'criteria': criteria ?? {},
    };
  }

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      pointsRequired: json['pointsRequired'] ?? 0,
      type: BadgeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BadgeType.participation,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      criteria: json['criteria'],
    );
  }

  BadgeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    int? pointsRequired,
    BadgeType? type,
    bool? isActive,
    DateTime? createdAt,
    Map<String, dynamic>? criteria,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      criteria: criteria ?? this.criteria,
    );
  }
}
