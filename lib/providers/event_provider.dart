import 'package:flutter/material.dart';
import '../models/event_models.dart';
import '../services/bookmark_services.dart';
import '../services/events_service.dart';

class EventProvider with ChangeNotifier {
  final EventsService _eventsService = EventsService();
  final BookmarkService _bookmarkService = BookmarkService();
  List<Event> _allEvents = [];
  List<Event> _upcomingEvents = [];
  List<Event> _filteredEvents = [];
  List<Event> _searchResults = [];
  final Map<String, bool> _bookmarkedEvents = {};

  List<Event> get events =>
      _searchQuery.isEmpty ? _filteredEvents : _searchResults;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _selectedCategory = 'All';
  String? _selectedCategoryId;

  String? get selectedCategory => _selectedCategory;

  String? get selectedCategoryId => _selectedCategoryId;

  String _selectedSortBy = 'Date';

  String get selectedSortBy => _selectedSortBy;

  DateTimeRange? _selectedDateRange;

  DateTimeRange? get selectedDateRange => _selectedDateRange;

  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  static const int _initialLoadCount = 9;
  static const int _loadMoreCount = _initialLoadCount + 9;

  Future<void> loadUpcomingEvents() async {
    try {
      final events = await _eventsService.getAllEvents();
      final now = DateTime.now();
      _upcomingEvents = events
          .where((event) =>
      _parseDateTime(event.endtime!).isAfter(now) &&
          event.publishOnline == true)
          .toList();
      _sortEventsByPriority(_upcomingEvents);
      _removeExpiredEvents();
      _filterVisibleEvents();
      _applyFilters();
    } catch (e) {
      print('Error loading upcoming events: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadInitialEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_selectedCategory == null || _selectedCategory == 'All') {
        loadUpcomingEvents();
        _allEvents =
        await _eventsService.getPaginatedEvents(1, _initialLoadCount);
        print("All events: ${_allEvents.length}");
      } else {
        _allEvents = await _eventsService.getPaginatedEventsByCategory(
            _selectedCategoryId!, 1, _initialLoadCount);
      }
      _removeExpiredEvents();
      _filterVisibleEvents();
      _applyFilters();
      await _loadBookmarkedStates();
    } catch (e) {
      print('Error loading initial events: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetFilters() {
    _selectedCategory = null;
    _selectedCategoryId = null;
    _selectedSortBy = 'Date';
    _selectedDateRange = null;
    _searchQuery = '';
    _searchResults = [];
    _allEvents = [];
    loadInitialEvents();
    notifyListeners();
  }

  Future<void> loadMoreEvents() async {
    if (!_isLoading && _searchQuery.isEmpty) {
      _isLoading = true;
      notifyListeners();

      try {
        final nextPage = _allEvents.length + 1;
        List<Event> newEvents;

        if (_selectedCategory == null || _selectedCategory == 'All') {
          newEvents =
          await _eventsService.getPaginatedEvents(nextPage, _loadMoreCount);
        } else {
          newEvents = await _eventsService.getPaginatedEventsByCategory(
              _selectedCategoryId!, nextPage, _loadMoreCount);
        }

        // Filter out any events that are already in _allEvents
        newEvents = newEvents
            .where((newEvent) => !_allEvents
            .any((existingEvent) => existingEvent.eid == newEvent.eid))
            .toList();

        _allEvents.addAll(newEvents);
        _removeExpiredEvents();
        _filterVisibleEvents();
        _applyFilters();
        await _loadBookmarkedStates();
      } catch (e) {
        print('Error loading more events: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void setCategory(String? categoryName, String? categoryId) {
    if (_selectedCategory != categoryName ||
        _selectedCategoryId != categoryId) {
      _selectedCategory = categoryName;
      _selectedCategoryId = categoryId;
      _allEvents = [];
      loadInitialEvents();
      notifyListeners();
    }
  }

  void setSortBy(String sortBy) {
    _selectedSortBy = sortBy;
    print("Selected sort by: $_selectedSortBy");
    _applyFilters();
    notifyListeners();
  }

  void setDateRange(DateTimeRange? dateRange) {
    _selectedDateRange = dateRange;
    _applyFilters();
    notifyListeners();
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      _applyFilters();
    } else {
      await _performGlobalSearch();
    }
    notifyListeners();
  }

  Future<void> _performGlobalSearch() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Event> allEvents;

      allEvents = await _eventsService.getAllEvents();

      _searchResults = allEvents.where((event) {
        final query = _searchQuery.toLowerCase();
        return event.publishOnline == true &&
            (event.name!.toLowerCase().contains(query) ||
                (event.location?.toLowerCase().contains(query) ?? false) ||
                (event.eventdescription?.toLowerCase().contains(query) ??
                    false));
      }).toList();

      _removeExpiredEventsFromSearch();
      _applyFiltersToSearchResults();
    } catch (e) {
      print('Error performing global search: $e');
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DateTime _parseDateTime(String dateString) {
    return DateTime.parse(dateString);
  }

  void _removeExpiredEvents() {
    final now = DateTime.now();
    _allEvents = _allEvents.where((event) {
      final eventEnd = _parseDateTime(event.endtime!);
      return now.difference(eventEnd).inDays <= 30;
    }).toList();
  }

  void _filterVisibleEvents() {
    _allEvents =
        _allEvents.where((event) => event.publishOnline == true).toList();
  }

  void _removeExpiredEventsFromSearch() {
    final now = DateTime.now();
    _searchResults = _searchResults.where((event) {
      final eventEnd = _parseDateTime(event.endtime!);
      return now.difference(eventEnd).inDays <= 30 &&
          event.publishOnline == true;
    }).toList();
  }

  void _applyFilters() {
    _filteredEvents = _allEvents.where(_eventMatchesFilters).toList();
    _applySortingToFilteredEvents();
  }

  void _applyFiltersToSearchResults() {
    _searchResults = _searchResults.where(_eventMatchesFilters).toList();
    _applySortingToSearchResults();
  }

  bool _eventMatchesFilters(Event event) {
    if (event.publishOnline != true) {
      return false;
    }
    if (_selectedCategory != null && _selectedCategory != 'All') {
      if (event.eventSubCategory?.eventManagementCategory?.name !=
          _selectedCategory) {
        return false;
      }
    }
    if (_selectedDateRange != null) {
      final eventStart = _parseDateTime(event.eventDate!);
      final eventEnd = _parseDateTime(event.endtime!);
      if (eventEnd.isBefore(_selectedDateRange!.start) ||
          eventStart.isAfter(_selectedDateRange!.end)) {
        return false;
      }
    }
    return true;
  }

  void _applySortingToFilteredEvents() {
    _applySorting(_filteredEvents);
  }

  void _applySortingToSearchResults() {
    _applySorting(_searchResults);
  }

  void _applySorting(List<Event> events) {
    final now = DateTime.now();
    switch (_selectedSortBy) {
      case 'Date':
        _sortEventsByPriority(events);
        break;
      case 'Upcoming':
        events.retainWhere(
                (event) => _parseDateTime(event.endtime!).isAfter(now));
        _sortEventsByPriority(events);
        break;
      case 'This Weekend':
        final nextWeekend = now.add(Duration(days: (6 - now.weekday + 7) % 7));
        final endOfWeekend = nextWeekend.add(const Duration(days: 1));
        events.retainWhere((event) {
          final eventStart = _parseDateTime(event.eventDate!);
          final eventEnd = _parseDateTime(event.endtime!);
          return eventStart.isBefore(endOfWeekend) &&
              eventEnd.isAfter(now);
        });
        _sortEventsByPriority(events);
        break;
      case 'This Week':
        final endOfWeek = now.add(Duration(days: 7 - now.weekday));
        events.retainWhere((event) {
          final eventStart = _parseDateTime(event.eventDate!);
          final eventEnd = _parseDateTime(event.endtime!);
          return eventStart.isBefore(endOfWeek) && eventEnd.isAfter(now);
        });
        _sortEventsByPriority(events);
        break;
    }
  }

  void _sortEventsByPriority(List<Event> events) {
    final now = DateTime.now();
    events.sort((a, b) {
      final aStart = _parseDateTime(a.eventDate!);
      final aEnd = _parseDateTime(a.endtime!);
      final bStart = _parseDateTime(b.eventDate!);
      final bEnd = _parseDateTime(b.endtime!);

      // Check if events are ongoing
      final aOngoing = aStart.isBefore(now) && aEnd.isAfter(now);
      final bOngoing = bStart.isBefore(now) && bEnd.isAfter(now);

      if (aOngoing && !bOngoing) return -1;
      if (!aOngoing && bOngoing) return 1;
      if (aOngoing && bOngoing) {
        // Both ongoing, sort by end time
        return aEnd.compareTo(bEnd);
      }

      // Check if events are in the future
      final aFuture = aStart.isAfter(now);
      final bFuture = bStart.isAfter(now);

      if (aFuture && !bFuture) return -1;
      if (!aFuture && bFuture) return 1;
      if (aFuture && bFuture) {
        // Both in future, sort by start time
        return aStart.compareTo(bStart);
      }

      // Both are past events, sort by end time (most recent first)
      return bEnd.compareTo(aEnd);
    });
  }

  List<Event> getUpcomingEvents({int limit = 5}) {
    final now = DateTime.now();
    final upcomingEvents = _upcomingEvents
        .where((event) => _parseDateTime(event.endtime!).isAfter(now))
        .toList();
    _sortEventsByPriority(upcomingEvents);

    if (limit > 0 && upcomingEvents.length > limit) {
      return upcomingEvents.sublist(0, limit);
    }
    return upcomingEvents;
  }

  Future<void> _loadBookmarkedStates() async {
    for (var event in _allEvents) {
      _bookmarkedEvents[event.eid!] =
      await _bookmarkService.isEventBookmarked(event.eid!);
    }
  }

  Future<void> toggleBookmark(Event event) async {
    await _bookmarkService.toggleBookmark(event);
    _bookmarkedEvents[event.eid!] = !(_bookmarkedEvents[event.eid!] ?? false);
    notifyListeners();
  }

  bool isEventBookmarked(String eventId) {
    return _bookmarkedEvents[eventId] ?? false;
  }

  Future<List<Event>> getBookmarkedEvents() async {
    final events = await _bookmarkService.getBookmarkedEvents();
    _sortEventsByPriority(events);
    return events;
  }

  void removeBookmarkedEvent(Event event) {
    _bookmarkedEvents[event.eid!] = false;
    notifyListeners();
  }

  Future<List<Event>> getEventsByOwner(String s) async {
    final events = await _eventsService.getAllEvents();
    final ownerEvents = events.where((event) => event.rid == s).toList();
    _sortEventsByPriority(ownerEvents);
    return ownerEvents;
  }
}