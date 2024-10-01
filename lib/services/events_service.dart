import 'package:flutter/foundation.dart';
import 'package:pinnket/api/api_service.dart';
import 'package:pinnket/models/event_models.dart';

import '../models/category_models.dart';

class EventsService {
  final ApiService _apiService = ApiService();

  Future<List<Event>> getPaginatedEvents(int start, int end) async {
    try {
      final response =
          await _apiService.get('/api/events/paginated/$start/$end');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> eventsJson = data['Events'];
        return eventsJson.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('Error in getPaginatedEvents: $e');
      rethrow;
    }
  }

  Future<Event> getEventDetails(String eid) async {
    try {
      final response = await _apiService.get('/api/events/details/$eid');

      if (response.statusCode == 200) {
        final Map<String, dynamic> eventData = response.data['eventInfo'];

        return Event.fromJson(eventData);
      } else {
        throw Exception('Failed to load event details');
      }
    } catch (e) {
      print('Error in getEventDetails: $e');
      rethrow;
    }
  }

  Future<List<Event>> getAllEvents() async {
    try {
      final response = await _apiService.get('/api/events/all');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> eventsJson = data['Events'];
        return eventsJson.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('Error in getAllEvents: $e');
      rethrow;
    }
  }

  Future<List<Event>> getPaginatedEventsByCategory(String cid, int start, int end) async {
    try {
      final response = await _apiService.get('/api/events/category/paginated/$cid/$start/$end');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> eventsJson = data['Events'];
        return eventsJson.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events by category');
      }
    } catch (e) {
      print('Error in getPaginatedEventsByCategory: $e');
      rethrow;
    }
  }

  Future<List<Categories>> getEventCategories() async {
    try {
      final response = await _apiService.get('/api/events/management/categories');

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = response.data;
        if (data == null) {
          throw Exception('Response data is null');
        }



        final List<dynamic>? categoriesJson = data['categories'];
        if (categoriesJson == null) {
          throw Exception('Categories data is null');
        }

        return categoriesJson.map((json) => Categories.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load event categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getEventCategories: $e');
      rethrow;
    }
  }
}