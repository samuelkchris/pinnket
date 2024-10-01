import 'package:dio/dio.dart';
import '../api/api_service.dart';

class TicketPurchaseService {
  final ApiService _apiService = ApiService();
  final String url = '/api/billing/pinnket/purchaseticket';

  Future<String> purchaseTicket({
    required String zid,
    required String ticketNumber,
    required String name,
    required String email,
    required String phone,
    required String provider,
    required bool sendOnMail,
    required bool sendOnPhone,
    required String amount,
  }) async {
    try {
      final response = await _apiService.post(
        url,
        data: {
          "zid": zid,
          "ticketNumber": ticketNumber,
          "name": name,
          "email": email,
          "phone": phone,
          "provider": provider,
          "sendOnMail": sendOnMail,
          "sendOnPhone": sendOnPhone,
          "amount": amount,
        },
      );

      if (response.statusCode == 201) {
        return response.data['message'];
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

  Future<String> purchaseTicketDPO({
    required String zid,
    required String ticketNumber,
    required String name,
    required String email,
    required String phone,
    required bool sendOnMail,
    required bool sendOnPhone,
    required String amount,
  }) async {
    const String url = '/api/billing/pinnket/purchaseticket/dpo';
    try {
      final response = await _apiService.post(
        url,
        data: {
          "zid": zid,
          "ticketNumber": ticketNumber,
          "name": name,
          "email": email,
          "phone": phone,
          "sendOnMail": sendOnMail,
          "sendOnPhone": sendOnPhone,
          "amount": amount,
        },
      );

      if (response.statusCode == 201) {
        return response.data['URL'];
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
