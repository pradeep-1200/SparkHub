import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

enum EventStatus { loading, loaded, error, creating, updating }

class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  EventStatus _status = EventStatus.loaded;
  List<EventModel> _events = [];
  List<EventModel> _userEvents = [];
  EventModel? _selectedEvent;
  String? _errorMessage;

  // Getters
  EventStatus get status => _status;
  List<EventModel> get events => _events;
  List<EventModel> get userEvents => _userEvents;
  List<EventModel> get upcomingEvents => _events
      .where((event) => event.isUpcoming && event.isActive)
      .toList();
  List<EventModel> get pastEvents => _events
      .where((event) => event.isPast)
      .toList();
  EventModel? get selectedEvent => _selectedEvent;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == EventStatus.loading;

  // Filter events by category
  List<EventModel> getEventsByCategory(EventCategory category) {
    return _events.where((event) => event.category == category).toList();
  }

  // Get events user has joined
  List<EventModel> getUserJoinedEvents(String userId) {
    return _events
        .where((event) => event.attendees.contains(userId))
        .toList();
  }

  // Initialize events stream
  void initializeEventsStream() {
    _firestoreService.getEventsStream().listen(
      (events) {
        _events = events;
        _setStatus(EventStatus.loaded);
        _clearError();
      },
      onError: (error) {
        _setError('Failed to load events: ${error.toString()}');
      },
    );
  }

  // Load upcoming events
  Future<void> loadUpcomingEvents() async {
    try {
      _setStatus(EventStatus.loading);
      final events = await _firestoreService.getUpcomingEvents();
      _events = events;
      _setStatus(EventStatus.loaded);
      _clearError();
    } catch (e) {
      _setError('Failed to load events: ${e.toString()}');
    }
  }

  // Load user's events
  Future<void> loadUserEvents(String userId) async {
    try {
      _userEvents = getUserJoinedEvents(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user events: ${e.toString()}');
    }
  }

  // Create event (Admin only)
  Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String time,
    required String location,
    required EventCategory category,
    required String createdBy,
    String? imageUrl,
    int maxAttendees = 50,
  }) async {
    try {
      _setStatus(EventStatus.creating);
      final event = EventModel(
        id: '', // Will be set by Firestore
        title: title,
        description: description,
        date: date,
        time: time,
        location: location,
        category: category,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: imageUrl,
        maxAttendees: maxAttendees,
      );

      final eventId = await _firestoreService.createEvent(event);
      _setStatus(EventStatus.loaded);
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to create event: ${e.toString()}');
      return false;
    }
  }

  // Update event (Admin only)
  Future<bool> updateEvent(EventModel event) async {
    try {
      _setStatus(EventStatus.updating);
      final updatedEvent = event.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateEvent(updatedEvent);

      // Update local list
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = updatedEvent;
      }

      _setStatus(EventStatus.loaded);
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update event: ${e.toString()}');
      return false;
    }
  }

  // Delete event (Admin only)
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _firestoreService.deleteEvent(eventId);
      _events.removeWhere((event) => event.id == eventId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete event: ${e.toString()}');
      return false;
    }
  }

  // RSVP to event
  Future<bool> rsvpToEvent(String eventId, String userId) async {
    try {
      final event = _events.firstWhere((e) => e.id == eventId);
      
      if (event.isFull) {
        _setError('Event is full');
        return false;
      }

      if (event.attendees.contains(userId)) {
        _setError('Already registered for this event');
        return false;
      }

      await _firestoreService.rsvpToEvent(eventId, userId);
      
      // Update local event
      final updatedAttendees = [...event.attendees, userId];
      final updatedEvent = event.copyWith(attendees: updatedAttendees);
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _events[index] = updatedEvent;
      }

      notifyListeners();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to RSVP: ${e.toString()}');
      return false;
    }
  }

  // Cancel RSVP
  Future<bool> cancelRsvp(String eventId, String userId) async {
    try {
      await _firestoreService.cancelRsvp(eventId, userId);
      
      // Update local event
      final event = _events.firstWhere((e) => e.id == eventId);
      final updatedAttendees = event.attendees.where((id) => id != userId).toList();
      final updatedEvent = event.copyWith(attendees: updatedAttendees);
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _events[index] = updatedEvent;
      }

      notifyListeners();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to cancel RSVP: ${e.toString()}');
      return false;
    }
  }

  // Select event for details
  void selectEvent(EventModel event) {
    _selectedEvent = event;
    notifyListeners();
  }

  // Clear selected event
  void clearSelectedEvent() {
    _selectedEvent = null;
    notifyListeners();
  }

  // Check if user has RSVPed
  bool hasUserRsvped(String eventId, String userId) {
    try {
      final event = _events.firstWhere((e) => e.id == eventId);
      return event.attendees.contains(userId);
    } catch (e) {
      return false;
    }
  }

  // Get event attendee count
  int getAttendeeCount(String eventId) {
    try {
      final event = _events.firstWhere((e) => e.id == eventId);
      return event.attendees.length;
    } catch (e) {
      return 0;
    }
  }

  // Search events
  List<EventModel> searchEvents(String query) {
    if (query.isEmpty) return _events;
    
    final lowercaseQuery = query.toLowerCase();
    return _events.where((event) {
      return event.title.toLowerCase().contains(lowercaseQuery) ||
          event.description.toLowerCase().contains(lowercaseQuery) ||
          event.location.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  void _setStatus(EventStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = EventStatus.error;
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
