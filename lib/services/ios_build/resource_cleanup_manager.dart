import 'dart:io';
import 'package:path/path.dart' as path;
import 'interfaces/resource_cleanup_manager_interface.dart';

/// Implementation of iOS emulator resource cleanup management
class ResourceCleanupManager implements ResourceCleanupManagerInterface {
  final String tempArtifactsDirectory;
  final String testDataDirectory;
  int _freedMemoryMB = 0;
  int _removedArtifactCount = 0;
  int _shutdownEmulatorCount = 0;

  ResourceCleanupManager({
    required this.tempArtifactsDirectory,
    required this.testDataDirectory,
  });

  /// Shutdown all running emulators
  @override
  Future<void> shutdownEmulators() async {
    try {
      // Get list of running simulators using xcrun simctl
      final result = await Process.run('xcrun', ['simctl', 'list', 'devices', 'booted']);

      if (result.exitCode == 0) {
        final output = result.stdout as String;
        final lines = output.split('\n');

        // Parse simulator UUIDs from output
        final simulatorUuids = <String>[];
        for (final line in lines) {
          // Extract UUID from lines like: "iPhone 14 (XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX) (Booted)"
          final match = RegExp(r'\(([A-F0-9\-]{36})\)').firstMatch(line);
          if (match != null) {
            simulatorUuids.add(match.group(1)!);
          }
        }

        // Shutdown each simulator
        for (final uuid in simulatorUuids) {
          try {
            await Process.run('xcrun', ['simctl', 'shutdown', uuid]);
            _shutdownEmulatorCount++;
          } catch (e) {
            // Continue with next simulator if one fails
          }
        }
      }
    } catch (e) {
      throw Exception('Error shutting down emulators: $e');
    }
  }

  /// Remove temporary build artifacts
  @override
  Future<void> removeTemporaryArtifacts() async {
    try {
      final dir = Directory(tempArtifactsDirectory);

      if (await dir.exists()) {
        final files = dir.listSync(recursive: true);

        for (final file in files) {
          if (file is File) {
            try {
              final fileSize = await file.length();
              await file.delete();
              _removedArtifactCount++;
              _freedMemoryMB += (fileSize / (1024 * 1024)).ceil();
            } catch (e) {
              // Continue with next file if one fails
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error removing temporary artifacts: $e');
    }
  }

  /// Clear test data from emulators
  @override
  Future<void> clearTestData() async {
    try {
      final dir = Directory(testDataDirectory);

      if (await dir.exists()) {
        final files = dir.listSync(recursive: true);

        for (final file in files) {
          if (file is File) {
            try {
              final fileSize = await file.length();
              await file.delete();
              _freedMemoryMB += (fileSize / (1024 * 1024)).ceil();
            } catch (e) {
              // Continue with next file if one fails
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error clearing test data: $e');
    }
  }

  /// Report freed resources after cleanup
  @override
  Future<Map<String, dynamic>> reportFreedResources() async {
    try {
      return {
        'freedMemoryMB': _freedMemoryMB,
        'removedArtifactCount': _removedArtifactCount,
        'shutdownEmulatorCount': _shutdownEmulatorCount,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'cleanup_completed',
      };
    } catch (e) {
      throw Exception('Error reporting freed resources: $e');
    }
  }

  /// Monitor and prevent resource exhaustion
  @override
  Future<Map<String, dynamic>> preventResourceExhaustion() async {
    try {
      // Get system memory information
      final result = await Process.run('vm_stat', []);

      if (result.exitCode == 0) {
        final output = result.stdout as String;
        final lines = output.split('\n');

        // Parse memory statistics
        int freePages = 0;
        int totalPages = 0;

        for (final line in lines) {
          if (line.contains('Pages free:')) {
            final match = RegExp(r'(\d+)').firstMatch(line);
            if (match != null) {
              freePages = int.parse(match.group(1)!);
            }
          }
          if (line.contains('Pages wired down:')) {
            final match = RegExp(r'(\d+)').firstMatch(line);
            if (match != null) {
              totalPages += int.parse(match.group(1)!);
            }
          }
        }

        // Calculate memory usage percentage (assuming 4KB per page)
        const pageSize = 4096; // bytes
        final freeMemoryMB = (freePages * pageSize) / (1024 * 1024);
        const warningThresholdMB = 500; // Warn if less than 500MB free

        final isExhausted = freeMemoryMB < warningThresholdMB;

        return {
          'freeMemoryMB': freeMemoryMB.toStringAsFixed(2),
          'isExhausted': isExhausted,
          'warningThresholdMB': warningThresholdMB,
          'timestamp': DateTime.now().toIso8601String(),
          'recommendation': isExhausted ? 'Consider running cleanup to free resources' : 'Resources are sufficient',
        };
      }

      return {
        'freeMemoryMB': 'unknown',
        'isExhausted': false,
        'timestamp': DateTime.now().toIso8601String(),
        'recommendation': 'Unable to determine system memory status',
      };
    } catch (e) {
      throw Exception('Error monitoring resource exhaustion: $e');
    }
  }

  /// Reset cleanup statistics
  void resetStatistics() {
    _freedMemoryMB = 0;
    _removedArtifactCount = 0;
    _shutdownEmulatorCount = 0;
  }
}
