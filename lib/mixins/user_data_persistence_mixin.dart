import 'package:hive/hive.dart';
import 'package:pinnket/models/auth_models.dart';

mixin UserDataPersistenceMixin {
  static const String _boxName = 'userDataBox';
  static const String _loginResponseKey = 'loginResponse';
  static const String _emailKey = 'email';
  static const String _nameKey = 'name';

  Future<void> initHive() async {
    await Hive.openBox(_boxName);
  }

  Future<void> saveUserData(LoginResponse loginResponse, String email) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_loginResponseKey, loginResponse.toJson());
    await box.put(_emailKey, email);
    await box.put(_nameKey, _extractNameFromEmail(email));
  }

  Future<Map<String, dynamic>?> loadUserData() async {
    final box = await Hive.openBox(_boxName);
    final loginResponseJson = box.get(_loginResponseKey);
    final email = box.get(_emailKey);
    final name = box.get(_nameKey);

    if (loginResponseJson != null && email != null) {
      // Safely convert the loginResponseJson to Map<String, dynamic>
      Map<String, dynamic> safeLoginResponseJson = _ensureStringDynamicMap(loginResponseJson);

      return {
        'loginResponse': LoginResponse.fromJson(safeLoginResponseJson),
        'email': email,
        'name': name,
      };
    }
    return null;
  }

  Map<String, dynamic> _ensureStringDynamicMap(dynamic map) {
    if (map is Map<String, dynamic>) {
      return map;
    } else if (map is Map) {
      return map.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _ensureStringDynamicMap(value));
        } else if (value is List) {
          return MapEntry(key.toString(), _ensureStringDynamicList(value));
        } else {
          return MapEntry(key.toString(), value);
        }
      });
    }
    throw ArgumentError('Expected a Map, but got ${map.runtimeType}');
  }

  List<dynamic> _ensureStringDynamicList(List list) {
    return list.map((item) {
      if (item is Map) {
        return _ensureStringDynamicMap(item);
      } else if (item is List) {
        return _ensureStringDynamicList(item);
      } else {
        return item;
      }
    }).toList();
  }

  Future<void> clearUserData() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }

  String _extractNameFromEmail(String email) {
    return email.split('@').first;
  }
}