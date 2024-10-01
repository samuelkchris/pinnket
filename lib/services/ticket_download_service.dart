import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../models/ticket_download.dart';

class TicketDownloadService {
  final ApiService _apiService = ApiService();

  Future<TicketResponse> validateOtpAndFetchTickets(
      String otp, String receiptNumber) async {
    try {
      final response = await _apiService.post(
        '/api/events/pinnket/gettickets',
        data: {
          "otp": otp,
          "receiptNumber": receiptNumber,
        },
      );

      if (response.statusCode == 200) {
        return TicketResponse.fromJson(response.data);
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

  Future<String> requestOtp(String receiptNumber) async {
    try {
      final response = await _apiService.post(
        '/api/auth/pinnket/otp',
        data: {"receiptNumber": receiptNumber},
      );
      print("Response: ${response.data}");
      if (response.statusCode == 201 || response.statusCode == 400) {
        final message = response.data['message'];
        return message;
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

