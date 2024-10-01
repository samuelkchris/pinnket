import 'package:flutter/foundation.dart';
import 'package:pinnket/models/auth_models.dart';
import 'package:pinnket/mixins/user_data_persistence_mixin.dart';

class UserProvider extends ChangeNotifier with UserDataPersistenceMixin {
  LoginResponse? _loginResponse;
  String? _email;
  String? _name;
  String _otp = '';

  LoginResponse? get loginResponse => _loginResponse;

  String? get email => _email;

  String? get name => _name;

  UserProvider() {
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    await initHive();
    final userData = await loadUserData();
    if (userData != null) {
      _loginResponse = userData['loginResponse'];
      _email = userData['email'];
      _name = userData['name'];
      notifyListeners();
    }
  }

  Future<void> setLoginResponse(LoginResponse response, String email) async {
    _loginResponse = response;
    _email = email;
    _name = _extractNameFromEmail(email);
    await saveUserData(response, email);
    notifyListeners();
  }

  String _extractNameFromEmail(String email) {
    return email.split('@').first;
  }

  Future<void> clearLoginResponse() async {
    _loginResponse = null;
    _email = null;
    _name = null;
    await clearUserData();
    notifyListeners();
  }

  void logout() {
    clearLoginResponse();
  }

  void setOtp(String otp) {
    _otp = otp;
    notifyListeners();
  }
}
