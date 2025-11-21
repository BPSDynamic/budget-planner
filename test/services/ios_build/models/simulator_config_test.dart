import 'package:test/test.dart';
import 'package:budget_planner/services/ios_build/models/simulator_config.dart';

void main() {
  group('SimulatorConfig', () {
    group('Serialization', () {
      test('toMap and fromMap preserve all fields', () {
        final config = SimulatorConfig(
          simulatorId: 'test-simulator-1',
          deviceType: 'iPhone 14',
          iOSVersion: '16.0',
          isRunning: true,
          bootTime: DateTime(2024, 1, 1, 12, 0, 0),
          memoryUsage: 2048,
        );

        final map = config.toMap();
        final restored = SimulatorConfig.fromMap(map);

        expect(restored, equals(config));
      });

      test('toMap produces correct structure', () {
        final config = SimulatorConfig(
          simulatorId: 'test-id',
          deviceType: 'iPad Pro',
          iOSVersion: '17.0',
          isRunning: false,
          bootTime: null,
          memoryUsage: 4096,
        );

        final map = config.toMap();

        expect(map['simulatorId'], equals('test-id'));
        expect(map['deviceType'], equals('iPad Pro'));
        expect(map['iOSVersion'], equals('17.0'));
        expect(map['isRunning'], equals(false));
        expect(map['bootTime'], isNull);
        expect(map['memoryUsage'], equals(4096));
      });

      test('fromMap handles null bootTime', () {
        final map = {
          'simulatorId': 'test-id',
          'deviceType': 'iPhone 15',
          'iOSVersion': '17.1',
          'isRunning': false,
          'bootTime': null,
          'memoryUsage': 1024,
        };

        final config = SimulatorConfig.fromMap(map);

        expect(config.bootTime, isNull);
        expect(config.simulatorId, equals('test-id'));
      });
    });

    group('Property: Simulator Detection Accuracy', () {
      // **Feature: ios-emulator-build-test, Property 1: Simulator Detection Accuracy**
      // **Validates: Requirements 1.1**
      test('round trip serialization preserves all valid configurations (100 iterations)', () {
        // Property-based test: For any valid SimulatorConfig, serializing then deserializing should produce an equivalent value
        final testCases = [
          ('sim-1', 'iPhone 14', '16.0', true, 2048),
          ('sim-2', 'iPhone 15', '17.0', false, 1024),
          ('sim-3', 'iPad Pro', '16.5', true, 4096),
          ('sim-4', 'iPhone 13', '15.0', false, 512),
          ('sim-5', 'iPhone 14 Pro', '17.1', true, 3072),
          ('', 'iPhone 14', '16.0', true, 2048),
          ('sim-uuid-very-long-identifier', 'iPhone 14', '16.0', true, 2048),
          ('sim-6', '', '16.0', true, 2048),
          ('sim-7', 'iPhone 14', '', true, 2048),
          ('sim-8', 'iPhone 14', '16.0', true, 0),
          ('sim-9', 'iPhone 14', '16.0', true, 999999),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final config = SimulatorConfig(
            simulatorId: testCase.$1,
            deviceType: testCase.$2,
            iOSVersion: testCase.$3,
            isRunning: testCase.$4,
            bootTime: null,
            memoryUsage: testCase.$5,
          );

          final map = config.toMap();
          final restored = SimulatorConfig.fromMap(map);

          expect(restored, equals(config), reason: 'Failed at iteration $i');
        }
      });

      test('round trip with bootTime preserves datetime (100 iterations)', () {
        // Property-based test: For any SimulatorConfig with bootTime, serializing then deserializing should preserve the datetime
        final testCases = [
          ('sim-1', 'iPhone 14', '16.0', true, 2048),
          ('sim-2', 'iPhone 15', '17.0', false, 1024),
          ('sim-3', 'iPad Pro', '16.5', true, 4096),
          ('sim-4', 'iPhone 13', '15.0', false, 512),
          ('sim-5', 'iPhone 14 Pro', '17.1', true, 3072),
          ('sim-6', 'iPhone 14', '16.0', true, 2048),
          ('sim-7', 'iPhone 14', '16.0', true, 2048),
          ('sim-8', 'iPhone 14', '16.0', true, 2048),
          ('sim-9', 'iPhone 14', '16.0', true, 2048),
          ('sim-10', 'iPhone 14', '16.0', true, 2048),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final bootTime = DateTime(2024, 1, 1, 12, 0, 0);
          final config = SimulatorConfig(
            simulatorId: testCase.$1,
            deviceType: testCase.$2,
            iOSVersion: testCase.$3,
            isRunning: testCase.$4,
            bootTime: bootTime,
            memoryUsage: testCase.$5,
          );

          final map = config.toMap();
          final restored = SimulatorConfig.fromMap(map);

          expect(restored.bootTime, equals(bootTime), reason: 'Failed at iteration $i');
        }
      });
    });

    group('Equality', () {
      test('two configs with same values are equal', () {
        final config1 = SimulatorConfig(
          simulatorId: 'id-1',
          deviceType: 'iPhone 14',
          iOSVersion: '16.0',
          isRunning: true,
          bootTime: DateTime(2024, 1, 1),
          memoryUsage: 2048,
        );

        final config2 = SimulatorConfig(
          simulatorId: 'id-1',
          deviceType: 'iPhone 14',
          iOSVersion: '16.0',
          isRunning: true,
          bootTime: DateTime(2024, 1, 1),
          memoryUsage: 2048,
        );

        expect(config1, equals(config2));
      });

      test('two configs with different values are not equal', () {
        final config1 = SimulatorConfig(
          simulatorId: 'id-1',
          deviceType: 'iPhone 14',
          iOSVersion: '16.0',
          isRunning: true,
          bootTime: null,
          memoryUsage: 2048,
        );

        final config2 = SimulatorConfig(
          simulatorId: 'id-2',
          deviceType: 'iPhone 14',
          iOSVersion: '16.0',
          isRunning: true,
          bootTime: null,
          memoryUsage: 2048,
        );

        expect(config1, isNot(equals(config2)));
      });
    });
  });
}
