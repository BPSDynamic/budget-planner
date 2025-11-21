import 'dart:convert';
import '../models/app_settings.dart';
import '../models/user_profile.dart';

class SettingsSerializationService {
  /// Serializes AppSettings to JSON string with all fields
  /// 
  /// Converts an AppSettings object to a JSON-encoded string containing
  /// all preference fields (notifications, theme, language, currency).
  /// 
  /// Throws [ArgumentError] if settings is null
  static String serializeSettings(AppSettings? settings) {
    if (settings == null) {
      throw ArgumentError('Settings cannot be null');
    }
    
    final map = settings.toMap();
    return jsonEncode(map);
  }

  /// Deserializes JSON string to AppSettings with validation
  /// 
  /// Reconstructs an AppSettings object from a JSON-encoded string.
  /// Validates that all required fields are present and correctly typed
  /// before reconstruction.
  /// 
  /// Throws [FormatException] if JSON is invalid
  /// Throws [ArgumentError] if required fields are missing or incorrectly typed
  static AppSettings deserializeSettings(String jsonString) {
    if (jsonString.isEmpty) {
      throw ArgumentError('JSON string cannot be empty');
    }

    Map<String, dynamic> map;
    try {
      map = jsonDecode(jsonString);
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }

    // Validate the deserialized map
    _validateSettings(map);

    // Reconstruct AppSettings from validated map
    return AppSettings.fromMap(map);
  }

  /// Validates that all required fields are present and correctly typed
  /// 
  /// Checks for:
  /// - Presence of all required fields
  /// - Correct types for each field
  /// 
  /// Throws [ArgumentError] if validation fails
  static void _validateSettings(Map<String, dynamic> map) {
    // Check for required fields
    const requiredFields = [
      'userId',
      'currency',
      'pushNotificationsEnabled',
      'emailNotificationsEnabled',
      'darkModeEnabled',
      'language',
      'lastUpdated',
    ];

    for (final field in requiredFields) {
      if (!map.containsKey(field)) {
        throw ArgumentError('Missing required field: $field');
      }
    }

    // Validate field types
    if (map['userId'] is! String) {
      throw ArgumentError('Field userId must be a String');
    }

    if (map['currency'] is! String) {
      throw ArgumentError('Field currency must be a String');
    }

    if (map['pushNotificationsEnabled'] is! bool) {
      throw ArgumentError('Field pushNotificationsEnabled must be a bool');
    }

    if (map['emailNotificationsEnabled'] is! bool) {
      throw ArgumentError('Field emailNotificationsEnabled must be a bool');
    }

    if (map['darkModeEnabled'] is! bool) {
      throw ArgumentError('Field darkModeEnabled must be a bool');
    }

    if (map['language'] is! String) {
      throw ArgumentError('Field language must be a String');
    }

    if (map['lastUpdated'] is! String) {
      throw ArgumentError('Field lastUpdated must be a String (ISO8601 format)');
    }

    // Validate ISO8601 date format (must include time component)
    final dateString = map['lastUpdated'];
    // Ensure it has time component (contains 'T' or space)
    if (!dateString.contains('T') && !dateString.contains(' ')) {
      throw ArgumentError('Field lastUpdated must include time component');
    }
    try {
      DateTime.parse(dateString);
    } catch (e) {
      throw ArgumentError('Field lastUpdated must be in ISO8601 format: $e');
    }
  }

  /// Serializes UserProfile to JSON string
  static String serializeUserProfile(UserProfile? profile) {
    if (profile == null) {
      throw ArgumentError('Profile cannot be null');
    }

    final map = profile.toMap();
    return jsonEncode(map);
  }

  /// Deserializes JSON string to UserProfile with validation
  static UserProfile deserializeUserProfile(String jsonString) {
    if (jsonString.isEmpty) {
      throw ArgumentError('JSON string cannot be empty');
    }

    Map<String, dynamic> map;
    try {
      map = jsonDecode(jsonString);
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }

    // Validate the deserialized map
    _validateUserProfile(map);

    // Reconstruct UserProfile from validated map
    return UserProfile.fromMap(map);
  }

  /// Validates that all required fields are present and correctly typed for UserProfile
  static void _validateUserProfile(Map<String, dynamic> map) {
    const requiredFields = [
      'id',
      'name',
      'email',
      'createdDate',
    ];

    for (final field in requiredFields) {
      if (!map.containsKey(field)) {
        throw ArgumentError('Missing required field: $field');
      }
    }

    // Validate field types
    if (map['id'] is! String) {
      throw ArgumentError('Field id must be a String');
    }

    if (map['name'] is! String) {
      throw ArgumentError('Field name must be a String');
    }

    if (map['email'] is! String) {
      throw ArgumentError('Field email must be a String');
    }

    if (map['createdDate'] is! String) {
      throw ArgumentError('Field createdDate must be a String (ISO8601 format)');
    }

    // Validate ISO8601 date format (must include time component)
    final dateString = map['createdDate'];
    // Ensure it has time component (contains 'T' or space)
    if (!dateString.contains('T') && !dateString.contains(' ')) {
      throw ArgumentError('Field createdDate must include time component');
    }
    try {
      DateTime.parse(dateString);
    } catch (e) {
      throw ArgumentError('Field createdDate must be in ISO8601 format: $e');
    }

    // avatarUrl is optional, but if present must be a String
    if (map.containsKey('avatarUrl') && map['avatarUrl'] != null) {
      if (map['avatarUrl'] is! String) {
        throw ArgumentError('Field avatarUrl must be a String or null');
      }
    }
  }
}
