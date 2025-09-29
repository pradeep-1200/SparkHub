import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<UserModel> _leaderboard = [];
  Map<String, dynamic> _userStats = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<UserModel> get leaderboard => _leaderboard;
  Map<String, dynamic> get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load leaderboard
  Future<void> loadLeaderboard([int limit = 10]) async {
    try {
      _setLoading(true);
      _leaderboard = await _firestoreService.getLeaderboard(limit);
      _setLoading(false);
      _clearError();
    } catch (e) {
      _setError('Failed to load leaderboard: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Load user stats
  Future<void> loadUserStats(String userId) async {
    try {
      _setLoading(true);
      _userStats = await _firestoreService.getUserStats(userId);
      _setLoading(false);
      _clearError();
    } catch (e) {
      _setError('Failed to load user stats: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Update user points
  Future<void> updateUserPoints(String userId, int points) async {
    try {
      await _firestoreService.updateUserPoints(userId, points);
      
      // Update local stats if available
      if (_userStats.containsKey('totalPoints')) {
        _userStats['totalPoints'] = (_userStats['totalPoints'] ?? 0) + points;
        notifyListeners();
      }
      
      _clearError();
    } catch (e) {
      _setError('Failed to update points: ${e.toString()}');
    }
  }

  // Add badge to user
  Future<void> addBadgeToUser(String userId, String badgeId) async {
    try {
      await _firestoreService.addBadgeToUser(userId, badgeId);
      _clearError();
    } catch (e) {
      _setError('Failed to add badge: ${e.toString()}');
    }
  }

  // Get user rank in leaderboard
  int getUserRank(String userId) {
    final index = _leaderboard.indexWhere((user) => user.uid == userId);
    return index >= 0 ? index + 1 : -1;
  }

  // Get top users by category
  List<UserModel> getTopUsersByPoints(int limit) {
    return _leaderboard.take(limit).toList();
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
