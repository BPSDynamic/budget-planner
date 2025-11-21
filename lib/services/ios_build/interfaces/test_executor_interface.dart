import '../models/test_report.dart';

/// Abstract interface for iOS test execution
abstract class TestExecutorInterface {
  /// Run unit tests on the iOS emulator
  Future<TestReport> runUnitTests(String simulatorId);

  /// Run widget tests on the iOS emulator
  Future<TestReport> runWidgetTests(String simulatorId);

  /// Run integration tests on the iOS emulator
  Future<TestReport> runIntegrationTests(String simulatorId);

  /// Capture test results from test output
  Future<TestReport> captureTestResults();

  /// Capture screenshots on test failure
  Future<List<String>> captureScreenshots();

  /// Capture emulator system and app logs
  Future<String> captureEmulatorLogs();
}
