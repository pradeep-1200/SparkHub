import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/badge_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String badgesCollection = 'badges';

  // User operations
  Future<void> createUser(UserModel user) async {
    await _db.collection(usersCollection).doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(usersCollection).doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection(usersCollection).doc(user.uid).update(user.toJson());
  }

  Future<void> updateUserLastActive(String uid) async {
    await _db.collection(usersCollection).doc(uid).update({
      'lastActive': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection(usersCollection).doc(uid).delete();
  }

  Future<void> updateUserPoints(String uid, int points) async {
    await _db.collection(usersCollection).doc(uid).update({
      'points': FieldValue.increment(points),
    });
  }

  Future<void> addBadgeToUser(String uid, String badgeId) async {
    await _db.collection(usersCollection).doc(uid).update({
      'badges': FieldValue.arrayUnion([badgeId]),
    });
  }

  // Event operations
  Future<String> createEvent(EventModel event) async {
    final docRef = _db.collection(eventsCollection).doc();
    final eventWithId = event.copyWith(id: docRef.id);
    await docRef.set(eventWithId.toJson());
    return docRef.id;
  }

  Future<EventModel?> getEvent(String eventId) async {
    final doc = await _db.collection(eventsCollection).doc(eventId).get();
    if (doc.exists && doc.data() != null) {
      return EventModel.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<List<EventModel>> getEventsStream() {
    return _db
        .collection(eventsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromJson(doc.data()))
            .toList());
  }

  Future<List<EventModel>> getUpcomingEvents() async {
    final snapshot = await _db
        .collection(eventsCollection)
        .where('isActive', isEqualTo: true)
        .where('date', isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        .orderBy('date')
        .get();

    return snapshot.docs
        .map((doc) => EventModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> updateEvent(EventModel event) async {
    await _db.collection(eventsCollection).doc(event.id).update(event.toJson());
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection(eventsCollection).doc(eventId).delete();
  }

  Future<void> rsvpToEvent(String eventId, String userId) async {
    final batch = _db.batch();

    // Add user to event attendees
    batch.update(_db.collection(eventsCollection).doc(eventId), {
      'attendees': FieldValue.arrayUnion([userId]),
    });

    // Add event to user's joined events
    batch.update(_db.collection(usersCollection).doc(userId), {
      'joinedEvents': FieldValue.arrayUnion([eventId]),
    });

    await batch.commit();
  }

  Future<void> cancelRsvp(String eventId, String userId) async {
    final batch = _db.batch();

    // Remove user from event attendees
    batch.update(_db.collection(eventsCollection).doc(eventId), {
      'attendees': FieldValue.arrayRemove([userId]),
    });

    // Remove event from user's joined events
    batch.update(_db.collection(usersCollection).doc(userId), {
      'joinedEvents': FieldValue.arrayRemove([eventId]),
    });

    await batch.commit();
  }

  // Badge operations
  Future<void> createBadge(BadgeModel badge) async {
    await _db.collection(badgesCollection).doc(badge.id).set(badge.toJson());
  }

  Future<List<BadgeModel>> getAllBadges() async {
    final snapshot = await _db
        .collection(badgesCollection)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => BadgeModel.fromJson(doc.data()))
        .toList();
  }

  Future<BadgeModel?> getBadge(String badgeId) async {
    final doc = await _db.collection(badgesCollection).doc(badgeId).get();
    if (doc.exists && doc.data() != null) {
      return BadgeModel.fromJson(doc.data()!);
    }
    return null;
  }

  // Analytics and stats
  Future<Map<String, dynamic>> getUserStats(String uid) async {
    final userDoc = await _db.collection(usersCollection).doc(uid).get();
    if (!userDoc.exists) return {};

    final userData = userDoc.data()!;
    final joinedEvents = List<String>.from(userData['joinedEvents'] ?? []);
    final badges = List<String>.from(userData['badges'] ?? []);

    return {
      'totalEvents': joinedEvents.length,
      'totalBadges': badges.length,
      'totalPoints': userData['points'] ?? 0,
      'joinDate': userData['createdAt'],
    };
  }

  Future<List<UserModel>> getLeaderboard([int limit = 10]) async {
    final snapshot = await _db
        .collection(usersCollection)
        .orderBy('points', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }
}
