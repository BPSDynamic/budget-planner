import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';

class SettingsProvider with ChangeNotifier {
  UserProfile? _userProfile;
  AppSettings? _appSettings;

  UserProfile? get userProfile => _userProfile;
  AppSettings? get appSettings => _appSettings;

  String get currency => _appSettings?.currency ?? 'USD';
  bool get pushNotificationsEnabled =>
      _appSettings?.pushNotificationsEnabled ?? true;
  bool get emailNotificationsEnabled =>
      _appSettings?.emailNotificationsEnabled ?? true;
  bool get darkModeEnabled => _appSettings?.darkModeEnabled ?? false;
  String get language => _appSettings?.language ?? 'English';

  // Getter methods
  UserProfile? getUserProfile() => _userProfile;
  String getCurrency() => currency;
  bool getPushNotificationsEnabled() => pushNotificationsEnabled;
  bool getEmailNotificationsEnabled() => emailNotificationsEnabled;
  bool getDarkModeEnabled() => darkModeEnabled;
  String getLanguage() => language;

  SettingsProvider() {
    _initializeSettings();
  }

  void _initializeSettings() {
    try {
      _loadSettings();
    } catch (e) {
      // Silently handle initialization errors
    }
  }

  // User Profile Methods
  Future<void> updateUserProfile({
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    if (_userProfile == null) {
      _userProfile = UserProfile(
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );
    } else {
      _userProfile = _userProfile!.copyWith(
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );
    }
    await _saveSettings();
    notifyListeners();
  }

  // Currency Methods
  Future<void> setCurrency(String currency) async {
    if (_appSettings == null) {
      _appSettings = AppSettings(userId: _userProfile?.id ?? 'default');
    }
    _appSettings = _appSettings!.copyWith(currency: currency);
    await _saveSettings();
    notifyListeners();
  }

  // Push Notification Methods
  Future<void> setPushNotificationsEnabled(bool enabled) async {
    if (_appSettings == null) {
      _appSettings = AppSettings(userId: _userProfile?.id ?? 'default');
    }
    _appSettings = _appSettings!.copyWith(pushNotificationsEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  // Email Notification Methods
  Future<void> setEmailNotificationsEnabled(bool enabled) async {
    if (_appSettings == null) {
      _appSettings = AppSettings(userId: _userProfile?.id ?? 'default');
    }
    _appSettings = _appSettings!.copyWith(emailNotificationsEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  // Dark Mode Methods
  Future<void> setDarkModeEnabled(bool enabled) async {
    if (_appSettings == null) {
      _appSettings = AppSettings(userId: _userProfile?.id ?? 'default');
    }
    _appSettings = _appSettings!.copyWith(darkModeEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    final newState = !darkModeEnabled;
    await setDarkModeEnabled(newState);
  }

  // Language Methods
  Future<void> setLanguage(String language) async {
    if (_appSettings == null) {
      _appSettings = AppSettings(userId: _userProfile?.id ?? 'default');
    }
    _appSettings = _appSettings!.copyWith(language: language);
    await _saveSettings();
    notifyListeners();
  }

  // Logout Method
  Future<void> logout() async {
    _userProfile = null;
    _appSettings = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    await prefs.remove('app_settings');
    notifyListeners();
  }

  // Persistence Methods
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (_userProfile != null) {
      final profileJson = jsonEncode(_userProfile!.toMap());
      await prefs.setString('user_profile', profileJson);
    }

    if (_appSettings != null) {
      final settingsJson = jsonEncode(_appSettings!.toMap());
      await prefs.setString('app_settings', settingsJson);
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load user profile
    final profileString = prefs.getString('user_profile');
    if (profileString != null) {
      try {
        final profileMap = jsonDecode(profileString);
        _userProfile = UserProfile.fromMap(profileMap);
      } catch (e) {
        // Handle error silently
      }
    }

    // Load app settings
    final settingsString = prefs.getString('app_settings');
    if (settingsString != null) {
      try {
        final settingsMap = jsonDecode(settingsString);
        _appSettings = AppSettings.fromMap(settingsMap);
      } catch (e) {
        // Handle error silently
      }
    } else {
      // Initialize with default settings if none exist
      _appSettings = AppSettings(userId: _userProfile?.id ?? 'default');
    }

    notifyListeners();
  }
}
