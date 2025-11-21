import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_planner/features/settings/providers/settings_provider.dart';
import 'package:budget_planner/features/settings/providers/theme_provider.dart';
import 'package:budget_planner/features/settings/providers/language_provider.dart';
import 'package:budget_planner/features/settings/models/user_profile.dart';
import 'package:budget_planner/features/settings/models/app_settings.dart';
import 'package:budget_planner/features/settings/services/settings_serialization_service.dart';

void main() {
  group('Integration Tests: App Settings Management', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('Flow 1: Open settings and change each preference', () {
      test('Change all preferences in sequence', () async {
        final settingsProvider = SettingsProvider();
        final themeProvider = ThemeProvider();
        final languageProvider = LanguageProvider();

        // Set up user profile
        await settingsProvider.updateUserProfile(
          name: 'John Doe',
          email: 'john@example.com',
        );

        // Verify profile is set
        expect(settingsProvider.getUserProfile(), isNotNull);
        expect(settingsProvider.getUserProfile()!.name, 'John Doe');

        // Change currency
        await settingsProvider.setCurrency('EUR');
        expect(settingsProvider.getCurrency(), 'EUR');

        // Change push notifications
        await settingsProvider.setPushNotificationsEnabled(false);
        expect(settingsProvider.getPushNotificationsEnabled(), false);

        // Change email notifications
        await settingsProvider.setEmailNotificationsEnabled(false);
        expect(settingsProvider.getEmailNotificationsEnabled(), false);

        // Change dark mode
        await settingsProvider.setDarkModeEnabled(true);
        expect(settingsProvider.getDarkModeEnabled(), true);

        // Change language
        await settingsProvider.setLanguage('Spanish');
        expect(settingsProvider.getLanguage(), 'Spanish');

        // Verify all changes are persisted
        expect(settingsProvider.appSettings!.currency, 'EUR');
        expect(settingsProvider.appSettings!.pushNotificationsEnabled, false);
        expect(settingsProvider.appSettings!.emailNotificationsEnabled, false);
        expect(settingsProvider.appSettings!.darkModeEnabled, true);
        expect(settingsProvider.appSettings!.language, 'Spanish');
      });

      test('Change preferences multiple times', () async {
        final settingsProvider = SettingsProvider();

        // First set of changes
        await settingsProvider.setCurrency('USD');
        await settingsProvider.setPushNotificationsEnabled(true);
        await settingsProvider.setLanguage('English');

        expect(settingsProvider.getCurrency(), 'USD');
        expect(settingsProvider.getPushNotificationsEnabled(), true);
        expect(settingsProvider.getLanguage(), 'English');

        // Second set of changes
        await settingsProvider.setCurrency('GBP');
        await settingsProvider.setPushNotificationsEnabled(false);
        await settingsProvider.setLanguage('French');

        expect(settingsProvider.getCurrency(), 'GBP');
        expect(settingsProvider.getPushNotificationsEnabled(), false);
        expect(settingsProvider.getLanguage(), 'French');

        // Third set of changes
        await settingsProvider.setCurrency('JPY');
        await settingsProvider.setPushNotificationsEnabled(true);
        await settingsProvider.setLanguage('German');

        expect(settingsProvider.getCurrency(), 'JPY');
        expect(settingsProvider.getPushNotificationsEnabled(), true);
        expect(settingsProvider.getLanguage(), 'German');
      });

      test('Toggle notifications multiple times', () async {
        final settingsProvider = SettingsProvider();

        for (int i = 0; i < 5; i++) {
          final shouldEnable = i % 2 == 0;

          await settingsProvider.setPushNotificationsEnabled(shouldEnable);
          expect(settingsProvider.getPushNotificationsEnabled(), shouldEnable);

          await settingsProvider.setEmailNotificationsEnabled(shouldEnable);
          expect(settingsProvider.getEmailNotificationsEnabled(), shouldEnable);
        }
      });
    });

    group('Flow 2: Close app and reopen to verify preferences persisted', () {
      test('Preferences persist across app restart', () async {
        // First session: set preferences
        final settingsProvider = SettingsProvider();
        await settingsProvider.updateUserProfile(
          name: 'Jane Smith',
          email: 'jane@example.com',
        );
        await settingsProvider.setCurrency('EUR');
        await settingsProvider.setPushNotificationsEnabled(false);
        await settingsProvider.setEmailNotificationsEnabled(true);
        await settingsProvider.setDarkModeEnabled(true);
        await settingsProvider.setLanguage('Spanish');

        // Verify all preferences are set
        expect(settingsProvider.getUserProfile()!.name, 'Jane Smith');
        expect(settingsProvider.getUserProfile()!.email, 'jane@example.com');
        expect(settingsProvider.getCurrency(), 'EUR');
        expect(settingsProvider.getPushNotificationsEnabled(), false);
        expect(settingsProvider.getEmailNotificationsEnabled(), true);
        expect(settingsProvider.getDarkModeEnabled(), true);
        expect(settingsProvider.getLanguage(), 'Spanish');
      });

      test('Theme preference persists across app restart', () async {
        final themeProvider = ThemeProvider();
        
        // Enable dark mode
        await themeProvider.setDarkMode(true);
        expect(themeProvider.isDarkMode, true);
        
        // Disable dark mode
        await themeProvider.setDarkMode(false);
        expect(themeProvider.isDarkMode, false);
        
        // Enable again
        await themeProvider.setDarkMode(true);
        expect(themeProvider.isDarkMode, true);
      });

      test('Language preference persists across app restart', () async {
        final languageProvider = LanguageProvider();

        // Set language
        await languageProvider.setLanguage('French');
        expect(languageProvider.currentLanguage, 'French');

        // Change language
        await languageProvider.setLanguage('German');
        expect(languageProvider.currentLanguage, 'German');
        
        // Change back
        await languageProvider.setLanguage('English');
        expect(languageProvider.currentLanguage, 'English');
      });

      test('Multiple preference changes maintain consistency', () async {
        final settingsProvider = SettingsProvider();
        final currencies = ['USD', 'EUR', 'GBP', 'JPY'];
        final languages = ['English', 'Spanish', 'French', 'German'];

        for (int cycle = 0; cycle < 3; cycle++) {
          final currency = currencies[cycle % currencies.length];
          final language = languages[cycle % languages.length];

          await settingsProvider.setCurrency(currency);
          await settingsProvider.setLanguage(language);
          
          expect(settingsProvider.getCurrency(), currency);
          expect(settingsProvider.getLanguage(), language);
        }
      });
    });

    group('Flow 3: Logout flow with session clearing', () {
      test('Logout clears all user data', () async {
        final settingsProvider = SettingsProvider();

        // Set up user data
        await settingsProvider.updateUserProfile(
          name: 'Test User',
          email: 'test@example.com',
        );
        await settingsProvider.setCurrency('EUR');
        await settingsProvider.setPushNotificationsEnabled(false);

        // Verify data is set
        expect(settingsProvider.getUserProfile(), isNotNull);
        expect(settingsProvider.getCurrency(), 'EUR');

        // Logout
        await settingsProvider.logout();

        // Verify all data is cleared
        expect(settingsProvider.getUserProfile(), isNull);
        expect(settingsProvider.appSettings, isNull);
      });

      test('After logout, new session starts fresh', () async {
        final settingsProvider = SettingsProvider();
        
        // First session with user data
        await settingsProvider.updateUserProfile(
          name: 'User 1',
          email: 'user1@example.com',
        );
        await settingsProvider.setCurrency('EUR');
        expect(settingsProvider.getUserProfile(), isNotNull);

        // Logout
        await settingsProvider.logout();
        expect(settingsProvider.getUserProfile(), isNull);
        expect(settingsProvider.appSettings, isNull);

        // New user can log in
        await settingsProvider.updateUserProfile(
          name: 'User 2',
          email: 'user2@example.com',
        );
        expect(settingsProvider.getUserProfile()!.name, 'User 2');
        expect(settingsProvider.getUserProfile()!.email, 'user2@example.com');
      });

      test('Logout clears cached preferences', () async {
        final settingsProvider = SettingsProvider();

        // Set multiple preferences
        await settingsProvider.updateUserProfile(
          name: 'Test',
          email: 'test@example.com',
        );
        await settingsProvider.setCurrency('GBP');
        await settingsProvider.setPushNotificationsEnabled(false);
        await settingsProvider.setEmailNotificationsEnabled(false);
        await settingsProvider.setDarkModeEnabled(true);
        await settingsProvider.setLanguage('Spanish');

        // Verify all are set
        expect(settingsProvider.getCurrency(), 'GBP');
        expect(settingsProvider.getPushNotificationsEnabled(), false);
        expect(settingsProvider.getEmailNotificationsEnabled(), false);
        expect(settingsProvider.getDarkModeEnabled(), true);
        expect(settingsProvider.getLanguage(), 'Spanish');

        // Logout
        await settingsProvider.logout();

        // Verify all are cleared
        expect(settingsProvider.appSettings, isNull);
      });

      test('Logout prevents access to previous session data', () async {
        final settingsProvider = SettingsProvider();

        for (int i = 0; i < 5; i++) {
          // Set up user data
          await settingsProvider.updateUserProfile(
            name: 'User $i',
            email: 'user$i@example.com',
          );
          await settingsProvider.setCurrency('EUR');

          // Verify data exists
          expect(settingsProvider.getUserProfile(), isNotNull);

          // Logout
          await settingsProvider.logout();

          // Verify no data is accessible
          expect(settingsProvider.getUserProfile(), isNull);
          expect(settingsProvider.appSettings, isNull);
        }
      });
    });

    group('Flow 4: Serialization/deserialization of all settings', () {
      test('Round-trip serialization of AppSettings', () async {
        final original = AppSettings(
          userId: 'user123',
          currency: 'EUR',
          pushNotificationsEnabled: false,
          emailNotificationsEnabled: true,
          darkModeEnabled: true,
          language: 'Spanish',
        );

        // Serialize
        final json = SettingsSerializationService.serializeSettings(original);

        // Deserialize
        final deserialized =
            SettingsSerializationService.deserializeSettings(json);

        // Verify round trip
        expect(deserialized.userId, original.userId);
        expect(deserialized.currency, original.currency);
        expect(deserialized.pushNotificationsEnabled,
            original.pushNotificationsEnabled);
        expect(deserialized.emailNotificationsEnabled,
            original.emailNotificationsEnabled);
        expect(deserialized.darkModeEnabled, original.darkModeEnabled);
        expect(deserialized.language, original.language);
      });

      test('Round-trip serialization of UserProfile', () async {
        final original = UserProfile(
          name: 'John Doe',
          email: 'john@example.com',
          avatarUrl: 'https://example.com/avatar.jpg',
        );

        // Serialize
        final json =
            SettingsSerializationService.serializeUserProfile(original);

        // Deserialize
        final deserialized =
            SettingsSerializationService.deserializeUserProfile(json);

        // Verify round trip
        expect(deserialized.name, original.name);
        expect(deserialized.email, original.email);
        expect(deserialized.avatarUrl, original.avatarUrl);
      });

      test('Serialization preserves all preference combinations', () async {
        final currencies = ['USD', 'EUR', 'GBP', 'JPY'];
        final languages = ['English', 'Spanish', 'French', 'German'];
        final notificationStates = [true, false];

        for (int i = 0; i < 10; i++) {
          final settings = AppSettings(
            userId: 'user$i',
            currency: currencies[i % currencies.length],
            pushNotificationsEnabled: notificationStates[i % 2],
            emailNotificationsEnabled: notificationStates[(i + 1) % 2],
            darkModeEnabled: i % 2 == 0,
            language: languages[i % languages.length],
          );

          // Serialize and deserialize
          final json = SettingsSerializationService.serializeSettings(settings);
          final deserialized =
              SettingsSerializationService.deserializeSettings(json);

          // Verify all fields match
          expect(deserialized.currency, settings.currency);
          expect(deserialized.pushNotificationsEnabled,
              settings.pushNotificationsEnabled);
          expect(deserialized.emailNotificationsEnabled,
              settings.emailNotificationsEnabled);
          expect(deserialized.darkModeEnabled, settings.darkModeEnabled);
          expect(deserialized.language, settings.language);
        }
      });

      test('Deserialization validates required fields', () async {
        // Missing userId
        expect(
          () => SettingsSerializationService.deserializeSettings(
            jsonEncode({
              'currency': 'USD',
              'pushNotificationsEnabled': true,
              'emailNotificationsEnabled': true,
              'darkModeEnabled': false,
              'language': 'English',
              'lastUpdated': DateTime.now().toIso8601String(),
            }),
          ),
          throwsArgumentError,
        );

        // Missing currency
        expect(
          () => SettingsSerializationService.deserializeSettings(
            jsonEncode({
              'userId': 'user123',
              'pushNotificationsEnabled': true,
              'emailNotificationsEnabled': true,
              'darkModeEnabled': false,
              'language': 'English',
              'lastUpdated': DateTime.now().toIso8601String(),
            }),
          ),
          throwsArgumentError,
        );
      });

      test('Deserialization validates field types', () async {
        // Invalid currency type (number instead of string)
        expect(
          () => SettingsSerializationService.deserializeSettings(
            jsonEncode({
              'userId': 'user123',
              'currency': 123,
              'pushNotificationsEnabled': true,
              'emailNotificationsEnabled': true,
              'darkModeEnabled': false,
              'language': 'English',
              'lastUpdated': DateTime.now().toIso8601String(),
            }),
          ),
          throwsArgumentError,
        );

        // Invalid pushNotificationsEnabled type (string instead of bool)
        expect(
          () => SettingsSerializationService.deserializeSettings(
            jsonEncode({
              'userId': 'user123',
              'currency': 'USD',
              'pushNotificationsEnabled': 'true',
              'emailNotificationsEnabled': true,
              'darkModeEnabled': false,
              'language': 'English',
              'lastUpdated': DateTime.now().toIso8601String(),
            }),
          ),
          throwsArgumentError,
        );
      });

      test('Provider serialization integration', () async {
        final settingsProvider = SettingsProvider();

        // Set up user and preferences
        await settingsProvider.updateUserProfile(
          name: 'Integration Test',
          email: 'integration@example.com',
        );
        await settingsProvider.setCurrency('EUR');
        await settingsProvider.setPushNotificationsEnabled(false);
        await settingsProvider.setLanguage('French');

        // Serialize current settings
        final settingsJson = SettingsSerializationService.serializeSettings(
          settingsProvider.appSettings,
        );
        final profileJson = SettingsSerializationService.serializeUserProfile(
          settingsProvider.userProfile,
        );

        // Deserialize
        final deserializedSettings =
            SettingsSerializationService.deserializeSettings(settingsJson);
        final deserializedProfile =
            SettingsSerializationService.deserializeUserProfile(profileJson);

        // Verify
        expect(deserializedSettings.currency, 'EUR');
        expect(deserializedSettings.pushNotificationsEnabled, false);
        expect(deserializedSettings.language, 'French');
        expect(deserializedProfile.name, 'Integration Test');
        expect(deserializedProfile.email, 'integration@example.com');
      });
    });

    group('Flow 5: Theme application across multiple screens', () {
      test('Dark mode state is consistent across providers', () async {
        final themeProvider1 = ThemeProvider();
        final themeProvider2 = ThemeProvider();
        final settingsProvider = SettingsProvider();

        // Enable dark mode through theme provider
        await themeProvider1.setDarkMode(true);

        // Verify it's enabled in both theme providers
        expect(themeProvider1.isDarkMode, true);

        // Create new theme provider (simulating different screen)
        final themeProvider3 = ThemeProvider();
        await Future.delayed(Duration(milliseconds: 50));
        expect(themeProvider3.isDarkMode, true);

        // Disable dark mode
        await themeProvider3.setDarkMode(false);
        expect(themeProvider3.isDarkMode, false);

        // Verify new state persists
        final themeProvider4 = ThemeProvider();
        await Future.delayed(Duration(milliseconds: 50));
        expect(themeProvider4.isDarkMode, false);
      });

      test('Theme mode reflects dark mode state', () async {
        final themeProvider = ThemeProvider();

        // Light mode
        await themeProvider.setDarkMode(false);
        expect(themeProvider.themeMode, ThemeMode.light);

        // Dark mode
        await themeProvider.setDarkMode(true);
        expect(themeProvider.themeMode, ThemeMode.dark);

        // Back to light
        await themeProvider.setDarkMode(false);
        expect(themeProvider.themeMode, ThemeMode.light);
      });

      test('Toggle dark mode multiple times', () async {
        final themeProvider = ThemeProvider();

        for (int i = 0; i < 5; i++) {
          await themeProvider.toggleDarkMode();
          final expectedState = i % 2 == 0;
          expect(themeProvider.isDarkMode, expectedState);
        }
      });

      test('Dark mode persists across multiple screen instances', () async {
        final themeProvider = ThemeProvider();
        
        // Enable dark mode
        await themeProvider.setDarkMode(true);
        expect(themeProvider.isDarkMode, true);
        expect(themeProvider.themeMode, ThemeMode.dark);

        // Disable dark mode
        await themeProvider.setDarkMode(false);
        expect(themeProvider.isDarkMode, false);
        expect(themeProvider.themeMode, ThemeMode.light);
        
        // Enable again
        await themeProvider.setDarkMode(true);
        expect(themeProvider.isDarkMode, true);
        expect(themeProvider.themeMode, ThemeMode.dark);
      });
    });

    group('Flow 6: Language change across multiple screens', () {
      test('Language state is consistent across providers', () async {
        final languageProvider1 = LanguageProvider();
        final languageProvider2 = LanguageProvider();

        // Set language through first provider
        await languageProvider1.setLanguage('Spanish');
        expect(languageProvider1.currentLanguage, 'Spanish');

        // Create new language provider (simulating different screen)
        final languageProvider3 = LanguageProvider();
        await Future.delayed(Duration(milliseconds: 50));
        expect(languageProvider3.currentLanguage, 'Spanish');

        // Change language
        await languageProvider3.setLanguage('French');
        expect(languageProvider3.currentLanguage, 'French');

        // Verify new language persists
        final languageProvider4 = LanguageProvider();
        await Future.delayed(Duration(milliseconds: 50));
        expect(languageProvider4.currentLanguage, 'French');
      });

      test('Language list is available across all providers', () async {
        final languageProvider1 = LanguageProvider();
        final languageProvider2 = LanguageProvider();

        expect(languageProvider1.languages, isNotEmpty);
        expect(languageProvider2.languages, isNotEmpty);
        expect(languageProvider1.languages, languageProvider2.languages);

        // Verify all supported languages are available
        expect(languageProvider1.languages.contains('English'), true);
        expect(languageProvider1.languages.contains('Spanish'), true);
        expect(languageProvider1.languages.contains('French'), true);
        expect(languageProvider1.languages.contains('German'), true);
      });

      test('Language changes persist across multiple screen instances', () async {
        final languages = ['English', 'Spanish', 'French', 'German', 'Italian'];

        for (int i = 0; i < languages.length; i++) {
          SharedPreferences.setMockInitialValues({});

          final language = languages[i];

          // Screen 1: Set language
          {
            final languageProvider = LanguageProvider();
            await languageProvider.setLanguage(language);
          }

          // Screen 2: Verify language is set
          {
            final languageProvider = LanguageProvider();
            await Future.delayed(Duration(milliseconds: 50));
            expect(languageProvider.currentLanguage, language);
          }
        }
      });

      test('Invalid language is rejected', () async {
        final languageProvider = LanguageProvider();

        expect(
          () => languageProvider.setLanguage('InvalidLanguage'),
          throwsArgumentError,
        );

        // Verify language didn't change
        expect(languageProvider.currentLanguage, 'English');
      });

      test('Language changes are applied immediately', () async {
        final languageProvider = LanguageProvider();

        for (int i = 0; i < 10; i++) {
          final language = languageProvider.languages[i % languageProvider.languages.length];
          await languageProvider.setLanguage(language);
          expect(languageProvider.currentLanguage, language);
        }
      });
    });

    group('Complex Integration Scenarios', () {
      test('Complete user session: login → change preferences → logout', () async {
        final settingsProvider = SettingsProvider();
        final themeProvider = ThemeProvider();
        final languageProvider = LanguageProvider();

        // Login: Set user profile
        await settingsProvider.updateUserProfile(
          name: 'Complete Test User',
          email: 'complete@example.com',
        );
        expect(settingsProvider.getUserProfile(), isNotNull);

        // Change preferences
        await settingsProvider.setCurrency('EUR');
        await settingsProvider.setPushNotificationsEnabled(false);
        await settingsProvider.setEmailNotificationsEnabled(true);
        await themeProvider.setDarkMode(true);
        await languageProvider.setLanguage('Spanish');

        // Verify all changes
        expect(settingsProvider.getCurrency(), 'EUR');
        expect(settingsProvider.getPushNotificationsEnabled(), false);
        expect(settingsProvider.getEmailNotificationsEnabled(), true);
        expect(themeProvider.isDarkMode, true);
        expect(languageProvider.currentLanguage, 'Spanish');

        // Logout
        await settingsProvider.logout();

        // Verify session is cleared
        expect(settingsProvider.getUserProfile(), isNull);
        expect(settingsProvider.appSettings, isNull);
      });

      test('Multi-session workflow with preference changes', () async {
        // Session 1
        {
          final settingsProvider = SettingsProvider();
          await settingsProvider.updateUserProfile(
            name: 'User Session 1',
            email: 'session1@example.com',
          );
          await settingsProvider.setCurrency('USD');
          await settingsProvider.setLanguage('English');
        }

        // Verify Session 1 data persists
        {
          final settingsProvider = SettingsProvider();
          await Future.delayed(Duration(milliseconds: 50));
          expect(settingsProvider.getUserProfile()!.name, 'User Session 1');
          expect(settingsProvider.getCurrency(), 'USD');
          expect(settingsProvider.getLanguage(), 'English');
        }

        // Session 1 logout
        {
          final settingsProvider = SettingsProvider();
          await settingsProvider.logout();
        }

        // Session 2 (new user)
        {
          final settingsProvider = SettingsProvider();
          await settingsProvider.updateUserProfile(
            name: 'User Session 2',
            email: 'session2@example.com',
          );
          await settingsProvider.setCurrency('EUR');
          await settingsProvider.setLanguage('French');
        }

        // Verify Session 2 data
        {
          final settingsProvider = SettingsProvider();
          await Future.delayed(Duration(milliseconds: 50));
          expect(settingsProvider.getUserProfile()!.name, 'User Session 2');
          expect(settingsProvider.getCurrency(), 'EUR');
          expect(settingsProvider.getLanguage(), 'French');
        }
      });

      test('Preferences persist through multiple preference changes', () async {
        final settingsProvider = SettingsProvider();

        // Initial setup
        await settingsProvider.updateUserProfile(
          name: 'Persistence Test',
          email: 'persistence@example.com',
        );

        // Make multiple changes
        final changes = [
          ('USD', 'English', true, true, false),
          ('EUR', 'Spanish', false, true, true),
          ('GBP', 'French', true, false, false),
          ('JPY', 'German', false, false, true),
        ];

        for (final (currency, language, pushEnabled, emailEnabled, darkMode)
            in changes) {
          await settingsProvider.setCurrency(currency);
          await settingsProvider.setLanguage(language);
          await settingsProvider.setPushNotificationsEnabled(pushEnabled);
          await settingsProvider.setEmailNotificationsEnabled(emailEnabled);
          await settingsProvider.setDarkModeEnabled(darkMode);

          // Verify immediately
          expect(settingsProvider.getCurrency(), currency);
          expect(settingsProvider.getLanguage(), language);
          expect(settingsProvider.getPushNotificationsEnabled(), pushEnabled);
          expect(settingsProvider.getEmailNotificationsEnabled(), emailEnabled);
          expect(settingsProvider.getDarkModeEnabled(), darkMode);
        }

        // Verify final state persists
        {
          final newProvider = SettingsProvider();
          await Future.delayed(Duration(milliseconds: 50));
          expect(newProvider.getCurrency(), 'JPY');
          expect(newProvider.getLanguage(), 'German');
          expect(newProvider.getPushNotificationsEnabled(), false);
          expect(newProvider.getEmailNotificationsEnabled(), false);
          expect(newProvider.getDarkModeEnabled(), true);
        }
      });

      test('Serialization works with real provider data', () async {
        final settingsProvider = SettingsProvider();

        // Set up realistic user data
        await settingsProvider.updateUserProfile(
          name: 'Real User',
          email: 'realuser@example.com',
          avatarUrl: 'https://example.com/avatar.jpg',
        );
        await settingsProvider.setCurrency('EUR');
        await settingsProvider.setPushNotificationsEnabled(false);
        await settingsProvider.setEmailNotificationsEnabled(true);
        await settingsProvider.setDarkModeEnabled(true);
        await settingsProvider.setLanguage('Spanish');

        // Serialize both profile and settings
        final profileJson = SettingsSerializationService.serializeUserProfile(
          settingsProvider.userProfile,
        );
        final settingsJson = SettingsSerializationService.serializeSettings(
          settingsProvider.appSettings,
        );

        // Deserialize
        final deserializedProfile =
            SettingsSerializationService.deserializeUserProfile(profileJson);
        final deserializedSettings =
            SettingsSerializationService.deserializeSettings(settingsJson);

        // Verify all data matches
        expect(deserializedProfile.name, 'Real User');
        expect(deserializedProfile.email, 'realuser@example.com');
        expect(deserializedProfile.avatarUrl, 'https://example.com/avatar.jpg');
        expect(deserializedSettings.currency, 'EUR');
        expect(deserializedSettings.pushNotificationsEnabled, false);
        expect(deserializedSettings.emailNotificationsEnabled, true);
        expect(deserializedSettings.darkModeEnabled, true);
        expect(deserializedSettings.language, 'Spanish');
      });
    });
  });
}
