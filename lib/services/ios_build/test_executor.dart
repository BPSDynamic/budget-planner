import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'interfaces/test_executor_interface.dart';
import 'models/test_report.dart';
import 'models/test_result.dart';

/// Implementation of iOS test execution on emulator
class TestExecutor implements TestExecutorInterface {
  final String projectRoot;
  TestReport? _lastTestReport;
  DateTime? _lastTestTime;

  TestExecutor({required this.projectRoot});

  /// Run unit tests on the iOS emulator
  @override
  Future<TestReport> runUnitTests(String simulatorId) async {
    try {
      _lastTestTime = DateTime.now();

      final result = await Process.run(
        'flutter',
        ['test', '--plain-name', 'unit'],
        workingDirectory: projectRoot,
      );

      if (result.exitCode != 0) {
        throw Exception('Failed to run unit tests: ${result.stderr}');
      }

      final testResults = _parseTestOutput(result.stdout as String, 'unit');
      final report = _generateTestReport(simulatorId, testResults);

      _lastTestReport = report;
      return report;
    } catch (e) {
      throw Exception('Error running unit tests: $e');
    }
  }

  /// Run widget tests on the iOS emulator
  @override
  Future<TestReport> runWidgetTests(String simulatorId) async {
    try {
      _lastTestTime = DateTime.now();

      final result = await Process.run(
        'flutter',
        ['test', '--plain-name', 'widget'],
        workingDirectory: projectRoot,
      );

      if (result.exitCode != 0) {
        throw Exception('Failed to run widget tests: ${result.stderr}');
      }

      final testResults = _parseTestOutput(result.stdout as String, 'widget');
      final report = _generateTestReport(simulatorId, testResults);

      _lastTestReport = report;
      return report;
    } catch (e) {
      throw Exception('Error running widget tests: $e');
    }
  }

  /// Run integration tests on the iOS emulator
  @override
  Future<TestReport> runIntegrationTests(String simulatorId) async {
    try {
      _lastTestTime = DateTime.now();

      final result = await Process.run(
        'flutter',
        ['drive', '--target=test_driver/app.dart'],
        workingDirectory: projectRoot,
      );

      if (result.exitCode != 0) {
        throw Exception('Failed to run integration tests: ${result.stderr}');
      }

      final testResults = _parseTestOutput(result.stdout as String, 'integration');
      final report = _generateTestReport(simulatorId, testResults);

      _lastTestReport = report;
      return report;
    } catch (e) {
      throw Exception('Error running integration tests: $e');
    }
  }

  /// Capture test results from test output
  @override
  Future<TestReport> captureTestResults() async {
    if (_lastTestReport == null) {
      throw Exception('No test results available. Run tests first.');
    }
    return _lastTestReport!;
  }

  /// Capture screenshots on test failure
  @override
  Future<List<String>> captureScreenshots() async {
    try {
      final screenshotsDir = Directory('$projectRoot/screenshots');
      if (!await screenshotsDir.exists()) {
        await screenshotsDir.create(recursive: true);
      }

      final result = await Process.run('xcrun', [
        'simctl',
        'io',
        'booted',
        'screenshot',
        '${screenshotsDir.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png',
      ]);

      if (result.exitCode != 0) {
        throw Exception('Failed to capture screenshot: ${result.stderr}');
      }

      final files = screenshotsDir.listSync().whereType<File>().map((f) => f.path).toList();
      return files;
    } catch (e) {
      throw Exception('Error capturing screenshots: $e');
    }
  }

  /// Capture emulator system and app logs
  @override
  Future<String> captureEmulatorLogs() async {
    try {
      final logsDir = Directory('$projectRoot/logs');
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final logFile = File('${logsDir.path}/emulator_${DateTime.now().millisecondsSinceEpoch}.log');

      final result = await Process.run('xcrun', [
        'simctl',
        'spawn',
        'booted',
        'log',
        'stream',
        '--level',
        'debug',
      ]);

      if (result.exitCode != 0) {
        throw Exception('Failed to capture logs: ${result.stderr}');
      }

      await logFile.writeAsString(result.stdout as String);
      return logFile.path;
    } catch (e) {
      throw Exception('Error capturing emulator logs: $e');
    }
  }

  /// Parse test output and extract test results
  List<TestResult> _parseTestOutput(String output, String testType) {
    final testResults = <TestResult>[];
    final lines = output.split('\n');

    for (final line in lines) {
      if (line.contains('✓') || line.contains('✗')) {
        final testName = _extractTestName(line);
        final status = line.contains('✓') ? 'passed' : 'failed';
        final duration = _extractDuration(line);
        final errorMessage = status == 'failed' ? _extractErrorMessage(line) : null;

        testResults.add(TestResult(
          testName: testName,
          testType: testType,
          status: status,
          duration: duration,
          errorMessage: errorMessage,
          stackTrace: null,
          timestamp: DateTime.now(),
        ));
      }
    }

    return testResults;
  }

  /// Extract test name from output line
  String _extractTestName(String line) {
    final match = RegExp(r'[✓✗]\s+(.+?)(?:\s+\(|$)').firstMatch(line);
    return match?.group(1) ?? 'unknown';
  }

  /// Extract test duration from output line
  int _extractDuration(String line) {
    final match = RegExp(r'\((\d+)ms\)').firstMatch(line);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  /// Extract error message from output line
  String? _extractErrorMessage(String line) {
    if (line.contains('Error:')) {
      final match = RegExp(r'Error:\s+(.+)').firstMatch(line);
      return match?.group(1);
    }
    return null;
  }

  /// Generate a test report from test results
  TestReport _generateTestReport(String simulatorId, List<TestResult> testResults) {
    final totalTests = testResults.length;
    final passedTests = testResults.where((r) => r.status == 'passed').length;
    final failedTests = testResults.where((r) => r.status == 'failed').length;
    final skippedTests = testResults.where((r) => r.status == 'skipped').length;
    final duration = _lastTestTime != null ? DateTime.now().difference(_lastTestTime!).inMilliseconds : 0;

    return TestReport(
      reportId: _generateReportId(),
      simulatorId: simulatorId,
      totalTests: totalTests,
      passedTests: passedTests,
      failedTests: failedTests,
      skippedTests: skippedTests,
      duration: duration,
      testResults: testResults,
      timestamp: DateTime.now(),
    );
  }

  /// Generate a unique report ID
  String _generateReportId() {
    return md5.convert('${DateTime.now().toIso8601String()}'.codeUnits).toString().substring(0, 12);
  }
}
