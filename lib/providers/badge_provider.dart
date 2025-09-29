import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'user_provider.dart';

class BadgeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<BadgeModel> _badges = [];
  List<BadgeModel> _userBadges = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<BadgeModel> get badges => _badges;
  List<BadgeModel> get userBadges => _userBadges;
  List<BadgeModel> get availableBadges => _badges.where((badge) => 
      !_userBadges.any((userBadge) => userBadge.id == badge.id)).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all badges
  Future<void> loadBadges() async {
    try {
      _setLoading(true);
      _badges = await _firestoreService.getAllBadges();
      _setLoading(false);
      _clearError();
    } catch (e) {
      _setError('Failed to load badges: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Load user badges
  Future<void> loadUserBadges(UserModel user) async {
    try {
      _setLoading(true);
      _userBadges = [];
      
      for (String badgeId in user.badges) {
        final badge = await _firestoreService.getBadge(badgeId);
        if (badge != null) {
          _userBadges.add(badge);
        }
      }
      
      _setLoading(false);
      _clearError();
    } catch (e) {
      _setError('Failed to load user badges: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Create badge (Admin only)
  Future<bool> createBadge({
    required String name,
    required String description,
    required String iconUrl,
    required int pointsRequired,
    required BadgeType type,
    Map<String, dynamic>? criteria,
  }) async {
    try {
      final badge = BadgeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        iconUrl: iconUrl,
        pointsRequired: pointsRequired,
        type: type,
        createdAt: DateTime.now(),
        criteria: criteria,
      );

      await _firestoreService.createBadge(badge);
      _badges.add(badge);
      notifyListeners();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to create badge: ${e.toString()}');
      return false;
    }
  }

  // Check and award badges to user
  Future<List<BadgeModel>> checkAndAwardBadges(
    UserModel user, 
    UserProvider userProvider,
  ) async {
    List<BadgeModel> newBadges = [];
    
    try {
      for (BadgeModel badge in availableBadges) {
        if (await _shouldAwardBadge(badge, user)) {
          await userProvider.addBadgeToUser(user.uid, badge.id);
          _userBadges.add(badge);
          newBadges.add(badge);
        }
      }
      
      if (newBadges.isNotEmpty) {
        notifyListeners();
      }
      
      _clearError();
    } catch (e) {
      _setError('Failed to check badges: ${e.toString()}');
    }
    
    return newBadges;
  }

  // Check if user should be awarded a badge
  Future<bool> _shouldAwardBadge(BadgeModel badge, UserModel user) async {
    // Basic points check
    if (user.points < badge.pointsRequired) {
      return false;
    }

    // Additional criteria checks
    if (badge.criteria != null) {
      final criteria = badge.criteria!;
      
      // Event participation badges
      if (criteria.containsKey('eventsAttended')) {
        final required = criteria['eventsAttended'] as int;
        if (user.joinedEvents.length < required) return false;
      }
      
      // Streak badges
      if (criteria.containsKey('streak')) {
        // Implement streak logic based on user activity
        // This would require additional tracking in user model
      }
      
      // Time-based badges
      if (criteria.containsKey('daysSinceJoin')) {
        final required = criteria['daysSinceJoin'] as int;
        final daysSinceJoin = DateTime.now().difference(user.createdAt).inDays;
        if (daysSinceJoin < required) return false;
      }
    }

    return true;
  }

  // Get badges by type
  List<BadgeModel> getBadgesByType(BadgeType type) {
    return _badges.where((badge) => badge.type == type).toList();
  }

  // Get user badges by type
  List<BadgeModel> getUserBadgesByType(BadgeType type) {
    return _userBadges.where((badge) => badge.type == type).toList();
  }

  // Check if user has badge
  bool userHasBadge(String badgeId) {
    return _userBadges.any((badge) => badge.id == badgeId);
  }

  // Get progress towards next badge
  double getProgressTowardsBadge(BadgeModel badge, int userPoints) {
    if (userPoints >= badge.pointsRequired) return 1.0;
    return userPoints / badge.pointsRequired;
  }

  // Get next available badge for user
  BadgeModel? getNextBadge(int userPoints) {
    final available = availableBadges
        .where((badge) => badge.pointsRequired > userPoints)
        .toList();
    
    if (available.isEmpty) return null;
    
    available.sort((a, b) => a.pointsRequired.compareTo(b.pointsRequired));
    return available.first;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
