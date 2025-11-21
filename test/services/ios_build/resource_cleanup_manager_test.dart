import 'package:test/test.dart';
import 'package:budget_planner/services/ios_build/resource_cleanup_manager.dart';
import 'dart:io';

void main() {
  group('ResourceCleanupManager', () {
    late String testTempDir;
    late String testDataDir;

    setUp(() {
      // Create temporary test directories
      testTempDir = Directory.systemTemp.createTempSync('cleanup_temp_test_').path;
      testDataDir = Directory.systemTemp.createTempSync('cleanup_data_test_').path;
    });

    tearDown(() {
      // Clean up test directories
      final tempDir = Directory(testTempDir);
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }

      final dataDir = Directory(testDataDir);
      if (dataDir.existsSync()) {
        dataDir.deleteSync(recursive: true);
      }
    });

    group('Property: Resource Cleanup Completeness', () {
      // **Feature: ios-emulator-build-test, Property 10: Resource Cleanup Completeness**
      // **Validates: Requirements 10.1, 10.3**

      test('cleanup removes all temporary artifacts (100 iterations)', () async {
        // Property-based test: For any completed test execution, the cleanup process SHALL remove temporary artifacts
        final testCases = [
          ('artifact-001', 'content-001'),
          ('artifact-002', 'content-002'),
          ('artifact-003', 'content-003'),
          ('artifact-004', 'content-004'),
          ('artifact-005', 'content-005'),
          ('artifact-006', 'content-006'),
          ('artifact-007', 'content-007'),
          ('artifact-008', 'content-008'),
          ('artifact-009', 'content-009'),
          ('artifact-010', 'content-010'),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final artifactName = testCase.$1;
          final content = testCase.$2;

          // Create temporary artifacts
          final artifactFile = File('$testTempDir/$artifactName-$i');
          artifactFile.writeAsStringSync(content);

          // Verify artifact exists
          expect(artifactFile.existsSync(), isTrue, reason: 'Artifact should exist before cleanup at iteration $i');

          // Create cleanup manager and remove artifacts
          final cleanupManager = ResourceCleanupManager(
            tempArtifactsDirectory: testTempDir,
            testDataDirectory: testDataDir,
          );
          await cleanupManager.removeTemporaryArtifacts();

          // Verify artifact is removed
          expect(artifactFile.existsSync(), isFalse, reason: 'Artifact should be removed after cleanup at iteration $i');
        }
      });

      test('cleanup reports correct freed resource count (100 iterations)', () async {
        // Property-based test: For any cleanup operation, the report should accurately reflect freed resources
        final testCases = [
          (1, 'single-artifact'),
          (2, 'double-artifact'),
          (3, 'triple-artifact'),
          (4, 'quad-artifact'),
          (5, 'five-artifact'),
          (6, 'six-artifact'),
          (7, 'seven-artifact'),
          (8, 'eight-artifact'),
          (9, 'nine-artifact'),
          (10, 'ten-artifact'),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final artifactCount = testCase.$1;
          final prefix = testCase.$2;

          // Create multiple temporary artifacts
          for (int j = 0; j < artifactCount; j++) {
            final artifactFile = File('$testTempDir/$prefix-$j-$i');
            artifactFile.writeAsStringSync('test artifact content $j');
          }

          // Create cleanup manager and remove artifacts
          final cleanupManager = ResourceCleanupManager(
            tempArtifactsDirectory: testTempDir,
            testDataDirectory: testDataDir,
          );
          await cleanupManager.removeTemporaryArtifacts();

          // Get cleanup report
          final report = await cleanupManager.reportFreedResources();

          // Verify report contains expected fields
          expect(report.containsKey('freedMemoryMB'), isTrue, reason: 'Report should contain freedMemoryMB at iteration $i');
          expect(report.containsKey('removedArtifactCount'), isTrue, reason: 'Report should contain removedArtifactCount at iteration $i');
          expect(report.containsKey('timestamp'), isTrue, reason: 'Report should contain timestamp at iteration $i');
          expect(report['status'], equals('cleanup_completed'), reason: 'Report status should be cleanup_completed at iteration $i');

          // Verify removed artifact count matches
          expect(report['removedArtifactCount'], greaterThanOrEqualTo(artifactCount), reason: 'Removed artifact count should match at iteration $i');
        }
      });

      test('cleanup clears all test data (100 iterations)', () async {
        // Property-based test: For any test data directory, cleanup should remove all test data files
        final testCases = [
          ('test-data-001', 'data-content-001'),
          ('test-data-002', 'data-content-002'),
          ('test-data-003', 'data-content-003'),
          ('test-data-004', 'data-content-004'),
          ('test-data-005', 'data-content-005'),
          ('test-data-006', 'data-content-006'),
          ('test-data-007', 'data-content-007'),
          ('test-data-008', 'data-content-008'),
          ('test-data-009', 'data-content-009'),
          ('test-data-010', 'data-content-010'),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final dataName = testCase.$1;
          final content = testCase.$2;

          // Create test data files
          final dataFile = File('$testDataDir/$dataName-$i');
          dataFile.writeAsStringSync(content);

          // Verify data file exists
          expect(dataFile.existsSync(), isTrue, reason: 'Test data should exist before cleanup at iteration $i');

          // Create cleanup manager and clear test data
          final cleanupManager = ResourceCleanupManager(
            tempArtifactsDirectory: testTempDir,
            testDataDirectory: testDataDir,
          );
          await cleanupManager.clearTestData();

          // Verify data file is removed
          expect(dataFile.existsSync(), isFalse, reason: 'Test data should be removed after cleanup at iteration $i');
        }
      });

      test('cleanup prevents resource exhaustion monitoring (100 iterations)', () async {
        // Property-based test: For any system state, resource exhaustion monitoring should report status
        for (int i = 0; i < 100; i++) {
          final cleanupManager = ResourceCleanupManager(
            tempArtifactsDirectory: testTempDir,
            testDataDirectory: testDataDir,
          );

          // Monitor resource exhaustion
          final resourceStatus = await cleanupManager.preventResourceExhaustion();

          // Verify resource status report contains expected fields
          expect(resourceStatus.containsKey('isExhausted'), isTrue, reason: 'Resource status should contain isExhausted at iteration $i');
          expect(resourceStatus.containsKey('timestamp'), isTrue, reason: 'Resource status should contain timestamp at iteration $i');
          expect(resourceStatus.containsKey('recommendation'), isTrue, reason: 'Resource status should contain recommendation at iteration $i');

          // Verify isExhausted is a boolean
          expect(resourceStatus['isExhausted'], isA<bool>(), reason: 'isExhausted should be a boolean at iteration $i');
        }
      });

      test('cleanup report contains all required fields (100 iterations)', () async {
        // Property-based test: For any cleanup operation, the report should contain all required fields
        for (int i = 0; i < 100; i++) {
          // Create some temporary artifacts
          final artifactFile = File('$testTempDir/artifact-$i');
          artifactFile.writeAsStringSync('test content');

          final cleanupManager = ResourceCleanupManager(
            tempArtifactsDirectory: testTempDir,
            testDataDirectory: testDataDir,
          );

          // Perform cleanup
          await cleanupManager.removeTemporaryArtifacts();

          // Get cleanup report
          final report = await cleanupManager.reportFreedResources();

          // Verify all required fields are present
          expect(report.containsKey('freedMemoryMB'), isTrue, reason: 'Report should contain freedMemoryMB at iteration $i');
          expect(report.containsKey('removedArtifactCount'), isTrue, reason: 'Report should contain removedArtifactCount at iteration $i');
          expect(report.containsKey('shutdownEmulatorCount'), isTrue, reason: 'Report should contain shutdownEmulatorCount at iteration $i');
          expect(report.containsKey('timestamp'), isTrue, reason: 'Report should contain timestamp at iteration $i');
          expect(report.containsKey('status'), isTrue, reason: 'Report should contain status at iteration $i');

          // Verify field types
          expect(report['freedMemoryMB'], isA<int>(), reason: 'freedMemoryMB should be an int at iteration $i');
          expect(report['removedArtifactCount'], isA<int>(), reason: 'removedArtifactCount should be an int at iteration $i');
          expect(report['shutdownEmulatorCount'], isA<int>(), reason: 'shutdownEmulatorCount should be an int at iteration $i');
          expect(report['timestamp'], isA<String>(), reason: 'timestamp should be a String at iteration $i');
          expect(report['status'], isA<String>(), reason: 'status should be a String at iteration $i');
        }
      });

      test('cleanup statistics are tracked correctly (100 iterations)', () async {
        // Property-based test: For any cleanup operation, statistics should be tracked and reported
        final testCases = [
          (1, 'stat-test-001'),
          (2, 'stat-test-002'),
          (3, 'stat-test-003'),
          (4, 'stat-test-004'),
          (5, 'stat-test-005'),
          (6, 'stat-test-006'),
          (7, 'stat-test-007'),
          (8, 'stat-test-008'),
          (9, 'stat-test-009'),
          (10, 'stat-test-010'),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final artifactCount = testCase.$1;
          final prefix = testCase.$2;

          // Create artifacts
          for (int j = 0; j < artifactCount; j++) {
            final artifactFile = File('$testTempDir/$prefix-$j-$i');
            artifactFile.writeAsStringSync('test artifact');
          }

          final cleanupManager = ResourceCleanupManager(
            tempArtifactsDirectory: testTempDir,
            testDataDirectory: testDataDir,
          );

          // Perform cleanup
          await cleanupManager.removeTemporaryArtifacts();

          // Get report
          final report = await cleanupManager.reportFreedResources();

          // Verify statistics are non-negative
          expect(report['freedMemoryMB'], greaterThanOrEqualTo(0), reason: 'freedMemoryMB should be non-negative at iteration $i');
          expect(report['removedArtifactCount'], greaterThanOrEqualTo(0), reason: 'removedArtifactCount should be non-negative at iteration $i');
          expect(report['shutdownEmulatorCount'], greaterThanOrEqualTo(0), reason: 'shutdownEmulatorCount should be non-negative at iteration $i');
        }
      });

      test('cleanup handles empty directories gracefully (100 iterations)', () async {
        // Property-based test: For any empty directory, cleanup should complete without errors
        for (int i = 0; i < 100; i++) {
          final cleanupManager = ResourceCleanupManager(
            tempArtifactsDirectory: testTempDir,
            testDataDirectory: testDataDir,
          );

          // Perform cleanup on empty directories
          await cleanupManager.removeTemporaryArtifacts();
          await cleanupManager.clearTestData();

          // Get report
          final report = await cleanupManager.reportFreedResources();

          // Verify cleanup completed successfully
          expect(report['status'], equals('cleanup_completed'), reason: 'Cleanup should complete successfully on empty directories at iteration $i');
        }
      });

      test('cleanup resets statistics correctly (100 iterations)', () async {
        // Property-based test: For any cleanup manager, statistics should reset when requested
        for (int i = 0; i < 100; i++) {
          // Create artifacts
          final artifactFile = File('$testTempDir/artifact-$i');
          artifactFile.writeAsStringSync('test content');

          final cleanupManager = ResourceCleanupManager(
            tempArtifactsDirectory: testTempDir,
            testDataDirectory: testDataDir,
          );

          // Perform cleanup
          await cleanupManager.removeTemporaryArtifacts();

          // Get report before reset
          var report = await cleanupManager.reportFreedResources();
          expect(report['removedArtifactCount'], greaterThan(0), reason: 'Should have removed artifacts at iteration $i');

          // Reset statistics
          cleanupManager.resetStatistics();

          // Get report after reset
          report = await cleanupManager.reportFreedResources();
          expect(report['removedArtifactCount'], equals(0), reason: 'Removed artifact count should be zero after reset at iteration $i');
          expect(report['freedMemoryMB'], equals(0), reason: 'Freed memory should be zero after reset at iteration $i');
          expect(report['shutdownEmulatorCount'], equals(0), reason: 'Shutdown emulator count should be zero after reset at iteration $i');
        }
      });
    });

    group('Cleanup operations', () {
      test('removes nested artifact directories', () async {
        // Create nested directory structure with artifacts
        final nestedDir = Directory('$testTempDir/nested/deep/structure');
        nestedDir.createSync(recursive: true);

        final artifactFile = File('${nestedDir.path}/artifact.bin');
        artifactFile.writeAsStringSync('test artifact');

        expect(artifactFile.existsSync(), isTrue);

        // Perform cleanup
        final cleanupManager = ResourceCleanupManager(
          tempArtifactsDirectory: testTempDir,
          testDataDirectory: testDataDir,
        );
        await cleanupManager.removeTemporaryArtifacts();

        // Verify artifact is removed
        expect(artifactFile.existsSync(), isFalse);
      });

      test('reports freed memory in megabytes', () async {
        // Create artifacts with known size
        final artifactFile = File('$testTempDir/large-artifact');
        // Create a 1MB file
        artifactFile.writeAsStringSync('x' * (1024 * 1024));

        final cleanupManager = ResourceCleanupManager(
          tempArtifactsDirectory: testTempDir,
          testDataDirectory: testDataDir,
        );
        await cleanupManager.removeTemporaryArtifacts();

        final report = await cleanupManager.reportFreedResources();
        expect(report['freedMemoryMB'], greaterThan(0), reason: 'Should report freed memory');
      });

      test('handles cleanup of multiple artifact types', () async {
        // Create different types of artifacts
        final types = ['build', 'test', 'cache', 'log'];
        for (final type in types) {
          final file = File('$testTempDir/$type-artifact');
          file.writeAsStringSync('$type content');
        }

        final cleanupManager = ResourceCleanupManager(
          tempArtifactsDirectory: testTempDir,
          testDataDirectory: testDataDir,
        );
        await cleanupManager.removeTemporaryArtifacts();

        // Verify all artifacts are removed
        for (final type in types) {
          final file = File('$testTempDir/$type-artifact');
          expect(file.existsSync(), isFalse);
        }
      });
    });

    group('Error handling', () {
      test('handles non-existent directories gracefully', () async {
        final cleanupManager = ResourceCleanupManager(
          tempArtifactsDirectory: '/non/existent/path',
          testDataDirectory: '/another/non/existent/path',
        );

        // Should not throw exception
        await cleanupManager.removeTemporaryArtifacts();
        await cleanupManager.clearTestData();

        final report = await cleanupManager.reportFreedResources();
        expect(report['status'], equals('cleanup_completed'));
      });

      test('resource exhaustion monitoring handles errors gracefully', () async {
        final cleanupManager = ResourceCleanupManager(
          tempArtifactsDirectory: testTempDir,
          testDataDirectory: testDataDir,
        );

        // Should not throw exception
        final resourceStatus = await cleanupManager.preventResourceExhaustion();
        expect(resourceStatus.containsKey('timestamp'), isTrue);
      });
    });
  });
}
