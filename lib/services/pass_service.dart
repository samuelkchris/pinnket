import 'package:dio/dio.dart';

import '../api/api_service.dart';
import '../models/pass_model.dart';

class PassService {
  final ApiService _apiService = ApiService();

  Future<PassInfo> validatePass(String tagcode) async {
    try {
      final response = await _apiService.post(
        '/api/events/pinnket/pass/validate',
        data: {
          'tagcode': tagcode,
        },
      );

      if (response.statusCode == 200) {
        return PassInfo.fromJson(response.data['passInfo']);
      } else {
        final message = response.data['message'];
        throw Exception(message ?? 'Unknown error occurred');
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
