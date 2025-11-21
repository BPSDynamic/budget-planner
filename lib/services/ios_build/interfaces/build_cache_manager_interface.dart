/// Abstract interface for iOS build cache management
abstract class BuildCacheManagerInterface {
  /// Cache a build artifact with a key
  Future<void> cacheArtifact(String key, String artifactPath);

  /// Retrieve a cached artifact by key
  Future<String?> retrieveArtifact(String key);

  /// Invalidate cache entries matching a pattern
  Future<void> invalidateCache(String pattern);

  /// Get cache statistics including hit/miss rates
  Future<Map<String, dynamic>> getCacheStats();

  /// Clear all cached artifacts
  Future<void> clearCache();
}
