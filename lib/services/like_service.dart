import 'package:dio/dio.dart';
import '../api/api_service.dart';

class LikeService {
  final ApiService _apiService = ApiService();

  Future<String> likeEvent(String eid, String email, bool like) async {
    try {
      final response = await _apiService.post(
        '/api/events/pinnket/likevent',
        data: {
          'eid': eid,
          'email': email,
          'like': like,
        },
      );

      if (response.statusCode == 201) {
        return response.data['message'];
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error occurred');
      }
    } on DioException catch (e) {
      print('Request failed with status: ${e.response?.statusCode}.');
      var responseJson = e.response?.data;
      throw Exception(responseJson['message']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, List<String>>> getLikedDislikedEvents(String email) async {
    try {
      final response = await _apiService.get(
        '/api/events/pinnket/likeddislikedevents/$email',
      );

      if (response.statusCode == 200) {
        var body = response.data;
        return {
          'likedEventIds': List<String>.from(body['likedEventIds']),
          'dislikedEventIds': List<String>.from(body['dislikedEventIds']),
        };
      } else {
        throw Exception('Failed to get liked/disliked events');
      }
    } on DioException catch (e) {
      print('Request failed with status: ${e.response?.statusCode}.');
      var responseJson = e.response?.data;
      throw Exception(responseJson['message']);
    } catch (e) {
      rethrow;
    }
  }
}