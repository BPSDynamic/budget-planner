import 'dart:async';
import 'package:crypto/crypto.dart';
import 'interfaces/multi_version_test_coordinator_interface.dart';
import 'emulator_manager.dart';
import 'build_manager.dart';
import 'app_installer.dart';
import 'test_executor.dart';
import 'models/simulator_config.dart';
import 'models/test_report.dart';

/// Implementation of multi-version iOS testing coordination
class MultiVersionTestCoordinator implements MultiVersionTestCoordinatorInterface {
  final String projectRoot;
  final EmulatorManager emulatorManager;
  final BuildManager buildManager;
  final AppInstaller appInstaller;
  final TestExecutor testExecutor;

  final Map<String, SimulatorConfig> _configuredSimulators = {};
  final Map<String, TestReport> _testResults = {};

  MultiVersionTestCoordinator({
    required this.projectRoot,
    EmulatorManager? emulatorManager,
    BuildManager? buildManager,
    AppInstaller? appInstaller,
    TestExecutor? testExecutor,
  })  : emulatorManager = emulatorManager ?? EmulatorManager(),
        buildManager = buildManager ?? BuildManager(projectRoot: projectRoot),
        appInstaller = appInstaller ?? AppInstaller(),
        testExecutor = testExecutor ?? TestExecutor(projectRoot: projectRoot);

  /// Configure multiple simulators for different iOS versions
  @override
  Future<List<SimulatorConfig>> configureMultipleSimulators(List<String> iOSVersions) async {
    try {
      _configuredSimulators.clear();
      final configuredSimulators = <SimulatorConfig>[];

      // Get available simulators
      final availableSimulators = await emulatorManager.detectAvailableSimulators();

      // For each requested iOS version, find or create a simulator
      for (final version in iOSVersions) {
        // Try to find an existing simulator with this version
        final existingSimulator = availableSimulators.firstWhere(
          (sim) => sim.iOSVersion == version,
          orElse: () => SimulatorConfig(
            simulatorId: '',
            deviceType: '',
            iOSVersion: version,
            isRunning: false,
            bootTime: null,
            memoryUsage: 0,
          ),
        );

        if (existingSimulator.simulatorId.isNotEmpty) {
          _configuredSimulators[version] = existingSimulator;
          configuredSimulators.add(existingSimulator);
        } else {
          // Create a new simulator for this version
          try {
            final newSimulator = await emulatorManager.createSimulator('iPhone 14', version);
            _configuredSimulators[version] = newSimulator;
            configuredSimulators.add(newSimulator);
          } catch (e) {
            throw Exception('Failed to configure simulator for iOS $version: $e');
          }
        }
      }

      return configuredSimulators;
    } catch (e) {
      throw Exception('Error configuring multiple simulators: $e');
    }
  }

  /// Build and test the app on all configured simulators
  @override
  Future<Map<String, TestReport>> buildAndTestOnAllVersions() async {
    try {
      if (_configuredSimulators.isEmpty) {
        throw Exception('No simulators configured. Call configureMultipleSimulators first.');
      }

      // Build the app once
      await buildManager.resolveDependencies();
      await buildManager.installCocoaPods();
      await buildManager.buildApp('debug');
      final appArtifact = await buildManager.getBuildArtifact();

      // Test on all simulators sequentially
      _testResults.clear();

      for (final entry in _configuredSimulators.entries) {
        final version = entry.key;
        final simulator = entry.value;

        try {
          // Launch simulator
          await emulatorManager.launchSimulator(simulator.simulatorId);

          // Wait for simulator to be ready
          int attempts = 0;
          while (!await emulatorManager.isSimulatorReady(simulator.simulatorId) && attempts < 30) {
            await Future.delayed(const Duration(seconds: 1));
            attempts++;
          }

          if (attempts >= 30) {
            throw Exception('Simulator did not boot within timeout');
          }

          // Install app
          await appInstaller.installApp(simulator.simulatorId, appArtifact);

          // Verify installation
          final isInstalled = await appInstaller.verifyInstallation(simulator.simulatorId);
          if (!isInstalled) {
            throw Exception('App installation verification failed');
          }

          // Run tests
          final testReport = await testExecutor.runIntegrationTests(simulator.simulatorId);
          _testResults[version] = testReport;

          // Shutdown simulator
          await emulatorManager.shutdownSimulator(simulator.simulatorId);
        } catch (e) {
          throw Exception('Error testing on iOS $version: $e');
        }
      }

      return _testResults;
    } catch (e) {
      throw Exception('Error building and testing on all versions: $e');
    }
  }

  /// Run tests in parallel on all simulators
  @override
  Future<Map<String, TestReport>> runTestsInParallel() async {
    try {
      if (_configuredSimulators.isEmpty) {
        throw Exception('No simulators configured. Call configureMultipleSimulators first.');
      }

      _testResults.clear();

      // Launch all simulators in parallel
      final launchFutures = <Future<void>>[];
      for (final simulator in _configuredSimulators.values) {
        launchFutures.add(emulatorManager.launchSimulator(simulator.simulatorId));
      }
      await Future.wait(launchFutures);

      // Wait for all simulators to be ready
      final readyFutures = <Future<bool>>[];
      for (final simulator in _configuredSimulators.values) {
        readyFutures.add(_waitForSimulatorReady(simulator.simulatorId));
      }
      await Future.wait(readyFutures);

      // Run tests in parallel
      final testFutures = <String, Future<TestReport>>{};
      for (final entry in _configuredSimulators.entries) {
        final version = entry.key;
        final simulator = entry.value;
        testFutures[version] = testExecutor.runIntegrationTests(simulator.simulatorId);
      }

      // Wait for all tests to complete
      for (final entry in testFutures.entries) {
        final version = entry.key;
        final future = entry.value;
        _testResults[version] = await future;
      }

      // Shutdown all simulators
      final shutdownFutures = <Future<void>>[];
      for (final simulator in _configuredSimulators.values) {
        shutdownFutures.add(emulatorManager.shutdownSimulator(simulator.simulatorId));
      }
      await Future.wait(shutdownFutures);

      return _testResults;
    } catch (e) {
      throw Exception('Error running tests in parallel: $e');
    }
  }

  /// Run tests sequentially on all simulators
  @override
  Future<Map<String, TestReport>> runTestsSequentially() async {
    try {
      if (_configuredSimulators.isEmpty) {
        throw Exception('No simulators configured. Call configureMultipleSimulators first.');
      }

      _testResults.clear();

      for (final entry in _configuredSimulators.entries) {
        final version = entry.key;
        final simulator = entry.value;

        try {
          // Launch simulator
          await emulatorManager.launchSimulator(simulator.simulatorId);

          // Wait for simulator to be ready
          await _waitForSimulatorReady(simulator.simulatorId);

          // Run tests
          final testReport = await testExecutor.runIntegrationTests(simulator.simulatorId);
          _testResults[version] = testReport;

          // Shutdown simulator
          await emulatorManager.shutdownSimulator(simulator.simulatorId);
        } catch (e) {
          throw Exception('Error testing on iOS $version: $e');
        }
      }

      return _testResults;
    } catch (e) {
      throw Exception('Error running tests sequentially: $e');
    }
  }

  /// Aggregate results from all simulators into a compatibility report
  @override
  Future<Map<String, dynamic>> aggregateResults(Map<String, TestReport> results) async {
    try {
      if (results.isEmpty) {
        throw Exception('No test results to aggregate');
      }

      int totalTests = 0;
      int totalPassed = 0;
      int totalFailed = 0;
      int totalSkipped = 0;
      int totalDuration = 0;
      final versionResults = <String, Map<String, dynamic>>{};

      for (final entry in results.entries) {
        final version = entry.key;
        final report = entry.value;

        totalTests += report.totalTests;
        totalPassed += report.passedTests;
        totalFailed += report.failedTests;
        totalSkipped += report.skippedTests;
        totalDuration += report.duration;

        versionResults[version] = {
          'totalTests': report.totalTests,
          'passedTests': report.passedTests,
          'failedTests': report.failedTests,
          'skippedTests': report.skippedTests,
          'duration': report.duration,
          'passRate': report.totalTests > 0 ? (report.passedTests / report.totalTests * 100).toStringAsFixed(2) : '0.00',
          'status': report.failedTests == 0 ? 'passed' : 'failed',
        };
      }

      final overallPassRate = totalTests > 0 ? (totalPassed / totalTests * 100).toStringAsFixed(2) : '0.00';
      final overallStatus = totalFailed == 0 ? 'passed' : 'failed';

      return {
        'reportId': _generateReportId(),
        'timestamp': DateTime.now().toIso8601String(),
        'totalVersions': results.length,
        'totalTests': totalTests,
        'totalPassed': totalPassed,
        'totalFailed': totalFailed,
        'totalSkipped': totalSkipped,
        'totalDuration': totalDuration,
        'overallPassRate': overallPassRate,
        'overallStatus': overallStatus,
        'versionResults': versionResults,
      };
    } catch (e) {
      throw Exception('Error aggregating results: $e');
    }
  }

  /// Wait for a simulator to be ready with timeout
  Future<bool> _waitForSimulatorReady(String simulatorId) async {
    int attempts = 0;
    const maxAttempts = 60; // 60 seconds timeout

    while (attempts < maxAttempts) {
      if (await emulatorManager.isSimulatorReady(simulatorId)) {
        return true;
      }
      await Future.delayed(const Duration(seconds: 1));
      attempts++;
    }

    return false;
  }

  /// Generate a unique report ID
  String _generateReportId() {
    return md5.convert('${DateTime.now().toIso8601String()}'.codeUnits).toString().substring(0, 12);
  }
}
