import 'package:flutter_test/flutter_test.dart';
import 'package:budget_planner/features/settings/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    group('Property 1: User Profile Accuracy', () {
      /// **Feature: app-settings, Property 1: User Profile Accuracy**
      /// **Validates: Requirements 1.5**
      /// 
      /// For any user profile displayed on the settings screen, the displayed 
      /// name and email SHALL match the currently stored user profile data.
      test('serialization round trip preserves profile data', () {
        // Run property test with 100 iterations
        for (int i = 0; i < 100; i++) {
          // Generate random profile data
          final originalProfile = UserProfile(
            name: 'Test User $i',
            email: 'user$i@example.com',
            avatarUrl: i % 2 == 0 ? 'https://example.com/avatar$i.jpg' : null,
          );

          // Serialize to map
          final map = originalProfile.toMap();

          // Deserialize from map
          final deserializedProfile = UserProfile.fromMap(map);

          // Verify round trip preserves all data
          expect(deserializedProfile.name, equals(originalProfile.name));
          expect(deserializedProfile.email, equals(originalProfile.email));
          expect(deserializedProfile.avatarUrl, equals(originalProfile.avatarUrl));
          expect(deserializedProfile.id, equals(originalProfile.id));
          expect(deserializedProfile.createdDate, equals(originalProfile.createdDate));
        }
      });

      test('profile equality works correctly after round trip', () {
        for (int i = 0; i < 100; i++) {
          final originalProfile = UserProfile(
            name: 'User $i',
            email: 'email$i@test.com',
          );

          final map = originalProfile.toMap();
          final deserializedProfile = UserProfile.fromMap(map);

          // Profiles should be equal after round trip
          expect(deserializedProfile, equals(originalProfile));
        }
      });

      test('copyWith preserves serialization integrity', () {
        for (int i = 0; i < 100; i++) {
          final originalProfile = UserProfile(
            name: 'Original Name',
            email: 'original@example.com',
            avatarUrl: 'https://example.com/avatar.jpg',
          );

          // Modify profile using copyWith
          final modifiedProfile = originalProfile.copyWith(
            name: 'Modified Name $i',
            email: 'modified$i@example.com',
          );

          // Serialize and deserialize modified profile
          final map = modifiedProfile.toMap();
          final deserializedProfile = UserProfile.fromMap(map);

          // Verify modified data is preserved
          expect(deserializedProfile.name, equals('Modified Name $i'));
          expect(deserializedProfile.email, equals('modified$i@example.com'));
          expect(deserializedProfile.avatarUrl, equals('https://example.com/avatar.jpg'));
          expect(deserializedProfile.id, equals(originalProfile.id));
        }
      });
    });
  });
}
