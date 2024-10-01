import 'package:dio/dio.dart';

import '../api/api_service.dart';
import '../models/ticket_verification.dart';

class TicketVerificationService {
  final ApiService _apiService = ApiService();

  Future<TicketVerificationResponse> verifyTicket(String ticketNumber) async {
    try {
      final response = await _apiService.get(
        '/api/events/pinnket/validateticket/$ticketNumber',
      );

      if (response.statusCode == 200) {
        return TicketVerificationResponse.fromJson(response.data);
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
