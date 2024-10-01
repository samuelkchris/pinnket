import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/donation_models.dart';

class DonationService {
  final ApiService _apiService = ApiService();
  final String initiateDonationUrl = '/api/billing/donation/initiate';
  final String initiateDonationDpoUrl = '/api/billing/donation/initiate/dpo';
  final String donationDetailsUrl = '/api/billing/donation/details/pinnket/';

  Future<String> initiateDonation({
    required String eid,
    required String name,
    required String email,
    required String phone,
    required String amount,
    required int tipAmount,
    required String provider,
  }) async {
    try {
      final response = await _apiService.post(
        initiateDonationUrl,
        data: {
          "eid": eid,
          "name": name,
          "email": email,
          "phone": phone,
          "amount": amount,
          "tipAmount": tipAmount,
          "provider": provider,
        },
      );

      if (response.statusCode == 201) {
        if (kDebugMode) {
          print("Donation initiated successfully: ${response.data}");
        }
        return response.data['message'] as String;
      } else {
        if (kDebugMode) {
          print("Donation initiated successfully: ${response.data}");
        }
        final message = response.data['message'] as String;
        throw Exception(message ?? 'Unknown error occurred');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Request failed with status: ${e.response?.statusCode}.');
      }
      var responseJson = e.response?.data;
      throw Exception(responseJson['message'] as String);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> initiateDonationDpo({
    required String eid,
    required String name,
    required String email,
    required String phone,
    required String amount,
    required int tipAmount,
  }) async {
    try {
      final response = await _apiService.post(
        initiateDonationDpoUrl,
        data: {
          "eid": eid,
          "name": name,
          "email": email,
          "phone": phone,
          "amount": amount,
          "tipAmount": tipAmount,
        },
      );

      if (response.statusCode == 201) {
        if (kDebugMode) {
          print("Donation via DPO initiated successfully: ${response.data}");
        }
        return response.data['URL'] as String;
      } else {
        if (kDebugMode) {
          print("Donation via DPO initiated successfully: ${response.data}");
        }
        final message = response.data['message'] as String;
        throw Exception(message ?? 'Unknown error occurred');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Request failed with status: ${e.response?.statusCode}.');
      }
      var responseJson = e.response?.data;
      throw Exception(responseJson['message'] as String);
    } catch (e) {
      rethrow;
    }
  }

  Future<DonationDetails> getDonationDetails(String eid) async {
    try {
      final response = await _apiService.get('$donationDetailsUrl$eid');

      if (response.statusCode == 200) {
        return DonationDetails.fromJson(response.data);
      } else {
        final message = response.data['message'] as String;
        throw Exception(message ?? 'Unknown error occurred');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Request failed with status: ${e.response?.statusCode}.');
      }
      var responseJson = e.response?.data;
      throw Exception(responseJson['message'] as String);
    } catch (e) {
      rethrow;
    }
  }
}
