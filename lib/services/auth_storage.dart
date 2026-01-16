import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _kAccessToken = 'access_token';
  static const _kMustChangePassword = 'must_change_password';

  Future<void> saveLogin({required String accessToken, required bool mustChangePassword}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessToken, accessToken);
    await prefs.setBool(_kMustChangePassword, mustChangePassword);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccessToken);
  }

  Future<bool> getMustChangePassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kMustChangePassword) ?? false;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessToken);
    await prefs.remove(_kMustChangePassword);
  }
}
