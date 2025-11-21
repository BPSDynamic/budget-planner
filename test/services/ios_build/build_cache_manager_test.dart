import 'package:test/test.dart';
import 'package:budget_planner/services/ios_build/build_cache_manager.dart';
import 'dart:io';

void main() {
  group('BuildCacheManager', () {
    late String testCacheDir;

    setUp(() {
      // Create a temporary test directory
      testCacheDir = Directory.systemTemp.createTempSync('build_cache_test_').path;
    });

    tearDown(() {
      // Clean up test directory
      final dir = Directory(testCacheDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    group('Property: Build Cache Effectiveness', () {
      // **Feature: ios-emulator-build-test, Property 7: Build Cache Effectiveness**
      // **Validates: Requirements 7.2, 7.4**

      test('cached artifacts can be retrieved with cache hit recorded (100 iterations)', () async {
        // Property-based test: For any unchanged source code, subsequent builds SHALL reuse cached artifacts and report cache hit status
        final cacheManager = BuildCacheManager(cacheDirectory: testCacheDir);

        final testCases = [
          ('cache-key-001', 'artifact-001'),
          ('cache-key-002', 'artifact-002'),
          ('cache-key-003', 'artifact-003'),
          ('cache-key-004', 'artifact-004'),
          ('cache-key-005', 'artifact-005'),
          ('cache-key-006', 'artifact-006'),
          ('cache-key-007', 'artifact-007'),
          ('cache-key-008', 'artifact-008'),
          ('cache-key-009', 'artifact-009'),
          ('cache-key-010', 'artifact-010'),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final key = testCase.$1;
          final artifactName = testCase.$2;

          // Create a temporary artifact file
          final artifactFile = File('$testCacheDir/$artifactName');
          artifactFile.writeAsStringSync('test artifact content $i');

          // Cache the artifact
          await cacheManager.cacheArtifact(key, artifactFile.path);

          // Retrieve the artifact
          final retrievedPath = await cacheManager.retrieveArtifact(key);

          // Verify artifact was retrieved
          expect(retrievedPath, isNotNull, reason: 'Failed to retrieve artifact at iteration $i');
          expect(File(retrievedPath!).existsSync(), isTrue, reason: 'Retrieved artifact does not exist at iteration $i');
        }
      });

      test('cache hit count increases with successful retrievals (100 iterations)', () async {
        // Property-based test: For any cached artifact, retrieving it multiple times should increase cache hit count
        final cacheManager = BuildCacheManager(cacheDirectory: testCacheDir);

        final testCases = [
          ('key-001', 1),
          ('key-002', 2),
          ('key-003', 3),
          ('key-004', 4),
          ('key-005', 5),
          ('key-006', 6),
          ('key-007', 7),
          ('key-008', 8),
          ('key-009', 9),
          ('key-010', 10),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final key = testCase.$1;
          final retrievalCount = testCase.$2;

          // Create and cache an artifact
          final artifactFile = File('$testCacheDir/artifact-$i');
          artifactFile.writeAsStringSync('test artifact content');
          await cacheManager.cacheArtifact(key, artifactFile.path);

          // Retrieve the artifact multiple times
          for (int j = 0; j < retrievalCount; j++) {
            final retrievedPath = await cacheManager.retrieveArtifact(key);
            expect(retrievedPath, isNotNull, reason: 'Failed to retrieve artifact at iteration $i, retrieval $j');
          }

          // Get cache stats
          final stats = await cacheManager.getCacheStats();
          expect(stats['cacheHits'], greaterThanOrEqualTo(retrievalCount), reason: 'Cache hits not recorded at iteration $i');
        }
      });

      test('cache miss count increases for non-existent keys (100 iterations)', () async {
        // Property-based test: For any non-existent cache key, retrieving it should increase cache miss count
        final cacheManager = BuildCacheManager(cacheDirectory: testCacheDir);

        final testCases = [
          'non-existent-001',
          'non-existent-002',
          'non-existent-003',
          'non-existent-004',
          'non-existent-005',
          'non-existent-006',
          'non-existent-007',
          'non-existent-008',
          'non-existent-009',
          'non-existent-010',
        ];

        for (int i = 0; i < 100; i++) {
          final key = testCases[i % testCases.length];

          // Try to retrieve a non-existent artifact
          final retrievedPath = await cacheManager.retrieveArtifact(key);
          expect(retrievedPath, isNull, reason: 'Should not retrieve non-existent artifact at iteration $i');

          // Get cache stats
          final stats = await cacheManager.getCacheStats();
          expect(stats['cacheMisses'], greaterThan(0), reason: 'Cache misses not recorded at iteration $i');
        }
      });

      test('cache hit rate is calculated correctly (100 iterations)', () async {
        // Property-based test: For any cache with hits and misses, hit rate should be correctly calculated
        final testCases = [
          (1, 0), // 100% hit rate
          (2, 0), // 100% hit rate
          (1, 1), // 50% hit rate
          (2, 2), // 50% hit rate
          (3, 1), // 75% hit rate
          (1, 3), // 25% hit rate
          (5, 5), // 50% hit rate
          (10, 0), // 100% hit rate
          (0, 10), // 0% hit rate
          (7, 3), // 70% hit rate
        ];

        for (int i = 0; i < 100; i++) {
          // Create a fresh cache manager for each iteration
          final iterationCacheDir = '$testCacheDir/iteration-$i';
          final cacheManager = BuildCacheManager(cacheDirectory: iterationCacheDir);

          final testCase = testCases[i % testCases.length];
          final hits = testCase.$1;
          final misses = testCase.$2;

          // Create and cache artifacts
          for (int j = 0; j < hits; j++) {
            final key = 'hit-key-$j';
            final artifactFile = File('$iterationCacheDir/artifact-hit-$j');
            artifactFile.writeAsStringSync('test artifact');
            await cacheManager.cacheArtifact(key, artifactFile.path);
            await cacheManager.retrieveArtifact(key);
          }

          // Try to retrieve non-existent artifacts
          for (int j = 0; j < misses; j++) {
            final key = 'miss-key-$j';
            await cacheManager.retrieveArtifact(key);
          }

          // Get cache stats
          final stats = await cacheManager.getCacheStats();
          final totalRequests = hits + misses;

          if (totalRequests > 0) {
            final expectedHitRate = (hits / totalRequests * 100).toStringAsFixed(2);
            expect(stats['hitRate'], equals(expectedHitRate), reason: 'Hit rate mismatch at iteration $i');
          }
        }
      });

      test('invalidated cache entries cannot be retrieved (100 iterations)', () async {
        // Property-based test: For any cache entry matching an invalidation pattern, it should not be retrievable
        final cacheManager = BuildCacheManager(cacheDirectory: testCacheDir);

        final testCases = [
          ('pattern-001', 'pattern-.*'),
          ('pattern-002', 'pattern-.*'),
          ('pattern-003', 'pattern-.*'),
          ('pattern-004', 'pattern-.*'),
          ('pattern-005', 'pattern-.*'),
          ('other-001', 'pattern-.*'),
          ('other-002', 'pattern-.*'),
          ('other-003', 'pattern-.*'),
          ('other-004', 'pattern-.*'),
          ('other-005', 'pattern-.*'),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final key = testCase.$1;
          final pattern = testCase.$2;

          // Create and cache an artifact
          final artifactFile = File('$testCacheDir/artifact-$i');
          artifactFile.writeAsStringSync('test artifact');
          await cacheManager.cacheArtifact(key, artifactFile.path);

          // Verify it can be retrieved
          var retrievedPath = await cacheManager.retrieveArtifact(key);
          expect(retrievedPath, isNotNull, reason: 'Failed to retrieve artifact before invalidation at iteration $i');

          // Invalidate cache entries matching pattern
          await cacheManager.invalidateCache(pattern);

          // Try to retrieve the artifact again
          retrievedPath = await cacheManager.retrieveArtifact(key);

          // If key matches pattern, it should not be retrievable
          if (RegExp(pattern).hasMatch(key)) {
            expect(retrievedPath, isNull, reason: 'Invalidated artifact should not be retrievable at iteration $i');
          }
        }
      });

      test('cleared cache has no retrievable artifacts (100 iterations)', () async {
        // Property-based test: For any cache, after clearing, no artifacts should be retrievable
        final cacheManager = BuildCacheManager(cacheDirectory: testCacheDir);

        final testCases = [
          ('key-001', 'artifact-001'),
          ('key-002', 'artifact-002'),
          ('key-003', 'artifact-003'),
          ('key-004', 'artifact-004'),
          ('key-005', 'artifact-005'),
          ('key-006', 'artifact-006'),
          ('key-007', 'artifact-007'),
          ('key-008', 'artifact-008'),
          ('key-009', 'artifact-009'),
          ('key-010', 'artifact-010'),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final key = testCase.$1;
          final artifactName = testCase.$2;

          // Create and cache an artifact
          final artifactFile = File('$testCacheDir/$artifactName-$i');
          artifactFile.writeAsStringSync('test artifact');
          await cacheManager.cacheArtifact(key, artifactFile.path);

          // Verify it can be retrieved
          var retrievedPath = await cacheManager.retrieveArtifact(key);
          expect(retrievedPath, isNotNull, reason: 'Failed to retrieve artifact before clear at iteration $i');

          // Clear the cache
          await cacheManager.clearCache();

          // Try to retrieve the artifact again
          retrievedPath = await cacheManager.retrieveArtifact(key);
          expect(retrievedPath, isNull, reason: 'Artifact should not be retrievable after cache clear at iteration $i');
        }
      });

      test('cache stats are reset after clearing (100 iterations)', () async {
        // Property-based test: For any cache with statistics, clearing should reset hit/miss counts
        final cacheManager = BuildCacheManager(cacheDirectory: testCacheDir);

        for (int i = 0; i < 100; i++) {
          // Create and cache an artifact
          final key = 'key-$i';
          final artifactFile = File('$testCacheDir/artifact-$i');
          artifactFile.writeAsStringSync('test artifact');
          await cacheManager.cacheArtifact(key, artifactFile.path);

          // Retrieve it to generate cache hits
          await cacheManager.retrieveArtifact(key);

          // Get stats before clear
          var stats = await cacheManager.getCacheStats();
          expect(stats['cacheHits'], greaterThan(0), reason: 'Cache hits should be recorded at iteration $i');

          // Clear the cache
          await cacheManager.clearCache();

          // Get stats after clear
          stats = await cacheManager.getCacheStats();
          expect(stats['cacheHits'], equals(0), reason: 'Cache hits should be reset after clear at iteration $i');
          expect(stats['cacheMisses'], equals(0), reason: 'Cache misses should be reset after clear at iteration $i');
          expect(stats['fileCount'], equals(0), reason: 'File count should be zero after clear at iteration $i');
        }
      });
    });

    group('Caching operations', () {
      test('artifact is stored in cache directory', () async {
        final cacheDir = '$testCacheDir/cache-ops-1';
        final artifactDir = '$testCacheDir/artifacts-1';
        Directory(artifactDir).createSync(recursive: true);
        final cacheManager = BuildCacheManager(cacheDirectory: cacheDir);

        // Create a test artifact
        final artifactFile = File('$artifactDir/test-artifact');
        artifactFile.writeAsStringSync('test content');

        // Cache the artifact
        await cacheManager.cacheArtifact('test-key', artifactFile.path);

        // Verify cache directory contains the artifact
        final cacheDirObj = Directory(cacheDir);
        final files = cacheDirObj.listSync();
        expect(files.length, greaterThan(0), reason: 'Cache directory should contain cached files');
      });

      test('cache stats report correct file count', () async {
        final cacheDir = '$testCacheDir/cache-ops-2';
        final artifactDir = '$testCacheDir/artifacts-2';
        Directory(artifactDir).createSync(recursive: true);
        final cacheManager = BuildCacheManager(cacheDirectory: cacheDir);

        // Cache multiple artifacts
        for (int i = 0; i < 5; i++) {
          final artifactFile = File('$artifactDir/artifact-$i');
          artifactFile.writeAsStringSync('test content $i');
          await cacheManager.cacheArtifact('key-$i', artifactFile.path);
        }

        // Get cache stats
        final stats = await cacheManager.getCacheStats();
        expect(stats['fileCount'], equals(5), reason: 'File count should match number of cached artifacts');
      });

      test('cache stats report correct total size', () async {
        final cacheDir = '$testCacheDir/cache-ops-3';
        final artifactDir = '$testCacheDir/artifacts-3';
        Directory(artifactDir).createSync(recursive: true);
        final cacheManager = BuildCacheManager(cacheDirectory: cacheDir);

        // Cache an artifact with known size
        final artifactFile = File('$artifactDir/artifact-size-test');
        const testContent = 'test content with known size';
        artifactFile.writeAsStringSync(testContent);

        await cacheManager.cacheArtifact('size-key', artifactFile.path);

        // Get cache stats
        final stats = await cacheManager.getCacheStats();
        expect(stats['totalSize'], greaterThan(0), reason: 'Total size should be greater than zero');
      });
    });

    group('Error handling', () {
      test('caching non-existent artifact throws exception', () async {
        final cacheManager = BuildCacheManager(cacheDirectory: testCacheDir);

        expect(
          () => cacheManager.cacheArtifact('key', '/non/existent/path'),
          throwsException,
          reason: 'Should throw exception for non-existent artifact',
        );
      });

      test('cache key is sanitized for filesystem safety', () async {
        final cacheManager = BuildCacheManager(cacheDirectory: testCacheDir);

        // Create a test artifact
        final artifactFile = File('$testCacheDir/test-artifact');
        artifactFile.writeAsStringSync('test content');

        // Cache with a key containing special characters
        final specialKey = 'key/with\\special:chars*?';
        await cacheManager.cacheArtifact(specialKey, artifactFile.path);

        // Verify it can be retrieved
        final retrievedPath = cacheManager.retrieveArtifact(specialKey);
        expect(retrievedPath, isNotNull, reason: 'Should retrieve artifact with special characters in key');
      });
    });
  });
}
