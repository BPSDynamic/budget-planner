import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'build_test_orchestrator.dart';
import 'emulator_manager.dart';
import 'build_manager.dart';
import 'app_installer.dart';
import 'test_executor.dart';
import 'report_generator.dart';

/// CLI command handler for iOS build and test operations
class IOSBuildTestCLI {
  final String projectRoot;
  late final BuildTestOrchestrator _orchestrator;
  final EmulatorManager? emulatorManager;
  final BuildManager? buildManager;
  final AppInstaller? appInstaller;
  final TestExecutor? testExecutor;
  final ReportGenerator? reportGenerator;

  IOSBuildTestCLI({
    required this.projectRoot,
    this.emulatorManager,
    this.buildManager,
    this.appInstaller,
    this.testExecutor,
    this.reportGenerator,
  }) {
    _orchestrator = BuildTestOrchestrator(
      projectRoot: projectRoot,
      emulatorManager: emulatorManager ?? EmulatorManager(),
      buildManager: buildManager ?? BuildManager(projectRoot: projectRoot),
      appInstaller: appInstaller ?? AppInstaller(),
      testExecutor: testExecutor ?? TestExecutor(projectRoot: projectRoot),
      reportGenerator: reportGenerator ?? ReportGenerator(),
    );
  }

  /// Parse and execute CLI commands
  Future<void> run(List<String> args) async {
    if (args.isEmpty) {
      _printUsage();
      return;
    }

    final command = args[0];
    final commandArgs = args.sublist(1);

    try {
      switch (command) {
        case 'flutter_build_ios':
          await _handleBuildCommand(commandArgs);
          break;
        case 'flutter_test_ios':
          await _handleTestCommand(commandArgs);
          break;
        case 'flutter_build_test_ios':
          await _handleBuildTestCommand(commandArgs);
          break;
        case 'flutter_list_simulators':
          await _handleListSimulatorsCommand(commandArgs);
          break;
        case 'flutter_create_simulator':
          await _handleCreateSimulatorCommand(commandArgs);
          break;
        case '--help':
        case '-h':
          _printUsage();
          break;
        default:
          stderr.writeln('Unknown command: $command');
          _printUsage();
          throw Exception('Unknown command: $command');
      }
    } catch (e) {
      stderr.writeln('Error: $e');
      rethrow;
    }
  }

  /// Handle flutter_build_ios command
  Future<void> _handleBuildCommand(List<String> args) async {
    final parser = ArgParser()
      ..addOption('mode', defaultsTo: 'debug', help: 'Build mode (debug, release, profile)')
      ..addFlag('help', negatable: false, help: 'Show help');

    final results = parser.parse(args);

    if (results['help'] as bool) {
      stdout.writeln('Build iOS app');
      stdout.writeln('Usage: flutter_build_ios [options]');
      stdout.writeln(parser.usage);
      return;
    }

    final buildMode = results['mode'] as String;
    stdout.writeln('Building iOS app in $buildMode mode...');

    try {
      final buildMgr = buildManager ?? BuildManager(projectRoot: projectRoot);
      await buildMgr.resolveDependencies();
      stdout.writeln('✓ Dependencies resolved');

      await buildMgr.installCocoaPods();
      stdout.writeln('✓ CocoaPods installed');

      await buildMgr.buildApp(buildMode);
      stdout.writeln('✓ App built successfully');

      final artifactPath = await buildMgr.getBuildArtifact();
      stdout.writeln('✓ Build artifact: $artifactPath');

      final buildReport = await buildMgr.reportBuildStatus();
      stdout.writeln('Build completed in ${buildReport.duration}ms');
    } catch (e) {
      stderr.writeln('Build failed: $e');
      rethrow;
    }
  }

  /// Handle flutter_test_ios command
  Future<void> _handleTestCommand(List<String> args) async {
    final parser = ArgParser()
      ..addOption('simulator', help: 'Simulator ID to run tests on')
      ..addOption('type', defaultsTo: 'unit', help: 'Test type (unit, widget, integration)')
      ..addFlag('help', negatable: false, help: 'Show help');

    final results = parser.parse(args);

    if (results['help'] as bool) {
      stdout.writeln('Run tests on iOS emulator');
      stdout.writeln('Usage: flutter_test_ios [options]');
      stdout.writeln(parser.usage);
      return;
    }

    final testType = results['type'] as String;
    String? simulatorId = results['simulator'] as String?;

    try {
      // If no simulator specified, detect and use first available
      if (simulatorId == null) {
        final emulMgr = emulatorManager ?? EmulatorManager();
        final simulators = await emulMgr.detectAvailableSimulators();

        if (simulators.isEmpty) {
          throw Exception('No iOS simulators available');
        }

        simulatorId = simulators.first.simulatorId;
        stdout.writeln('Using simulator: ${simulators.first.deviceType} (${simulators.first.iOSVersion})');
      }

      final testExec = testExecutor ?? TestExecutor(projectRoot: projectRoot);

      stdout.writeln('Running $testType tests on simulator $simulatorId...');

      late final dynamic testReport;
      switch (testType) {
        case 'unit':
          testReport = await testExec.runUnitTests(simulatorId);
          break;
        case 'widget':
          testReport = await testExec.runWidgetTests(simulatorId);
          break;
        case 'integration':
          testReport = await testExec.runIntegrationTests(simulatorId);
          break;
        default:
          throw Exception('Unknown test type: $testType');
      }

      stdout.writeln('✓ Tests completed');
      stdout.writeln('Passed: ${testReport.passedTests}/${testReport.totalTests}');
      if (testReport.failedTests > 0) {
        stdout.writeln('Failed: ${testReport.failedTests}');
        throw Exception('Tests failed');
      }
    } catch (e) {
      stderr.writeln('Test execution failed: $e');
      rethrow;
    }
  }

  /// Handle flutter_build_test_ios command (full workflow)
  Future<void> _handleBuildTestCommand(List<String> args) async {
    final parser = ArgParser()
      ..addOption('mode', defaultsTo: 'debug', help: 'Build mode (debug, release, profile)')
      ..addFlag('help', negatable: false, help: 'Show help');

    final results = parser.parse(args);

    if (results['help'] as bool) {
      stdout.writeln('Build and test iOS app');
      stdout.writeln('Usage: flutter_build_test_ios [options]');
      stdout.writeln(parser.usage);
      return;
    }

    stdout.writeln('Starting full build and test workflow...');

    try {
      final result = await _orchestrator.runFullBuildAndTest();

      stdout.writeln('\n=== Workflow Complete ===');
      stdout.writeln('Status: ${result['status']}');
      stdout.writeln('Duration: ${result['duration']}ms');
      stdout.writeln('Workflow ID: ${result['workflowId']}');

      if (result['buildReport'] != null) {
        stdout.writeln('\nBuild Report:');
        stdout.writeln('  Status: ${result['buildReport']['status']}');
        stdout.writeln('  Duration: ${result['buildReport']['duration']}ms');
      }

      if (result['testReport'] != null) {
        stdout.writeln('\nTest Report:');
        stdout.writeln('  Total: ${result['testReport']['totalTests']}');
        stdout.writeln('  Passed: ${result['testReport']['passedTests']}');
        stdout.writeln('  Failed: ${result['testReport']['failedTests']}');
      }

      if ((result['errors'] as List).isNotEmpty) {
        stdout.writeln('\nErrors:');
        for (final error in result['errors'] as List) {
          stdout.writeln('  - $error');
        }
      }

      stdout.writeln('\nRecommendations:');
      for (final rec in result['recommendations'] as List) {
        stdout.writeln('  - $rec');
      }

      if (result['status'] != 'success') {
        throw Exception('Workflow failed');
      }
    } catch (e) {
      stderr.writeln('Workflow failed: $e');
      rethrow;
    }
  }

  /// Handle flutter_list_simulators command
  Future<void> _handleListSimulatorsCommand(List<String> args) async {
    final parser = ArgParser()
      ..addFlag('json', negatable: false, help: 'Output as JSON')
      ..addFlag('help', negatable: false, help: 'Show help');

    final results = parser.parse(args);

    if (results['help'] as bool) {
      stdout.writeln('List available iOS simulators');
      stdout.writeln('Usage: flutter_list_simulators [options]');
      stdout.writeln(parser.usage);
      return;
    }

    try {
      final emulMgr = emulatorManager ?? EmulatorManager();
      final simulators = await emulMgr.detectAvailableSimulators();

      if (results['json'] as bool) {
        final jsonOutput = simulators.map((s) => s.toMap()).toList();
        stdout.writeln(jsonEncode(jsonOutput));
      } else {
        if (simulators.isEmpty) {
          stdout.writeln('No iOS simulators found');
          return;
        }

        stdout.writeln('Available iOS Simulators:');
        stdout.writeln('');

        for (final simulator in simulators) {
          final status = simulator.isRunning ? '(running)' : '(stopped)';
          stdout.writeln('  ${simulator.deviceType}');
          stdout.writeln('    ID: ${simulator.simulatorId}');
          stdout.writeln('    iOS: ${simulator.iOSVersion}');
          stdout.writeln('    Status: $status');
          stdout.writeln('');
        }
      }
    } catch (e) {
      stderr.writeln('Failed to list simulators: $e');
      rethrow;
    }
  }

  /// Handle flutter_create_simulator command
  Future<void> _handleCreateSimulatorCommand(List<String> args) async {
    final parser = ArgParser()
      ..addOption('device', help: 'Device type (e.g., iPhone 14, iPhone 15)')
      ..addOption('ios', help: 'iOS version (e.g., 16.0, 17.0)')
      ..addFlag('help', negatable: false, help: 'Show help');

    final results = parser.parse(args);

    if (results['help'] as bool) {
      stdout.writeln('Create a new iOS simulator');
      stdout.writeln('Usage: flutter_create_simulator [options]');
      stdout.writeln(parser.usage);
      return;
    }

    final deviceType = results['device'] as String?;
    final iOSVersion = results['ios'] as String?;

    if (deviceType == null || iOSVersion == null) {
      throw Exception('Error: --device and --ios options are required');
    }

    try {
      final emulMgr = emulatorManager ?? EmulatorManager();
      stdout.writeln('Creating simulator: $deviceType with iOS $iOSVersion...');

      final simulator = await emulMgr.createSimulator(deviceType, iOSVersion);
      stdout.writeln('✓ Simulator created successfully');
      stdout.writeln('  ID: ${simulator.simulatorId}');
      stdout.writeln('  Device: ${simulator.deviceType}');
      stdout.writeln('  iOS: ${simulator.iOSVersion}');
    } catch (e) {
      stderr.writeln('Failed to create simulator: $e');
      rethrow;
    }
  }

  /// Print usage information
  void _printUsage() {
    stdout.writeln('iOS Build & Test CLI');
    stdout.writeln('');
    stdout.writeln('Usage: flutter_ios_cli <command> [options]');
    stdout.writeln('');
    stdout.writeln('Commands:');
    stdout.writeln('  flutter_build_ios              Build iOS app');
    stdout.writeln('  flutter_test_ios               Run tests on iOS emulator');
    stdout.writeln('  flutter_build_test_ios         Build and test iOS app (full workflow)');
    stdout.writeln('  flutter_list_simulators        List available iOS simulators');
    stdout.writeln('  flutter_create_simulator       Create a new iOS simulator');
    stdout.writeln('');
    stdout.writeln('Options:');
    stdout.writeln('  -h, --help                     Show help');
    stdout.writeln('');
    stdout.writeln('Examples:');
    stdout.writeln('  flutter_build_ios --mode debug');
    stdout.writeln('  flutter_test_ios --type unit');
    stdout.writeln('  flutter_build_test_ios');
    stdout.writeln('  flutter_list_simulators --json');
    stdout.writeln('  flutter_create_simulator --device "iPhone 14" --ios 17.0');
  }
}
