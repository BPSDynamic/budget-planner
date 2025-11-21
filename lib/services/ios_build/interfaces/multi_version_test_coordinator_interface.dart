import '../models/simulator_config.dart';
import '../models/test_report.dart';

/// Interface for multi-version iOS testing coordination
abstract class MultiVersionTestCoordinatorInterface {
  /// Configure multiple simulators for different iOS versions
  Future<List<SimulatorConfig>> configureMultipleSimulators(List<String> iOSVersions);

  /// Build and test the app on all configured simulators
  Future<Map<String, TestReport>> buildAndTestOnAllVersions();

  /// Run tests in parallel on all simulators
  Future<Map<String, TestReport>> runTestsInParallel();

  /// Run tests sequentially on all simulators
  Future<Map<String, TestReport>> runTestsSequentially();

  /// Aggregate results from all simulators into a compatibility report
  Future<Map<String, dynamic>> aggregateResults(Map<String, TestReport> results);
}
