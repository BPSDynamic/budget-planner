import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_planner/features/settings/models/app_settings.dart';
import 'package:budget_planner/features/settings/models/user_profile.dart';
import 'package:budget_planner/features/settings/services/settings_serialization_service.dart';

void main() {
  group('SettingsSerializationService', () {
    group('Property 9: Settings Validation on Deserialization', () {
      /// **Feature: app-settings, Property 9: Settings Validation on Deserialization**
      /// **Validates: Requirements 9.4**
      ///
      /// For any settings deserialized from storage, all required fields SHALL be
      /// present and correctly typed, or deserialization SHALL fail with a validation error.
      test('valid settings deserialize successfully with all fields present', () {
        for (int i = 0; i < 100; i++) {
          final originalSettings = AppSettings(
            userId: 'user_$i',
            currency: i % 3 == 0 ? 'EUR' : i % 3 == 1 ? 'GBP' : 'USD',
            pushNotificationsEnabled: i % 2 == 0,
            emailNotificationsEnabled: i % 2 == 1,
            darkModeEnabled: i % 2 == 0,
            language: i % 3 == 0 ? 'Spanish' : i % 3 == 1 ? 'French' : 'English',
          );

          // Serialize to JSON
          final jsonString =
              SettingsSerializationService.serializeSettings(originalSettings);

          // Deserialize from JSON
          final deserializedSettings =
              SettingsSerializationService.deserializeSettings(jsonString);

          // Verify all fields are present and correctly typed
          expect(deserializedSettings.userId, equals(originalSettings.userId));
          expect(deserializedSettings.currency, equals(originalSettings.currency));
          expect(deserializedSettings.pushNotificationsEnabled,
              equals(originalSettings.pushNotificationsEnabled));
          expect(deserializedSettings.emailNotificationsEnabled,
              equals(originalSettings.emailNotificationsEnabled));
          expect(deserializedSettings.darkModeEnabled,
              equals(originalSettings.darkModeEnabled));
          expect(deserializedSettings.language, equals(originalSettings.language));
        }
      });

      test('deserialization fails when required fields are missing', () {
        final requiredFields = [
          'userId',
          'currency',
          'pushNotificationsEnabled',
          'emailNotificationsEnabled',
          'darkModeEnabled',
          'language',
          'lastUpdated',
        ];

        for (int i = 0; i < requiredFields.length; i++) {
          // Create a valid settings map
          final validMap = {
            'userId': 'user_test',
            'currency': 'USD',
            'pushNotificationsEnabled': true,
            'emailNotificationsEnabled': true,
            'darkModeEnabled': false,
            'language': 'English',
            'lastUpdated': DateTime.now().toIso8601String(),
          };

          // Remove one required field
          final fieldToRemove = requiredFields[i];
          validMap.remove(fieldToRemove);

          final jsonString = jsonEncode(validMap);

          // Deserialization should fail
          expect(
            () => SettingsSerializationService.deserializeSettings(jsonString),
            throwsA(isA<ArgumentError>()),
          );
        }
      });

      test('deserialization fails when field types are incorrect', () {
        for (int i = 0; i < 100; i++) {
          final testCases = [
            {
              'userId': 123, // Should be String
              'currency': 'USD',
              'pushNotificationsEnabled': true,
              'emailNotificationsEnabled': true,
              'darkModeEnabled': false,
              'language': 'English',
              'lastUpdated': DateTime.now().toIso8601String(),
            },
            {
              'userId': 'user_test',
              'currency': 123, // Should be String
              'pushNotificationsEnabled': true,
              'emailNotificationsEnabled': true,
              'darkModeEnabled': false,
              'language': 'English',
              'lastUpdated': DateTime.now().toIso8601String(),
            },
            {
              'userId': 'user_test',
              'currency': 'USD',
              'pushNotificationsEnabled': 'true', // Should be bool
              'emailNotificationsEnabled': true,
              'darkModeEnabled': false,
              'language': 'English',
              'lastUpdated': DateTime.now().toIso8601String(),
            },
            {
              'userId': 'user_test',
              'currency': 'USD',
              'pushNotificationsEnabled': true,
              'emailNotificationsEnabled': 'true', // Should be bool
              'darkModeEnabled': false,
              'language': 'English',
              'lastUpdated': DateTime.now().toIso8601String(),
            },
            {
              'userId': 'user_test',
              'currency': 'USD',
              'pushNotificationsEnabled': true,
              'emailNotificationsEnabled': true,
              'darkModeEnabled': 'false', // Should be bool
              'language': 'English',
              'lastUpdated': DateTime.now().toIso8601String(),
            },
            {
              'userId': 'user_test',
              'currency': 'USD',
              'pushNotificationsEnabled': true,
              'emailNotificationsEnabled': true,
              'darkModeEnabled': false,
              'language': 123, // Should be String
              'lastUpdated': DateTime.now().toIso8601String(),
            },
            {
              'userId': 'user_test',
              'currency': 'USD',
              'pushNotificationsEnabled': true,
              'emailNotificationsEnabled': true,
              'darkModeEnabled': false,
              'language': 'English',
              'lastUpdated': 123, // Should be String (ISO8601)
            },
          ];

          final testCase = testCases[i % testCases.length];
          final jsonString = jsonEncode(testCase);

          // Deserialization should fail due to type mismatch
          expect(
            () => SettingsSerializationService.deserializeSettings(jsonString),
            throwsA(isA<ArgumentError>()),
          );
        }
      });

      test('deserialization fails when lastUpdated is not ISO8601 format', () {
        // Test cases that should fail validation
        final testCases = [
          {
            'userId': 'user_test',
            'currency': 'USD',
            'pushNotificationsEnabled': true,
            'emailNotificationsEnabled': true,
            'darkModeEnabled': false,
            'language': 'English',
            'lastUpdated': '2024-01-01', // Missing time component
          },
          {
            'userId': 'user_test',
            'currency': 'USD',
            'pushNotificationsEnabled': true,
            'emailNotificationsEnabled': true,
            'darkModeEnabled': false,
            'language': 'English',
            'lastUpdated': '01/01/2024', // Wrong format
          },
          {
            'userId': 'user_test',
            'currency': 'USD',
            'pushNotificationsEnabled': true,
            'emailNotificationsEnabled': true,
            'darkModeEnabled': false,
            'language': 'English',
            'lastUpdated': 'invalid-date', // Not a date
          },
          {
            'userId': 'user_test',
            'currency': 'USD',
            'pushNotificationsEnabled': true,
            'emailNotificationsEnabled': true,
            'darkModeEnabled': false,
            'language': 'English',
            'lastUpdated': 'not-a-date-at-all', // Completely invalid
          },
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final jsonString = jsonEncode(testCase);

          // Deserialization should fail
          expect(
            () => SettingsSerializationService.deserializeSettings(jsonString),
            throwsA(isA<ArgumentError>()),
          );
        }
      });

      test('deserialization fails with invalid JSON', () {
        final invalidJsonStrings = [
          '{invalid json}',
          'not json at all',
          '{userId: "user_test"}', // Missing quotes around key
          '{"userId": "user_test"', // Missing closing brace
        ];

        for (int i = 0; i < 100; i++) {
          final invalidJson = invalidJsonStrings[i % invalidJsonStrings.length];

          // Deserialization should fail
          expect(
            () => SettingsSerializationService.deserializeSettings(invalidJson),
            throwsA(isA<FormatException>()),
          );
        }
      });

      test('deserialization fails with empty JSON string', () {
        expect(
          () => SettingsSerializationService.deserializeSettings(''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('valid settings round trip through serialization', () {
        for (int i = 0; i < 100; i++) {
          final originalSettings = AppSettings(
            userId: 'user_$i',
            currency: i % 3 == 0 ? 'EUR' : i % 3 == 1 ? 'GBP' : 'USD',
            pushNotificationsEnabled: i % 2 == 0,
            emailNotificationsEnabled: i % 2 == 1,
            darkModeEnabled: i % 2 == 0,
            language: i % 3 == 0 ? 'Spanish' : i % 3 == 1 ? 'French' : 'English',
          );

          // Serialize
          final jsonString =
              SettingsSerializationService.serializeSettings(originalSettings);

          // Deserialize
          final deserializedSettings =
              SettingsSerializationService.deserializeSettings(jsonString);

          // Verify equality
          expect(deserializedSettings, equals(originalSettings));
        }
      });

      test('serialization fails with null settings', () {
        expect(
          () => SettingsSerializationService.serializeSettings(null),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('UserProfile Serialization', () {
      test('valid user profile deserializes successfully', () {
        for (int i = 0; i < 100; i++) {
          final originalProfile = UserProfile(
            name: 'User $i',
            email: 'user$i@example.com',
            avatarUrl: i % 2 == 0 ? 'https://example.com/avatar$i.jpg' : null,
          );

          // Serialize to JSON
          final jsonString = SettingsSerializationService
              .serializeUserProfile(originalProfile);

          // Deserialize from JSON
          final deserializedProfile = SettingsSerializationService
              .deserializeUserProfile(jsonString);

          // Verify all fields are present and correct
          expect(deserializedProfile.name, equals(originalProfile.name));
          expect(deserializedProfile.email, equals(originalProfile.email));
          expect(deserializedProfile.avatarUrl, equals(originalProfile.avatarUrl));
          expect(deserializedProfile.id, equals(originalProfile.id));
        }
      });

      test('user profile deserialization fails when required fields missing', () {
        final requiredFields = ['id', 'name', 'email', 'createdDate'];

        for (int i = 0; i < requiredFields.length; i++) {
          final validMap = {
            'id': 'profile_id',
            'name': 'Test User',
            'email': 'test@example.com',
            'avatarUrl': null,
            'createdDate': DateTime.now().toIso8601String(),
          };

          // Remove one required field
          final fieldToRemove = requiredFields[i];
          validMap.remove(fieldToRemove);

          final jsonString = jsonEncode(validMap);

          // Deserialization should fail
          expect(
            () => SettingsSerializationService.deserializeUserProfile(jsonString),
            throwsA(isA<ArgumentError>()),
          );
        }
      });

      test('user profile round trip through serialization', () {
        for (int i = 0; i < 100; i++) {
          final originalProfile = UserProfile(
            name: 'User $i',
            email: 'user$i@example.com',
            avatarUrl: i % 2 == 0 ? 'https://example.com/avatar$i.jpg' : null,
          );

          // Serialize
          final jsonString = SettingsSerializationService
              .serializeUserProfile(originalProfile);

          // Deserialize
          final deserializedProfile = SettingsSerializationService
              .deserializeUserProfile(jsonString);

          // Verify equality
          expect(deserializedProfile, equals(originalProfile));
        }
      });
    });
  });
}
