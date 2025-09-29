class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'participant' or 'admin'
  final int points;
  final List<String> badges;
  final List<String> joinedEvents;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastActive;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.points = 0,
    this.badges = const [],
    this.joinedEvents = const [],
    this.profileImageUrl,
    required this.createdAt,
    required this.lastActive,
    this.preferences,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'points': points,
      'badges': badges,
      'joinedEvents': joinedEvents,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastActive': lastActive.millisecondsSinceEpoch,
      'preferences': preferences ?? {},
    };
  }

  // Create from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'participant',
      points: json['points'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      joinedEvents: List<String>.from(json['joinedEvents'] ?? []),
      profileImageUrl: json['profileImageUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      lastActive: DateTime.fromMillisecondsSinceEpoch(
        json['lastActive'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      preferences: json['preferences'],
    );
  }

  // Copy with new values
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    int? points,
    List<String>? badges,
    List<String>? joinedEvents,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastActive,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      points: points ?? this.points,
      badges: badges ?? this.badges,
      joinedEvents: joinedEvents ?? this.joinedEvents,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      preferences: preferences ?? this.preferences,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isParticipant => role == 'participant';
}
