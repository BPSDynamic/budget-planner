import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_planner/features/settings/providers/language_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LanguageProvider', () {
    group('Property 6: Language Persistence and Application', () {
      /// **Feature: app-settings, Property 6: Language Persistence and Application**
      /// **Validates: Requirements 5.3, 5.4, 5.5**
      ///
      /// For any language selection made by the user, the system SHALL persist
      /// the selection and apply it to all UI text in subsequent app sessions.
      test('language selection persists across provider instances', () async {
        final languages = LanguageProvider.supportedLanguages;

        for (int i = 0; i < 100; i++) {
          final selectedLanguage = languages[i % languages.length];

          // Reset mock for each iteration
          SharedPreferences.setMockInitialValues({});

          // Create first provider instance and set language
          final provider1 = LanguageProvider();
          await provider1.setLanguage(selectedLanguage);

          // Verify state is set
          expect(provider1.currentLanguage, equals(selectedLanguage));

          // Create second provider instance (simulating app restart)
          SharedPreferences.setMockInitialValues({
            'language_preference': selectedLanguage,
          });

          final provider2 = LanguageProvider();
          await Future.delayed(const Duration(milliseconds: 10));

          // Verify state persists
          expect(provider2.currentLanguage, equals(selectedLanguage));
        }
      });

      test('language is immediately applied after selection', () async {
        final provider = LanguageProvider();
        final languages = LanguageProvider.supportedLanguages;

        for (int i = 0; i < 100; i++) {
          final language = languages[i % languages.length];
          await provider.setLanguage(language);

          // Verify immediate application
          expect(provider.currentLanguage, equals(language));
        }
      });

      test('language selection is persisted to storage', () async {
        final languages = LanguageProvider.supportedLanguages;

        for (int i = 0; i < 100; i++) {
          final language = languages[i % languages.length];

          // Reset mock for each iteration
          SharedPreferences.setMockInitialValues({});

          // Create provider and set language
          final provider = LanguageProvider();
          await provider.setLanguage(language);

          // Verify it was saved to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final savedLanguage = prefs.getString('language_preference');
          expect(savedLanguage, equals(language));
        }
      });

      test('default language is English when no preference is saved', () async {
        SharedPreferences.setMockInitialValues({});

        final provider = LanguageProvider();
        await Future.delayed(const Duration(milliseconds: 10));

        expect(provider.currentLanguage, equals('English'));
      });

      test('language provider notifies listeners on language change', () async {
        final provider = LanguageProvider();
        final languages = LanguageProvider.supportedLanguages;
        int notificationCount = 0;

        provider.addListener(() {
          notificationCount++;
        });

        for (int i = 0; i < 10; i++) {
          final language = languages[i % languages.length];
          await provider.setLanguage(language);
        }

        // Should have notified listeners for each change
        expect(notificationCount, greaterThan(0));
      });

      test('all supported languages can be set and persisted', () async {
        final languages = LanguageProvider.supportedLanguages;

        for (final language in languages) {
          // Reset mock for each language
          SharedPreferences.setMockInitialValues({});

          final provider = LanguageProvider();
          await provider.setLanguage(language);

          expect(provider.currentLanguage, equals(language));

          // Verify persistence
          final prefs = await SharedPreferences.getInstance();
          final savedLanguage = prefs.getString('language_preference');
          expect(savedLanguage, equals(language));
        }
      });

      test('setting invalid language throws ArgumentError', () async {
        final provider = LanguageProvider();

        expect(
          () => provider.setLanguage('InvalidLanguage'),
          throwsArgumentError,
        );
      });

      test('language list is accessible and contains all supported languages',
          () async {
        final provider = LanguageProvider();

        expect(provider.languages, isNotEmpty);
        expect(provider.languages.length, equals(12));
        expect(provider.languages.contains('English'), isTrue);
        expect(provider.languages.contains('Spanish'), isTrue);
        expect(provider.languages.contains('French'), isTrue);
      });

      test('multiple rapid language changes are persisted correctly', () async {
        final provider = LanguageProvider();
        final languages = LanguageProvider.supportedLanguages;

        for (int i = 0; i < 100; i++) {
          // Perform multiple rapid changes
          await provider.setLanguage(languages[0]);
          await provider.setLanguage(languages[1]);
          await provider.setLanguage(languages[2]);

          // Verify final state
          expect(provider.currentLanguage, equals(languages[2]));
        }
      });
    });
  });
}
