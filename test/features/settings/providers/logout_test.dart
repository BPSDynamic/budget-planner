import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_planner/features/settings/providers/settings_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Logout Flow Tests', () {
    test('logout clears user profile', () async {
      final provider = SettingsProvider();
      
      // Set up user profile
      await provider.updateUserProfile(
        name: 'Test User',
        email: 'test@example.com',
      );
      
      // Verify profile is set
      expect(provider.getUserProfile(), isNotNull);
      expect(provider.getUserProfile()?.name, equals('Test User'));
      
      // Logout
      await provider.logout();
      
      // Verify profile is cleared
      expect(provider.getUserProfile(), isNull);
    });

    test('logout clears app settings', () async {
      final provider = SettingsProvider();
      
      // Set up settings
      await provider.setCurrency('EUR');
      await provider.setPushNotificationsEnabled(false);
      await provider.setEmailNotificationsEnabled(false);
      await provider.setDarkModeEnabled(true);
      await provider.setLanguage('Spanish');
      
      // Verify settings are set
      expect(provider.getCurrency(), equals('EUR'));
      expect(provider.getPushNotificationsEnabled(), equals(false));
      expect(provider.getEmailNotificationsEnabled(), equals(false));
      expect(provider.getDarkModeEnabled(), equals(true));
      expect(provider.getLanguage(), equals('Spanish'));
      
      // Logout
      await provider.logout();
      
      // Verify settings are cleared
      expect(provider.appSettings, isNull);
    });

    test('logout removes data from shared preferences', () async {
      final provider = SettingsProvider();
      
      // Set up user data
      await provider.updateUserProfile(
        name: 'Test User',
        email: 'test@example.com',
      );
      await provider.setCurrency('GBP');
      
      // Verify data is in shared preferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_profile'), isNotNull);
      expect(prefs.getString('app_settings'), isNotNull);
      
      // Logout
      await provider.logout();
      
      // Verify data is removed from shared preferences
      expect(prefs.getString('user_profile'), isNull);
      expect(prefs.getString('app_settings'), isNull);
    });

    test('logout prevents access to previous session data', () async {
      final provider = SettingsProvider();
      
      // Set up user data
      await provider.updateUserProfile(
        name: 'User 1',
        email: 'user1@example.com',
      );
      await provider.setCurrency('JPY');
      
      // Logout
      await provider.logout();
      
      // Verify no data is accessible
      expect(provider.getUserProfile(), isNull);
      expect(provider.appSettings, isNull);
      expect(provider.getCurrency(), equals('USD')); // Default value
    });

    test('logout notifies listeners', () async {
      final provider = SettingsProvider();
      
      // Set up user data
      await provider.updateUserProfile(
        name: 'Test User',
        email: 'test@example.com',
      );
      
      // Track listener calls
      int listenerCallCount = 0;
      provider.addListener(() {
        listenerCallCount++;
      });
      
      // Logout
      await provider.logout();
      
      // Verify listener was called
      expect(listenerCallCount, greaterThan(0));
    });

    test('logout clears all cached data across multiple iterations', () async {
      for (int i = 0; i < 100; i++) {
        final provider = SettingsProvider();
        
        // Set up user data
        await provider.updateUserProfile(
          name: 'User $i',
          email: 'user$i@example.com',
        );
        await provider.setCurrency('USD');
        await provider.setPushNotificationsEnabled(i % 2 == 0);
        
        // Logout
        await provider.logout();
        
        // Verify all data is cleared
        expect(provider.getUserProfile(), isNull);
        expect(provider.appSettings, isNull);
      }
    });

    test('logout followed by new session starts fresh', () async {
      // First session
      final provider1 = SettingsProvider();
      await provider1.updateUserProfile(
        name: 'User 1',
        email: 'user1@example.com',
      );
      await provider1.setCurrency('EUR');
      
      // Logout
      await provider1.logout();
      
      // Verify cleared
      expect(provider1.getUserProfile(), isNull);
      
      // Second session (new provider instance)
      final provider2 = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 10));
      
      // Verify new session has no previous data
      expect(provider2.getUserProfile(), isNull);
      expect(provider2.getCurrency(), equals('USD')); // Default
    });
  });
}
