import '../models/simulator_config.dart';

/// Abstract interface for iOS emulator management
abstract class EmulatorManagerInterface {
  /// Detect all available iOS simulators on the system
  Future<List<SimulatorConfig>> detectAvailableSimulators();

  /// Create a new iOS simulator with specified device type and iOS version
  Future<SimulatorConfig> createSimulator(String deviceType, String iOSVersion);

  /// Launch a specific iOS simulator
  Future<void> launchSimulator(String simulatorId);

  /// Shutdown a running iOS simulator
  Future<void> shutdownSimulator(String simulatorId);

  /// Check if a simulator is fully booted and responsive
  Future<bool> isSimulatorReady(String simulatorId);

  /// Get detailed information about a simulator
  Future<SimulatorConfig> getSimulatorInfo(String simulatorId);
}
