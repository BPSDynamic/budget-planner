import 'dart:io';
import 'package:path/path.dart' as path;
import 'interfaces/build_cache_manager_interface.dart';

/// Implementation of iOS build cache management
class BuildCacheManager implements BuildCacheManagerInterface {
  final String cacheDirectory;
  final Map<String, _CacheEntry> _memoryCache = {};
  int _cacheHits = 0;
  int _cacheMisses = 0;

  BuildCacheManager({required this.cacheDirectory}) {
    _initializeCacheDirectory();
  }

  /// Initialize the cache directory
  void _initializeCacheDirectory() {
    final dir = Directory(cacheDirectory);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// Cache a build artifact with a key
  @override
  Future<void> cacheArtifact(String key, String artifactPath) async {
    try {
      final sourceFile = File(artifactPath);
      if (!await sourceFile.exists()) {
        throw Exception('Artifact file not found at $artifactPath');
      }

      final cacheFilePath = path.join(cacheDirectory, _sanitizeKey(key));
      final cacheFile = File(cacheFilePath);

      // Copy artifact to cache
      await sourceFile.copy(cacheFile.path);

      // Store in memory cache
      _memoryCache[key] = _CacheEntry(
        key: key,
        filePath: cacheFilePath,
        timestamp: DateTime.now(),
        size: await sourceFile.length(),
      );
    } catch (e) {
      throw Exception('Error caching artifact: $e');
    }
  }

  /// Retrieve a cached artifact by key
  @override
  Future<String?> retrieveArtifact(String key) async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(key)) {
        final entry = _memoryCache[key]!;
        final file = File(entry.filePath);

        if (await file.exists()) {
          _cacheHits++;
          return entry.filePath;
        } else {
          // Cache entry is stale, remove it
          _memoryCache.remove(key);
        }
      }

      // Check disk cache
      final cacheFilePath = path.join(cacheDirectory, _sanitizeKey(key));
      final cacheFile = File(cacheFilePath);

      if (await cacheFile.exists()) {
        _cacheHits++;
        // Restore to memory cache
        _memoryCache[key] = _CacheEntry(
          key: key,
          filePath: cacheFilePath,
          timestamp: DateTime.now(),
          size: await cacheFile.length(),
        );
        return cacheFilePath;
      }

      _cacheMisses++;
      return null;
    } catch (e) {
      throw Exception('Error retrieving artifact: $e');
    }
  }

  /// Invalidate cache entries matching a pattern
  @override
  Future<void> invalidateCache(String pattern) async {
    try {
      final regex = RegExp(pattern);

      // Remove from memory cache
      final keysToRemove = _memoryCache.keys.where((key) => regex.hasMatch(key)).toList();
      for (final key in keysToRemove) {
        _memoryCache.remove(key);
      }

      // Remove from disk cache
      final dir = Directory(cacheDirectory);
      if (await dir.exists()) {
        final files = dir.listSync();
        for (final file in files) {
          if (file is File) {
            final fileName = path.basename(file.path);
            if (regex.hasMatch(fileName)) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error invalidating cache: $e');
    }
  }

  /// Get cache statistics including hit/miss rates
  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final dir = Directory(cacheDirectory);
      int totalSize = 0;
      int fileCount = 0;

      if (await dir.exists()) {
        final files = dir.listSync();
        for (final file in files) {
          if (file is File) {
            fileCount++;
            totalSize += await file.length();
          }
        }
      }

      final totalRequests = _cacheHits + _cacheMisses;
      final hitRate = totalRequests > 0 ? (_cacheHits / totalRequests * 100).toStringAsFixed(2) : '0.00';

      return {
        'cacheHits': _cacheHits,
        'cacheMisses': _cacheMisses,
        'totalRequests': totalRequests,
        'hitRate': hitRate,
        'fileCount': fileCount,
        'totalSize': totalSize,
        'cacheDirectory': cacheDirectory,
      };
    } catch (e) {
      throw Exception('Error getting cache stats: $e');
    }
  }

  /// Clear all cached artifacts
  @override
  Future<void> clearCache() async {
    try {
      // Clear memory cache
      _memoryCache.clear();

      // Clear disk cache
      final dir = Directory(cacheDirectory);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }

      // Recreate cache directory
      _initializeCacheDirectory();

      // Reset statistics
      _cacheHits = 0;
      _cacheMisses = 0;
    } catch (e) {
      throw Exception('Error clearing cache: $e');
    }
  }

  /// Sanitize cache key to be filesystem-safe
  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}

/// Internal class to represent a cache entry
class _CacheEntry {
  final String key;
  final String filePath;
  final DateTime timestamp;
  final int size;

  _CacheEntry({
    required this.key,
    required this.filePath,
    required this.timestamp,
    required this.size,
  });
}
