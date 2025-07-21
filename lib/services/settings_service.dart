import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _themeKey = 'theme_mode';
  static const String _userNameKey = 'user_name';
  static const String _autoConnectKey = 'auto_connect';
  static const String _soundEnabledKey = 'sound_enabled';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Theme settings
  Future<String?> getThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(_themeKey);
  }

  Future<void> setThemeMode(String themeMode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeKey, themeMode);
  }

  // User name
  Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_userNameKey);
  }

  Future<void> setUserName(String userName) async {
    final prefs = await _prefs;
    await prefs.setString(_userNameKey, userName);
  }

  // Auto connect setting
  Future<bool> getAutoConnect() async {
    final prefs = await _prefs;
    return prefs.getBool(_autoConnectKey) ?? false;
  }

  Future<void> setAutoConnect(bool autoConnect) async {
    final prefs = await _prefs;
    await prefs.setBool(_autoConnectKey, autoConnect);
  }

  // Sound settings
  Future<bool> getSoundEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool soundEnabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_soundEnabledKey, soundEnabled);
  }

  // Device custom names
  Future<String?> getDeviceCustomName(String deviceId) async {
    final prefs = await _prefs;
    return prefs.getString('device_name_$deviceId');
  }

  Future<void> setDeviceCustomName(String deviceId, String customName) async {
    final prefs = await _prefs;
    await prefs.setString('device_name_$deviceId', customName);
  }

  Future<void> removeDeviceCustomName(String deviceId) async {
    final prefs = await _prefs;
    await prefs.remove('device_name_$deviceId');
  }
}