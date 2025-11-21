import 'test_result.dart';

/// Report of test execution on iOS emulator
class TestReport {
  final String reportId;
  final String simulatorId;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final int skippedTests;
  final int duration;
  final List<TestResult> testResults;
  final DateTime timestamp;

  TestReport({
    required this.reportId,
    required this.simulatorId,
    required this.totalTests,
    required this.passedTests,
    required this.failedTests,
    required this.skippedTests,
    required this.duration,
    required this.testResults,
    required this.timestamp,
  });

  /// Convert TestReport to a Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'simulatorId': simulatorId,
      'totalTests': totalTests,
      'passedTests': passedTests,
      'failedTests': failedTests,
      'skippedTests': skippedTests,
      'duration': duration,
      'testResults': testResults.map((result) => result.toMap()).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create TestReport from a Map
  factory TestReport.fromMap(Map<String, dynamic> map) {
    return TestReport(
      reportId: map['reportId'] as String,
      simulatorId: map['simulatorId'] as String,
      totalTests: map['totalTests'] as int,
      passedTests: map['passedTests'] as int,
      failedTests: map['failedTests'] as int,
      skippedTests: map['skippedTests'] as int,
      duration: map['duration'] as int,
      testResults: (map['testResults'] as List<dynamic>)
          .map((result) => TestResult.fromMap(result as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TestReport) return false;
    if (runtimeType != other.runtimeType) return false;
    
    return reportId == other.reportId &&
        simulatorId == other.simulatorId &&
        totalTests == other.totalTests &&
        passedTests == other.passedTests &&
        failedTests == other.failedTests &&
        skippedTests == other.skippedTests &&
        duration == other.duration &&
        timestamp == other.timestamp &&
        _listEquals(testResults, other.testResults);
  }

  bool _listEquals(List<TestResult> a, List<TestResult> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      reportId.hashCode ^
      simulatorId.hashCode ^
      totalTests.hashCode ^
      passedTests.hashCode ^
      failedTests.hashCode ^
      skippedTests.hashCode ^
      duration.hashCode ^
      testResults.hashCode ^
      timestamp.hashCode;
}
