/// Abstract interface for iOS emulator resource cleanup management
abstract class ResourceCleanupManagerInterface {
  /// Shutdown all running emulators
  Future<void> shutdownEmulators();

  /// Remove temporary build artifacts
  Future<void> removeTemporaryArtifacts();

  /// Clear test data from emulators
  Future<void> clearTestData();

  /// Report freed resources after cleanup
  Future<Map<String, dynamic>> reportFreedResources();

  /// Monitor and prevent resource exhaustion
  Future<Map<String, dynamic>> preventResourceExhaustion();
}
