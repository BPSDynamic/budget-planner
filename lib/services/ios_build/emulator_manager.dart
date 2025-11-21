import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'interfaces/emulator_manager_interface.dart';
import 'models/simulator_config.dart';

/// Implementation of iOS emulator management using xcrun simctl
class EmulatorManager implements EmulatorManagerInterface {
  /// Detect all available iOS simulators on the system
  @override
  Future<List<SimulatorConfig>> detectAvailableSimulators() async {
    try {
      final result = await Process.run('xcrun', ['simctl', 'list', 'devices', '--json']);

      if (result.exitCode != 0) {
        throw Exception('Failed to detect simulators: ${result.stderr}');
      }

      final jsonOutput = jsonDecode(result.stdout as String) as Map<String, dynamic>;
      final devices = jsonOutput['devices'] as Map<String, dynamic>;

      final simulators = <SimulatorConfig>[];

      devices.forEach((iOSVersion, deviceList) {
        if (deviceList is List) {
          for (final device in deviceList) {
            if (device is Map<String, dynamic>) {
              final isAvailable = device['isAvailable'] as bool? ?? false;
              if (isAvailable) {
                final simulatorId = device['udid'] as String? ?? '';
                final deviceType = device['name'] as String? ?? '';
                final isRunning = device['state'] == 'Booted';
                final memoryUsage = 0; // xcrun simctl doesn't provide memory directly

                simulators.add(SimulatorConfig(
                  simulatorId: simulatorId,
                  deviceType: deviceType,
                  iOSVersion: iOSVersion,
                  isRunning: isRunning,
                  bootTime: null,
                  memoryUsage: memoryUsage,
                ));
              }
            }
          }
        }
      });

      return simulators;
    } catch (e) {
      throw Exception('Error detecting simulators: $e');
    }
  }

  /// Create a new iOS simulator with specified device type and iOS version
  @override
  Future<SimulatorConfig> createSimulator(String deviceType, String iOSVersion) async {
    try {
      // Get available device types
      final deviceTypesResult = await Process.run('xcrun', ['simctl', 'list', 'devicetypes', '--json']);

      if (deviceTypesResult.exitCode != 0) {
        throw Exception('Failed to list device types: ${deviceTypesResult.stderr}');
      }

      final deviceTypesJson = jsonDecode(deviceTypesResult.stdout as String) as Map<String, dynamic>;
      final deviceTypes = deviceTypesJson['devicetypes'] as List<dynamic>? ?? [];

      String? deviceTypeId;
      for (final dt in deviceTypes) {
        if (dt is Map<String, dynamic> && dt['name'] == deviceType) {
          deviceTypeId = dt['identifier'] as String?;
          break;
        }
      }

      if (deviceTypeId == null) {
        throw Exception('Device type "$deviceType" not found');
      }

      // Get available runtimes
      final runtimesResult = await Process.run('xcrun', ['simctl', 'list', 'runtimes', '--json']);

      if (runtimesResult.exitCode != 0) {
        throw Exception('Failed to list runtimes: ${runtimesResult.stderr}');
      }

      final runtimesJson = jsonDecode(runtimesResult.stdout as String) as Map<String, dynamic>;
      final runtimes = runtimesJson['runtimes'] as List<dynamic>? ?? [];

      String? runtimeId;
      for (final runtime in runtimes) {
        if (runtime is Map<String, dynamic>) {
          final version = runtime['version'] as String?;
          if (version == iOSVersion) {
            runtimeId = runtime['identifier'] as String?;
            break;
          }
        }
      }

      if (runtimeId == null) {
        throw Exception('iOS version "$iOSVersion" not found');
      }

      // Create the simulator
      final createResult = await Process.run('xcrun', [
        'simctl',
        'create',
        '$deviceType-$iOSVersion',
        deviceTypeId,
        runtimeId,
      ]);

      if (createResult.exitCode != 0) {
        throw Exception('Failed to create simulator: ${createResult.stderr}');
      }

      final simulatorId = (createResult.stdout as String).trim();

      return SimulatorConfig(
        simulatorId: simulatorId,
        deviceType: deviceType,
        iOSVersion: iOSVersion,
        isRunning: false,
        bootTime: null,
        memoryUsage: 0,
      );
    } catch (e) {
      throw Exception('Error creating simulator: $e');
    }
  }

  /// Launch a specific iOS simulator
  @override
  Future<void> launchSimulator(String simulatorId) async {
    try {
      final result = await Process.run('open', [
        '-a',
        'Simulator',
        '--args',
        '-CurrentDeviceUDID',
        simulatorId,
      ]);

      if (result.exitCode != 0) {
        throw Exception('Failed to launch simulator: ${result.stderr}');
      }

      // Wait for simulator to boot
      await Future.delayed(const Duration(seconds: 5));
    } catch (e) {
      throw Exception('Error launching simulator: $e');
    }
  }

  /// Shutdown a running iOS simulator
  @override
  Future<void> shutdownSimulator(String simulatorId) async {
    try {
      final result = await Process.run('xcrun', ['simctl', 'shutdown', simulatorId]);

      if (result.exitCode != 0) {
        throw Exception('Failed to shutdown simulator: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Error shutting down simulator: $e');
    }
  }

  /// Check if a simulator is fully booted and responsive
  @override
  Future<bool> isSimulatorReady(String simulatorId) async {
    try {
      final result = await Process.run('xcrun', ['simctl', 'list', 'devices', '--json']);

      if (result.exitCode != 0) {
        return false;
      }

      final jsonOutput = jsonDecode(result.stdout as String) as Map<String, dynamic>;
      final devices = jsonOutput['devices'] as Map<String, dynamic>;

      for (final deviceList in devices.values) {
        if (deviceList is List) {
          for (final device in deviceList) {
            if (device is Map<String, dynamic>) {
              final udid = device['udid'] as String?;
              if (udid == simulatorId) {
                final state = device['state'] as String?;
                return state == 'Booted';
              }
            }
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get detailed information about a simulator
  @override
  Future<SimulatorConfig> getSimulatorInfo(String simulatorId) async {
    try {
      final result = await Process.run('xcrun', ['simctl', 'list', 'devices', '--json']);

      if (result.exitCode != 0) {
        throw Exception('Failed to get simulator info: ${result.stderr}');
      }

      final jsonOutput = jsonDecode(result.stdout as String) as Map<String, dynamic>;
      final devices = jsonOutput['devices'] as Map<String, dynamic>;

      for (final iOSVersion in devices.keys) {
        final deviceList = devices[iOSVersion];
        if (deviceList is List) {
          for (final device in deviceList) {
            if (device is Map<String, dynamic>) {
              final udid = device['udid'] as String?;
              if (udid == simulatorId) {
                final deviceType = device['name'] as String? ?? '';
                final isRunning = device['state'] == 'Booted';

                return SimulatorConfig(
                  simulatorId: simulatorId,
                  deviceType: deviceType,
                  iOSVersion: iOSVersion,
                  isRunning: isRunning,
                  bootTime: null,
                  memoryUsage: 0,
                );
              }
            }
          }
        }
      }

      throw Exception('Simulator with ID "$simulatorId" not found');
    } catch (e) {
      throw Exception('Error getting simulator info: $e');
    }
  }
}
