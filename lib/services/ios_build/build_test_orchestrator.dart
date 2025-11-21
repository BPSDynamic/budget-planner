import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'interfaces/build_test_orchestrator_interface.dart';
import 'emulator_manager.dart';
import 'build_manager.dart';
import 'app_installer.dart';
import 'test_executor.dart';
import 'report_generator.dart';
import 'models/build_report.dart';
import 'models/test_report.dart';

/// Orchestrates the complete iOS build and test workflow
class BuildTestOrchestrator implements BuildTestOrchestratorInterface {
  final String projectRoot;
  final EmulatorManager emulatorManager;
  final BuildManager buildManager;
  final AppInstaller appInstaller;
  final TestExecutor testExecutor;
  final ReportGenerator reportGenerator;

  BuildReport? _lastBuildReport;
  TestReport? _lastTestReport;
  DateTime? _workflowStartTime;
  List<String> _workflowErrors = [];

  BuildTestOrchestrator({
    required this.projectRoot,
    EmulatorManager? emulatorManager,
    BuildManager? buildManager,
    AppInstaller? appInstaller,
    TestExecutor? testExecutor,
    ReportGenerator? reportGenerator,
  })  : emulatorManager = emulatorManager ?? EmulatorManager(),
        buildManager = buildManager ?? BuildManager(projectRoot: projectRoot),
        appInstaller = appInstaller ?? AppInstaller(),
        testExecutor = testExecutor ?? TestExecutor(projectRoot: projectRoot),
        reportGenerator = reportGenerator ?? ReportGenerator();

  /// Run the complete build and test workflow
  @override
  Future<Map<String, dynamic>> runFullBuildAndTest() async {
    _workflowStartTime = DateTime.now();
    _workflowErrors = [];

    try {
      // Validate prerequisites
      final prerequisites = await validatePrerequisites();
      if (!prerequisites.values.every((v) => v)) {
        throw Exception('Prerequisites validation failed');
      }

      // Execute the workflow
      await executeWorkflow();

      // Report final status
      return await reportFinalStatus();
    } catch (e) {
      await handleErrors(e as Exception);
      return await reportFinalStatus();
    }
  }

  /// Validate that all prerequisites are installed and available
  @override
  Future<Map<String, bool>> validatePrerequisites() async {
    final prerequisites = <String, bool>{};

    try {
      // Check Xcode
      final xcodeResult = await Process.run('xcode-select', ['-p']);
      prerequisites['xcode'] = xcodeResult.exitCode == 0;

      // Check iOS SDK
      final sdkResult = await Process.run('xcrun', ['--sdk', 'iphoneos', '--show-sdk-path']);
      prerequisites['ios_sdk'] = sdkResult.exitCode == 0;

      // Check Flutter
      final flutterResult = await Process.run('flutter', ['--version']);
      prerequisites['flutter'] = flutterResult.exitCode == 0;

      // Check CocoaPods
      final podsResult = await Process.run('pod', ['--version']);
      prerequisites['cocoapods'] = podsResult.exitCode == 0;

      // Check xcrun simctl
      final simctlResult = await Process.run('xcrun', ['simctl', 'list', 'devices']);
      prerequisites['simctl'] = simctlResult.exitCode == 0;

      return prerequisites;
    } catch (e) {
      _workflowErrors.add('Error validating prerequisites: $e');
      return {
        'xcode': false,
        'ios_sdk': false,
        'flutter': false,
        'cocoapods': false,
        'simctl': false,
      };
    }
  }

  /// Execute the workflow steps in sequence
  @override
  Future<void> executeWorkflow() async {
    try {
      // Step 1: Resolve dependencies
      await _executeStep('Resolving dependencies', () => buildManager.resolveDependencies());

      // Step 2: Install CocoaPods
      await _executeStep('Installing CocoaPods', () => buildManager.installCocoaPods());

      // Step 3: Build the app
      await _executeStep('Building iOS app', () => buildManager.buildApp('debug'));

      // Step 4: Get build artifact
      final artifactPath = await _executeStep(
        'Getting build artifact',
        () => buildManager.getBuildArtifact(),
      );

      // Step 5: Report build status
      _lastBuildReport = await _executeStep(
        'Reporting build status',
        () => buildManager.reportBuildStatus(),
      );

      // Step 6: Detect available simulators
      final simulators = await _executeStep(
        'Detecting simulators',
        () => emulatorManager.detectAvailableSimulators(),
      );

      if (simulators.isEmpty) {
        throw Exception('No iOS simulators available');
      }

      // Step 7: Launch first available simulator
      final simulator = simulators.first;
      await _executeStep(
        'Launching simulator ${simulator.simulatorId}',
        () => emulatorManager.launchSimulator(simulator.simulatorId),
      );

      // Step 8: Wait for simulator to be ready
      await _executeStep(
        'Waiting for simulator to be ready',
        () => _waitForSimulatorReady(simulator.simulatorId),
      );

      // Step 9: Install app on simulator
      await _executeStep(
        'Installing app on simulator',
        () => appInstaller.installApp(simulator.simulatorId, artifactPath as String),
      );

      // Step 10: Verify installation
      await _executeStep(
        'Verifying app installation',
        () => appInstaller.verifyInstallation(simulator.simulatorId),
      );

      // Step 11: Run unit tests
      _lastTestReport = await _executeStep(
        'Running unit tests',
        () => testExecutor.runUnitTests(simulator.simulatorId),
      );

      // Step 12: Run widget tests
      await _executeStep(
        'Running widget tests',
        () => testExecutor.runWidgetTests(simulator.simulatorId),
      );

      // Step 13: Shutdown simulator
      await _executeStep(
        'Shutting down simulator',
        () => emulatorManager.shutdownSimulator(simulator.simulatorId),
      );
    } catch (e) {
      _workflowErrors.add('Workflow execution error: $e');
      rethrow;
    }
  }

  /// Handle errors with recovery logic
  @override
  Future<void> handleErrors(Exception error) async {
    _workflowErrors.add('Workflow error: ${error.toString()}');

    try {
      // Attempt to shutdown any running simulators
      final simulators = await emulatorManager.detectAvailableSimulators();
      for (final simulator in simulators) {
        if (simulator.isRunning) {
          try {
            await emulatorManager.shutdownSimulator(simulator.simulatorId);
          } catch (e) {
            _workflowErrors.add('Error shutting down simulator: $e');
          }
        }
      }
    } catch (e) {
      _workflowErrors.add('Error during error recovery: $e');
    }
  }

  /// Report the final status of the workflow
  @override
  Future<Map<String, dynamic>> reportFinalStatus() async {
    final workflowDuration = _workflowStartTime != null
        ? DateTime.now().difference(_workflowStartTime!).inMilliseconds
        : 0;

    final hasErrors = _workflowErrors.isNotEmpty;
    final status = hasErrors ? 'failed' : 'success';

    return {
      'status': status,
      'workflowId': _generateWorkflowId(),
      'duration': workflowDuration,
      'timestamp': DateTime.now().toIso8601String(),
      'buildReport': _lastBuildReport?.toMap(),
      'testReport': _lastTestReport?.toMap(),
      'errors': _workflowErrors,
      'errorCount': _workflowErrors.length,
      'recommendations': _generateRecommendations(),
    };
  }

  /// Execute a workflow step with error handling
  Future<T> _executeStep<T>(String stepName, Future<T> Function() step) async {
    try {
      return await step();
    } catch (e) {
      _workflowErrors.add('$stepName failed: $e');
      rethrow;
    }
  }

  /// Wait for simulator to be fully booted and ready
  Future<void> _waitForSimulatorReady(String simulatorId) async {
    const maxAttempts = 30;
    const delayBetweenAttempts = Duration(seconds: 2);

    for (int i = 0; i < maxAttempts; i++) {
      final isReady = await emulatorManager.isSimulatorReady(simulatorId);
      if (isReady) {
        return;
      }
      await Future.delayed(delayBetweenAttempts);
    }

    throw Exception('Simulator did not become ready within timeout period');
  }

  /// Generate a unique workflow ID
  String _generateWorkflowId() {
    return md5.convert('${DateTime.now().toIso8601String()}'.codeUnits).toString().substring(0, 12);
  }

  /// Generate recommendations based on workflow results
  List<String> _generateRecommendations() {
    final recommendations = <String>[];

    if (_workflowErrors.isNotEmpty) {
      recommendations.add('Review error logs above for detailed failure information');
    }

    if (_lastBuildReport != null && _lastBuildReport!.duration > 60000) {
      recommendations.add('Build took longer than 60 seconds. Consider using build cache.');
    }

    if (_lastTestReport != null && _lastTestReport!.failedTests > 0) {
      recommendations.add('${_lastTestReport!.failedTests} tests failed. Review test output for details.');
    }

    if (_workflowErrors.isEmpty && _lastTestReport != null && _lastTestReport!.failedTests == 0) {
      recommendations.add('All tests passed successfully!');
    }

    return recommendations;
  }
}
