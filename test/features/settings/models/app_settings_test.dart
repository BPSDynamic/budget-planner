import 'package:flutter_test/flutter_test.dart';
import 'package:budget_planner/features/settings/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    group('Property 7: Settings Round Trip Serialization', () {
      /// **Feature: app-settings, Property 7: Settings Round Trip Serialization**
      /// **Validates: Requirements 8.5, 9.5**
      /// 
      /// For any app settings serialized to JSON and then deserialized, 
      /// the reconstructed settings SHALL be equivalent to the original 
      /// settings before serialization.
      test('serialization round trip preserves all settings', () {
        // Run property test with 100 iterations
        for (int i = 0; i < 100; i++) {
          // Generate random settings
          final originalSettings = AppSettings(
            userId: 'user_$i',
            currency: i % 3 == 0 ? 'EUR' : i % 3 == 1 ? 'GBP' : 'USD',
            pushNotificationsEnabled: i % 2 == 0,
            emailNotificationsEnabled: i % 2 == 1,
            darkModeEnabled: i % 2 == 0,
            language: i % 3 == 0 ? 'Spanish' : i % 3 == 1 ? 'French' : 'English',
          );

          // Serialize to map
          final map = originalSettings.toMap();

          // Deserialize from map
          final deserializedSettings = AppSettings.fromMap(map);

          // Verify round trip preserves all data
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

      test('settings equality works correctly after round trip', () {
        for (int i = 0; i < 100; i++) {
          final originalSettings = AppSettings(
            userId: 'user_$i',
            currency: 'USD',
            pushNotificationsEnabled: true,
            emailNotificationsEnabled: false,
            darkModeEnabled: i % 2 == 0,
            language: 'English',
          );

          final map = originalSettings.toMap();
          final deserializedSettings = AppSettings.fromMap(map);

          // Settings should be equal after round trip
          expect(deserializedSettings, equals(originalSettings));
        }
      });

      test('copyWith preserves serialization integrity', () {
        for (int i = 0; i < 100; i++) {
          final originalSettings = AppSettings(
            userId: 'user_original',
            currency: 'USD',
            pushNotificationsEnabled: true,
            emailNotificationsEnabled: true,
            darkModeEnabled: false,
            language: 'English',
          );

          // Modify settings using copyWith
          final modifiedSettings = originalSettings.copyWith(
            currency: i % 2 == 0 ? 'EUR' : 'GBP',
            darkModeEnabled: i % 2 == 0,
            language: i % 2 == 0 ? 'Spanish' : 'French',
          );

          // Serialize and deserialize modified settings
          final map = modifiedSettings.toMap();
          final deserializedSettings = AppSettings.fromMap(map);

          // Verify modified data is preserved
          expect(deserializedSettings.currency,
              equals(i % 2 == 0 ? 'EUR' : 'GBP'));
          expect(deserializedSettings.darkModeEnabled, equals(i % 2 == 0));
          expect(deserializedSettings.language,
              equals(i % 2 == 0 ? 'Spanish' : 'French'));
          expect(deserializedSettings.userId, equals('user_original'));
          expect(deserializedSettings.pushNotificationsEnabled, equals(true));
          expect(deserializedSettings.emailNotificationsEnabled, equals(true));
        }
      });

      test('default values are preserved in round trip', () {
        for (int i = 0; i < 100; i++) {
          // Create settings with minimal parameters (using defaults)
          final originalSettings = AppSettings(
            userId: 'user_$i',
          );

          final map = originalSettings.toMap();
          final deserializedSettings = AppSettings.fromMap(map);

          // Verify defaults are preserved
          expect(deserializedSettings.currency, equals('USD'));
          expect(deserializedSettings.pushNotificationsEnabled, equals(true));
          expect(deserializedSettings.emailNotificationsEnabled, equals(true));
          expect(deserializedSettings.darkModeEnabled, equals(false));
          expect(deserializedSettings.language, equals('English'));
        }
      });
    });
  });
}
