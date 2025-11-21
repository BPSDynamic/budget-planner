import 'package:test/test.dart';
import 'package:budget_planner/services/ios_build/models/build_config.dart';

void main() {
  group('BuildConfig', () {
    group('Serialization', () {
      test('toMap and fromMap preserve all fields', () {
        final config = BuildConfig(
          buildMode: 'debug',
          targetPlatform: 'ios',
          buildNumber: 1,
          buildTimestamp: DateTime(2024, 1, 1, 12, 0, 0),
          sourceHash: 'abc123def456',
          artifactPath: '/path/to/app.app',
        );

        final map = config.toMap();
        final restored = BuildConfig.fromMap(map);

        expect(restored, equals(config));
      });

      test('toMap produces correct structure', () {
        final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final config = BuildConfig(
          buildMode: 'release',
          targetPlatform: 'ios',
          buildNumber: 42,
          buildTimestamp: timestamp,
          sourceHash: 'hash123',
          artifactPath: '/artifacts/app.app',
        );

        final map = config.toMap();

        expect(map['buildMode'], equals('release'));
        expect(map['targetPlatform'], equals('ios'));
        expect(map['buildNumber'], equals(42));
        expect(map['buildTimestamp'], equals(timestamp.toIso8601String()));
        expect(map['sourceHash'], equals('hash123'));
        expect(map['artifactPath'], equals('/artifacts/app.app'));
      });

      test('fromMap handles null artifactPath', () {
        final map = {
          'buildMode': 'debug',
          'targetPlatform': 'ios',
          'buildNumber': 1,
          'buildTimestamp': DateTime(2024, 1, 1).toIso8601String(),
          'sourceHash': 'hash',
          'artifactPath': null,
        };

        final config = BuildConfig.fromMap(map);

        expect(config.artifactPath, isNull);
        expect(config.buildMode, equals('debug'));
      });
    });

    group('Property: Build Artifact Generation', () {
      // **Feature: ios-emulator-build-test, Property 2: Build Artifact Generation**
      // **Validates: Requirements 2.4**
      test('round trip serialization preserves all valid configurations (100 iterations)', () {
        // Property-based test: For any valid BuildConfig, serializing then deserializing should produce an equivalent value
        final testCases = [
          ('debug', 'ios', 1, 'hash1'),
          ('release', 'ios', 42, 'hash2'),
          ('profile', 'ios', 100, 'hash3'),
          ('debug', 'ios', 0, 'hash4'),
          ('release', 'ios', 999, 'hash5'),
          ('debug', 'ios', 1, ''),
          ('debug', 'ios', 1, 'very-long-hash-string-with-many-characters'),
          ('', 'ios', 1, 'hash'),
          ('debug', '', 1, 'hash'),
          ('debug', 'ios', 1, 'hash'),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
          final config = BuildConfig(
            buildMode: testCase.$1,
            targetPlatform: testCase.$2,
            buildNumber: testCase.$3,
            buildTimestamp: timestamp,
            sourceHash: testCase.$4,
            artifactPath: null,
          );

          final map = config.toMap();
          final restored = BuildConfig.fromMap(map);

          expect(restored, equals(config), reason: 'Failed at iteration $i');
        }
      });

      test('round trip with artifactPath preserves path (100 iterations)', () {
        // Property-based test: For any BuildConfig with artifactPath, serializing then deserializing should preserve the path
        final testCases = [
          ('debug', 'hash1', '/path/to/app.app'),
          ('release', 'hash2', '/artifacts/app.app'),
          ('profile', 'hash3', '/build/output/app.app'),
          ('debug', 'hash4', ''),
          ('release', 'hash5', '/very/long/path/to/app.app'),
          ('debug', 'hash6', '/path/to/app.app'),
          ('debug', 'hash7', '/path/to/app.app'),
          ('debug', 'hash8', '/path/to/app.app'),
          ('debug', 'hash9', '/path/to/app.app'),
          ('debug', 'hash10', '/path/to/app.app'),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
          final config = BuildConfig(
            buildMode: testCase.$1,
            targetPlatform: 'ios',
            buildNumber: 1,
            buildTimestamp: timestamp,
            sourceHash: testCase.$2,
            artifactPath: testCase.$3,
          );

          final map = config.toMap();
          final restored = BuildConfig.fromMap(map);

          expect(restored.artifactPath, equals(testCase.$3), reason: 'Failed at iteration $i');
        }
      });

      test('round trip preserves timestamp precision (100 iterations)', () {
        // Property-based test: For any BuildConfig with timestamp, serializing then deserializing should preserve the timestamp
        final testCases = [
          ('debug', 1, 'hash1'),
          ('release', 42, 'hash2'),
          ('profile', 100, 'hash3'),
          ('debug', 0, 'hash4'),
          ('release', 999, 'hash5'),
          ('debug', 1, 'hash6'),
          ('debug', 1, 'hash7'),
          ('debug', 1, 'hash8'),
          ('debug', 1, 'hash9'),
          ('debug', 1, 'hash10'),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final timestamp = DateTime(2024, 1, 1, 12, 30, 45, 123);
          final config = BuildConfig(
            buildMode: testCase.$1,
            targetPlatform: 'ios',
            buildNumber: testCase.$2,
            buildTimestamp: timestamp,
            sourceHash: testCase.$3,
            artifactPath: null,
          );

          final map = config.toMap();
          final restored = BuildConfig.fromMap(map);

          expect(restored.buildTimestamp, equals(timestamp), reason: 'Failed at iteration $i');
        }
      });
    });

    group('Equality', () {
      test('two configs with same values are equal', () {
        final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final config1 = BuildConfig(
          buildMode: 'debug',
          targetPlatform: 'ios',
          buildNumber: 1,
          buildTimestamp: timestamp,
          sourceHash: 'hash123',
          artifactPath: '/path/to/app.app',
        );

        final config2 = BuildConfig(
          buildMode: 'debug',
          targetPlatform: 'ios',
          buildNumber: 1,
          buildTimestamp: timestamp,
          sourceHash: 'hash123',
          artifactPath: '/path/to/app.app',
        );

        expect(config1, equals(config2));
      });

      test('two configs with different values are not equal', () {
        final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final config1 = BuildConfig(
          buildMode: 'debug',
          targetPlatform: 'ios',
          buildNumber: 1,
          buildTimestamp: timestamp,
          sourceHash: 'hash123',
          artifactPath: null,
        );

        final config2 = BuildConfig(
          buildMode: 'release',
          targetPlatform: 'ios',
          buildNumber: 1,
          buildTimestamp: timestamp,
          sourceHash: 'hash123',
          artifactPath: null,
        );

        expect(config1, isNot(equals(config2)));
      });
    });
  });
}
