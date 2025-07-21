import 'package:flutter/material.dart';
import 'package:whisperwind/services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  ThemeMode _themeMode = ThemeMode.system;
  String _userName = '';
  bool _autoConnect = false;
  bool _soundEnabled = true;

  ThemeMode get themeMode => _themeMode;
  String get userName => _userName;
  bool get autoConnect => _autoConnect;
  bool get soundEnabled => _soundEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeString = await _settingsService.getThemeMode();
    if (themeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeString,
        orElse: () => ThemeMode.system,
      );
    }

    _userName = await _settingsService.getUserName() ?? '';
    _autoConnect = await _settingsService.getAutoConnect();
    _soundEnabled = await _settingsService.getSoundEnabled();

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _settingsService.setThemeMode(mode.toString());
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _settingsService.setUserName(name);
    notifyListeners();
  }

  Future<void> setAutoConnect(bool value) async {
    _autoConnect = value;
    await _settingsService.setAutoConnect(value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _settingsService.setSoundEnabled(value);
    notifyListeners();
  }

  Future<String?> getDeviceCustomName(String deviceId) async {
    return await _settingsService.getDeviceCustomName(deviceId);
  }

  Future<void> setDeviceCustomName(String deviceId, String customName) async {
    await _settingsService.setDeviceCustomName(deviceId, customName);
  }
}