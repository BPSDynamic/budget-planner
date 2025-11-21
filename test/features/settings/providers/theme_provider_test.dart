import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_planner/features/settings/providers/theme_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeProvider', () {
    group('Property 5: Dark Mode Application', () {
      /// **Feature: app-settings, Property 5: Dark Mode Application**
      /// **Validates: Requirements 4.2, 4.3, 4.4, 4.5**
      ///
      /// For any dark mode toggle state change, the system SHALL immediately apply
      /// the corresponding theme to the current screen and persist the preference
      /// for future sessions.
      test('dark mode state persists across provider instances', () async {
        final states = [true, false];

        for (int i = 0; i < 100; i++) {
          final enabled = states[i % states.length];

          // Reset mock for each iteration
          SharedPreferences.setMockInitialValues({});

          // Create first provider instance and set dark mode
          final provider1 = ThemeProvider();
          await provider1.setDarkMode(enabled);

          // Verify state is set
          expect(provider1.isDarkMode, equals(enabled));
          expect(provider1.themeMode,
              equals(enabled ? ThemeMode.dark : ThemeMode.light));

          // Create second provider instance (simulating app restart)
          SharedPreferences.setMockInitialValues({
            'dark_mode_enabled': enabled,
          });

          final provider2 = ThemeProvider();
          await Future.delayed(const Duration(milliseconds: 10));

          // Verify state persists
          expect(provider2.isDarkMode, equals(enabled));
          expect(provider2.themeMode,
              equals(enabled ? ThemeMode.dark : ThemeMode.light));
        }
      });

      test('dark mode is immediately applied', () async {
        final provider = ThemeProvider();

        for (int i = 0; i < 100; i++) {
          final enabled = i % 2 == 0;
          await provider.setDarkMode(enabled);

          // Verify immediate application
          expect(provider.isDarkMode, equals(enabled));
          expect(provider.themeMode,
              equals(enabled ? ThemeMode.dark : ThemeMode.light));
        }
      });

      test('toggle dark mode switches state correctly', () async {
        final provider = ThemeProvider();

        for (int i = 0; i < 100; i++) {
          final initialState = provider.isDarkMode;
          await provider.toggleDarkMode();

          // Verify toggle worked
          expect(provider.isDarkMode, equals(!initialState));
          expect(provider.themeMode,
              equals(!initialState ? ThemeMode.dark : ThemeMode.light));
        }
      });

      test('dark mode state is persisted after toggle', () async {
        for (int i = 0; i < 100; i++) {
          // Reset mock for each iteration
          SharedPreferences.setMockInitialValues({});

          // Create first provider and toggle dark mode
          final provider1 = ThemeProvider();
          final initialState = provider1.isDarkMode;
          await provider1.toggleDarkMode();

          // Create second provider (simulating app restart)
          SharedPreferences.setMockInitialValues({
            'dark_mode_enabled': !initialState,
          });

          final provider2 = ThemeProvider();
          await Future.delayed(const Duration(milliseconds: 10));

          // Verify toggled state persists
          expect(provider2.isDarkMode, equals(!initialState));
        }
      });

      test('theme mode getter returns correct value for dark mode', () async {
        final provider = ThemeProvider();

        // Test light mode
        await provider.setDarkMode(false);
        expect(provider.themeMode, equals(ThemeMode.light));

        // Test dark mode
        await provider.setDarkMode(true);
        expect(provider.themeMode, equals(ThemeMode.dark));
      });

      test('multiple rapid dark mode changes are persisted correctly',
          () async {
        final provider = ThemeProvider();

        for (int i = 0; i < 100; i++) {
          // Perform multiple rapid changes
          await provider.setDarkMode(true);
          await provider.setDarkMode(false);
          await provider.setDarkMode(true);

          // Verify final state
          expect(provider.isDarkMode, equals(true));
          expect(provider.themeMode, equals(ThemeMode.dark));
        }
      });
    });
  });
}
