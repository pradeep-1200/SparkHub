import 'package:flutter_test/flutter_test.dart';
import 'package:sparkhub/models/user_model.dart';

void main() {
  group('UserModel', () {
    late UserModel testUser;

    setUp(() {
      testUser = UserModel(
        uid: 'test-uid',
        name: 'Test User',
        email: 'test@example.com',
        role: 'participant',
        createdAt: DateTime(2023, 1, 1),
        lastActive: DateTime(2023, 1, 2),
      );
    });

    test('should create UserModel with required fields', () {
      expect(testUser.uid, 'test-uid');
      expect(testUser.name, 'Test User');
      expect(testUser.email, 'test@example.com');
      expect(testUser.role, 'participant');
      expect(testUser.points, 0);
      expect(testUser.badges, []);
      expect(testUser.joinedEvents, []);
    });

    test('should create UserModel from JSON', () {
      final json = {
        'uid': 'test-uid',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'participant',
        'points': 100,
        'badges': ['badge1', 'badge2'],
        'joinedEvents': ['event1', 'event2'],
        'createdAt': DateTime(2023, 1, 1).millisecondsSinceEpoch,
        'lastActive': DateTime(2023, 1, 2).millisecondsSinceEpoch,
      };

      final user = UserModel.fromJson(json);

      expect(user.uid, 'test-uid');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.role, 'participant');
      expect(user.points, 100);
      expect(user.badges, ['badge1', 'badge2']);
      expect(user.joinedEvents, ['event1', 'event2']);
    });

    test('should convert UserModel to JSON', () {
      final json = testUser.toJson();

      expect(json['uid'], 'test-uid');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['role'], 'participant');
      expect(json['points'], 0);
      expect(json['badges'], []);
      expect(json['joinedEvents'], []);
      expect(json['createdAt'], DateTime(2023, 1, 1).millisecondsSinceEpoch);
      expect(json['lastActive'], DateTime(2023, 1, 2).millisecondsSinceEpoch);
    });

    test('should identify admin users correctly', () {
      final adminUser = testUser.copyWith(role: 'admin');
      final participantUser = testUser.copyWith(role: 'participant');

      expect(adminUser.isAdmin, true);
      expect(adminUser.isParticipant, false);
      expect(participantUser.isAdmin, false);
      expect(participantUser.isParticipant, true);
    });

    test('should copy with new values', () {
      final updatedUser = testUser.copyWith(
        name: 'Updated Name',
        points: 50,
        badges: ['new-badge'],
        joinedEvents: ['new-event'],
      );

      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.points, 50);
      expect(updatedUser.badges, ['new-badge']);
      expect(updatedUser.joinedEvents, ['new-event']);
      expect(updatedUser.uid, testUser.uid); // Unchanged
      expect(updatedUser.email, testUser.email); // Unchanged
    });

    test('should handle null profileImageUrl correctly', () {
      expect(testUser.profileImageUrl, null);
      
      final userWithImage = testUser.copyWith(
        profileImageUrl: 'https://example.com/image.jpg',
      );
      
      expect(userWithImage.profileImageUrl, 'https://example.com/image.jpg');
    });

    test('should update lastActive correctly', () {
      final newDate = DateTime.now();
      final updatedUser = testUser.copyWith(lastActive: newDate);
      
      expect(updatedUser.lastActive, newDate);
      expect(updatedUser.lastActive, isNot(equals(testUser.lastActive)));
    });

    test('should handle badges list operations', () {
      final userWithBadges = testUser.copyWith(
        badges: ['badge1', 'badge2', 'badge3'],
      );
      
      expect(userWithBadges.badges.length, 3);
      expect(userWithBadges.badges.contains('badge1'), true);
      expect(userWithBadges.badges.contains('badge4'), false);
    });

    test('should handle joinedEvents list operations', () {
      final userWithEvents = testUser.copyWith(
        joinedEvents: ['event1', 'event2', 'event3'],
      );
      
      expect(userWithEvents.joinedEvents.length, 3);
      expect(userWithEvents.joinedEvents.contains('event1'), true);
      expect(userWithEvents.joinedEvents.contains('event4'), false);
    });
  });
}
