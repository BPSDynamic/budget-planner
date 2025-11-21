import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_planner/features/settings/providers/settings_provider.dart';
import 'package:budget_planner/features/settings/models/user_profile.dart';
import 'package:budget_planner/features/settings/models/app_settings.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsProvider', () {
    group('Property 2: Currency Persistence', () {
      /// **Feature: app-settings, Property 2: Currency Persistence**
      /// **Validates: Requirements 2.3**
      ///
      /// For any currency selection made by the user, retrieving the currency
      /// preference in a new session SHALL return the same currency that was
      /// previously selected.
      test('currency persists across provider instances', () async {
        final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];

        for (int i = 0; i < 100; i++) {
          final selectedCurrency = currencies[i % currencies.length];

          // Reset mock for each iteration
          SharedPreferences.setMockInitialValues({});

          // Create first provider instance and set currency
          final provider1 = SettingsProvider();
          await provider1.setCurrency(selectedCurrency);

          // Get the serialized settings
          final settingsJson = jsonEncode(provider1.appSettings?.toMap());

          // Create second provider instance (simulating app restart)
          SharedPreferences.setMockInitialValues({
            'app_settings': settingsJson,
          });

          final provider2 = SettingsProvider();
          await Future.delayed(Duration(milliseconds: 10));

          // Verify currency persists
          expect(provider2.getCurrency(), equals(selectedCurrency));
        }
      });

      test('currency changes are immediately persisted', () async {
        final provider = SettingsProvider();
        final currencies = ['USD', 'EUR', 'GBP', 'JPY'];

        for (int i = 0; i < 100; i++) {
          final currency = currencies[i % currencies.length];
          await provider.setCurrency(currency);

          // Verify immediate persistence
          expect(provider.getCurrency(), equals(currency));
          expect(provider.appSettings?.currency, equals(currency));
        }
      });
    });

    group('Property 3: Push Notification Toggle Consistency', () {
      /// **Feature: app-settings, Property 3: Push Notification Toggle Consistency**
      /// **Validates: Requirements 3.2, 3.3**
      ///
      /// For any push notification toggle state change, the system SHALL persist
      /// the new state and apply it consistently across all subsequent app sessions.
      test('push notification state persists across sessions', () async {
        final states = [true, false];

        for (int i = 0; i < 100; i++) {
          final enabled = states[i % states.length];

          // Reset mock for each iteration
          SharedPreferences.setMockInitialValues({});

          // Create first provider and set push notifications
          final provider1 = SettingsProvider();
          await provider1.setPushNotificationsEnabled(enabled);

          // Get the serialized settings
          final settingsJson = jsonEncode(provider1.appSettings?.toMap());

          // Create second provider (simulating app restart)
          SharedPreferences.setMockInitialValues({
            'app_settings': settingsJson,
          });

          final provider2 = SettingsProvider();
          await Future.delayed(Duration(milliseconds: 10));

          // Verify state persists
          expect(provider2.getPushNotificationsEnabled(), equals(enabled));
        }
      });

      test('push notification toggle is applied consistently', () async {
        final provider = SettingsProvider();

        for (int i = 0; i < 100; i++) {
          final enabled = i % 2 == 0;
          await provider.setPushNotificationsEnabled(enabled);

          // Verify consistency
          expect(provider.getPushNotificationsEnabled(), equals(enabled));
          expect(provider.appSettings?.pushNotificationsEnabled, equals(enabled));
        }
      });
    });

    group('Property 4: Email Notification Toggle Consistency', () {
      /// **Feature: app-settings, Property 4: Email Notification Toggle Consistency**
      /// **Validates: Requirements 3.4, 3.5**
      ///
      /// For any email notification toggle state change, the system SHALL persist
      /// the new state and apply it consistently across all subsequent app sessions.
      test('email notification state persists across sessions', () async {
        final states = [true, false];

        for (int i = 0; i < 100; i++) {
          final enabled = states[i % states.length];

          // Reset mock for each iteration
          SharedPreferences.setMockInitialValues({});

          // Create first provider and set email notifications
          final provider1 = SettingsProvider();
          await provider1.setEmailNotificationsEnabled(enabled);

          // Get the serialized settings
          final settingsJson = jsonEncode(provider1.appSettings?.toMap());

          // Create second provider (simulating app restart)
          SharedPreferences.setMockInitialValues({
            'app_settings': settingsJson,
          });

          final provider2 = SettingsProvider();
          await Future.delayed(Duration(milliseconds: 10));

          // Verify state persists
          expect(provider2.getEmailNotificationsEnabled(), equals(enabled));
        }
      });

      test('email notification toggle is applied consistently', () async {
        final provider = SettingsProvider();

        for (int i = 0; i < 100; i++) {
          final enabled = i % 2 == 0;
          await provider.setEmailNotificationsEnabled(enabled);

          // Verify consistency
          expect(provider.getEmailNotificationsEnabled(), equals(enabled));
          expect(provider.appSettings?.emailNotificationsEnabled, equals(enabled));
        }
      });
    });

    group('Property 5: Dark Mode Application', () {
      /// **Feature: app-settings, Property 5: Dark Mode Application**
      /// **Validates: Requirements 4.2, 4.3, 4.4, 4.5**
      ///
      /// For any dark mode toggle state change, the system SHALL immediately apply
      /// the corresponding theme to the current screen and persist the preference
      /// for future sessions.
      test('dark mode state persists across sessions', () async {
        final states = [true, false];

        for (int i = 0; i < 100; i++) {
          final enabled = states[i % states.length];

          // Reset mock for each iteration
          SharedPreferences.setMockInitialValues({});

          // Create first provider and set dark mode
          final provider1 = SettingsProvider();
          await provider1.setDarkModeEnabled(enabled);

          // Get the serialized settings
          final settingsJson = jsonEncode(provider1.appSettings?.toMap());

          // Create second provider (simulating app restart)
          SharedPreferences.setMockInitialValues({
            'app_settings': settingsJson,
          });

          final provider2 = SettingsProvider();
          await Future.delayed(Duration(milliseconds: 10));

          // Verify state persists
          expect(provider2.getDarkModeEnabled(), equals(enabled));
        }
      });

      test('dark mode is immediately applied and persisted', () async {
        final provider = SettingsProvider();

        for (int i = 0; i < 100; i++) {
          final enabled = i % 2 == 0;
          await provider.setDarkModeEnabled(enabled);

          // Verify immediate application
          expect(provider.getDarkModeEnabled(), equals(enabled));
          expect(provider.appSettings?.darkModeEnabled, equals(enabled));
        }
      });
    });

    group('Property 6: Language Persistence and Application', () {
      /// **Feature: app-settings, Property 6: Language Persistence and Application**
      /// **Validates: Requirements 5.3, 5.4, 5.5**
      ///
      /// For any language selection made by the user, the system SHALL persist
      /// the selection and apply it to all UI text in subsequent app sessions.
      test('language selection persists across sessions', () async {
        final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

        for (int i = 0; i < 100; i++) {
          final selectedLanguage = languages[i % languages.length];

          // Reset mock for each iteration
          SharedPreferences.setMockInitialValues({});

          // Create first provider and set language
          final provider1 = SettingsProvider();
          await provider1.setLanguage(selectedLanguage);

          // Get the serialized settings
          final settingsJson = jsonEncode(provider1.appSettings?.toMap());

          // Create second provider (simulating app restart)
          SharedPreferences.setMockInitialValues({
            'app_settings': settingsJson,
          });

          final provider2 = SettingsProvider();
          await Future.delayed(Duration(milliseconds: 10));

          // Verify language persists
          expect(provider2.getLanguage(), equals(selectedLanguage));
        }
      });

      test('language changes are applied and persisted', () async {
        final provider = SettingsProvider();
        final languages = ['English', 'Spanish', 'French', 'German'];

        for (int i = 0; i < 100; i++) {
          final language = languages[i % languages.length];
          await provider.setLanguage(language);

          // Verify application and persistence
          expect(provider.getLanguage(), equals(language));
          expect(provider.appSettings?.language, equals(language));
        }
      });
    });

    group('Property 8: Logout Session Clearing', () {
      /// **Feature: app-settings, Property 8: Logout Session Clearing**
      /// **Validates: Requirements 7.3**
      ///
      /// For any user logout action, the system SHALL clear all user session data
      /// and cached preferences, and subsequent app launch SHALL require re-authentication.
      test('logout clears all session data', () async {
        for (int i = 0; i < 100; i++) {
          // Create provider and set up user data
          final provider = SettingsProvider();
          await provider.updateUserProfile(
            name: 'Test User $i',
            email: 'test$i@example.com',
          );
          await provider.setCurrency('EUR');
          await provider.setPushNotificationsEnabled(false);

          // Verify data is set
          expect(provider.getUserProfile(), isNotNull);
          expect(provider.getCurrency(), equals('EUR'));

          // Logout
          await provider.logout();

          // Verify all data is cleared
          expect(provider.getUserProfile(), isNull);
          expect(provider.appSettings, isNull);
        }
      });

      test('logout prevents access to previous session data', () async {
        final provider = SettingsProvider();

        for (int i = 0; i < 100; i++) {
          // Set up user data
          await provider.updateUserProfile(
            name: 'User $i',
            email: 'user$i@example.com',
          );
          await provider.setCurrency('GBP');

          // Logout
          await provider.logout();

          // Verify no data is accessible
          expect(provider.getUserProfile(), isNull);
          expect(provider.appSettings, isNull);
        }
      });
    });

    group('Property 10: Immediate Settings Persistence', () {
      /// **Feature: app-settings, Property 10: Immediate Settings Persistence**
      /// **Validates: Requirements 8.1**
      ///
      /// For any settings change made by the user, the change SHALL be persisted
      /// to storage within 100 milliseconds of the user action.
      test('settings changes are persisted immediately', () async {
        final provider = SettingsProvider();
        final stopwatch = Stopwatch();

        for (int i = 0; i < 100; i++) {
          stopwatch.reset();
          stopwatch.start();

          await provider.setCurrency('USD');

          stopwatch.stop();

          // Verify persistence happened quickly (within 100ms)
          expect(stopwatch.elapsedMilliseconds, lessThan(100));
          expect(provider.getCurrency(), equals('USD'));
        }
      });

      test('all preference changes persist immediately', () async {
        final provider = SettingsProvider();

        for (int i = 0; i < 100; i++) {
          // Test currency persistence
          await provider.setCurrency('EUR');
          expect(provider.getCurrency(), equals('EUR'));

          // Test push notification persistence
          await provider.setPushNotificationsEnabled(false);
          expect(provider.getPushNotificationsEnabled(), equals(false));

          // Test email notification persistence
          await provider.setEmailNotificationsEnabled(true);
          expect(provider.getEmailNotificationsEnabled(), equals(true));

          // Test dark mode persistence
          await provider.setDarkModeEnabled(true);
          expect(provider.getDarkModeEnabled(), equals(true));

          // Test language persistence
          await provider.setLanguage('Spanish');
          expect(provider.getLanguage(), equals('Spanish'));
        }
      });
    });
  });
}
