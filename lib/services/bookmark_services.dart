import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_models.dart';

class BookmarkService {
  static const String _bookmarksKey = 'bookmarked_events';

  Future<List<Event>> getBookmarkedEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? bookmarksJson = prefs.getString(_bookmarksKey);
      if (bookmarksJson == null) {
        return [];
      }
      final List<dynamic> bookmarksList = json.decode(bookmarksJson);
      return bookmarksList.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      print('Error getting bookmarked events: $e');
      return [];
    }
  }

  Future<void> toggleBookmark(Event event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Event> bookmarkedEvents = await getBookmarkedEvents();

      final index = bookmarkedEvents.indexWhere((e) => e.eid == event.eid);
      if (index != -1) {
        // Event is already bookmarked, remove it
        bookmarkedEvents.removeAt(index);
      } else {
        // Event is not bookmarked, add it
        bookmarkedEvents.add(event);
      }

      final bookmarksJson =
          json.encode(bookmarkedEvents.map((e) => e.toJson()).toList());
      await prefs.setString(_bookmarksKey, bookmarksJson);
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
  }

  Future<bool> isEventBookmarked(String eventId) async {
    try {
      final bookmarkedEvents = await getBookmarkedEvents();
      return bookmarkedEvents.any((event) => event.eid == eventId);
    } catch (e) {
      print('Error checking if event is bookmarked: $e');
      return false;
    }
  }

  Future<void> clearAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookmarksKey);
    } catch (e) {
      print('Error clearing all bookmarks: $e');
    }
  }


  Future<void> removeBookmark(Event event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Event> bookmarkedEvents = await getBookmarkedEvents();

      final index = bookmarkedEvents.indexWhere((e) => e.eid == event.eid);
      if (index != -1) {
        // Event is already bookmarked, remove it
        bookmarkedEvents.removeAt(index);
      }

      final bookmarksJson =
          json.encode(bookmarkedEvents.map((e) => e.toJson()).toList());
      await prefs.setString(_bookmarksKey, bookmarksJson);
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
  }
}
