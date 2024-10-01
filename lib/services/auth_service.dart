import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pinnket/api/api_service.dart';

import '../models/auth_models.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<String> requestLoginOtp(String email) async {
    try {
      final response = await _apiService.post(
        '/api/auth/pinnket/profile/otp',
        data: {"email": email},
      );

      if (response.statusCode == 201) {
        final String message = response.data['message'];
        if (kDebugMode) {
          print(message);
        }
        return message;
      } else {
        final String message = response.data['message'];
        if (kDebugMode) {
          print('Request failed with status: ${response.statusCode}.');
        }
        throw Exception(message);
      }
    } on DioException catch (e) {
      print('Request failed with status: ${e.response?.statusCode}.');
      var responseJson = e.response?.data;
      throw Exception(responseJson['message']);
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResponse> login(String email, String otp) async {
    try {
      final response = await _apiService.post(
        '/api/events/pinnket/profile/login',
        data: {"email": email, "otp": otp},
      );

      if (response.statusCode == 201) {
        final loginResponse = LoginResponse.fromJson(response.data);
        if (kDebugMode) {
          print('Login successful: ${loginResponse.message}');
        }
        return loginResponse;
      } else {
        final String message = response.data['message'];
        if (kDebugMode) {
          print('Login failed with status: ${response.statusCode}.');
        }
        throw Exception(message);
      }
    } on DioException catch (e) {
      print('Login request failed with status: ${e.response?.statusCode}.');
      var responseJson = e.response?.data;
      throw Exception(responseJson['message']);
    } catch (e) {
      rethrow;
    }
  }
}
