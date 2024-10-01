import 'package:dio/dio.dart';

import '../api/api_service.dart';

class TicketTransferService {
  final ApiService _apiService = ApiService();

  Future<dynamic> isFirstTransfer(String ticketNumber) async {
    try {
      var response = await _apiService
          .get('/api/events/pinnket/isfirsttransfer/$ticketNumber');

      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print('Request failed with status: ${e.response?.statusCode}.');
      return e.response?.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> initiateTicketTransfer(String oldTicketNumber,
      String receiverEmail, String receiverName, String receiverPhone,
      {String? provider,
      String? phoneNumber,
      String? payerName,
      required bool isCard}) async {
    var body = {
      "oldTicketNumber": oldTicketNumber,
      "receiverEmail": receiverEmail,
      "receiverName": receiverName,
      "receiverPhone": receiverPhone,
      if (provider != null) "provider": provider,
      if (phoneNumber != null) "phoneNumber": phoneNumber,
      if (payerName != null) "payerName": payerName,
    };

    try {
      var response = await _apiService.post(
        isCard
            ? '/api/events/pinnket/initiateTicketTransfer/dpo'
            : '/api/events/pinnket/initiateTicketTransfer',
        data: body,
      );

      return response.data['message'] ?? response.data['URL'];
    } on DioException catch (e) {
      print('Request failed with status: ${e.response?.statusCode}.');
      var message = e.response?.data['message'];

      throw Exception(message);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> confirmTicketTransfer(String oldTicketNumber,
      String receiverEmail, String transferSecret) async {
    var body = {
      "oldTicketNumber": oldTicketNumber,
      "receiverEmail": receiverEmail,
      "transferSecret": transferSecret,
    };

    try {
      var response = await _apiService.post(
        '/api/events/pinnket/confirmTicketTransfer',
        data: body,
      );

      return response.data['message'];
    } on DioException catch (e) {
      print('Request failed with status: ${e.response?.statusCode}.');
      var responseJson = e.response?.data;
      throw Exception(responseJson['message']);
    } catch (e) {
      rethrow;
    }
  }
}
