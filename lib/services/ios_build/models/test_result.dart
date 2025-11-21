/// Result of a single test execution
class TestResult {
  final String testName;
  final String testType;
  final String status;
  final int duration;
  final String? errorMessage;
  final String? stackTrace;
  final DateTime timestamp;

  TestResult({
    required this.testName,
    required this.testType,
    required this.status,
    required this.duration,
    this.errorMessage,
    this.stackTrace,
    required this.timestamp,
  });

  /// Convert TestResult to a Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'testName': testName,
      'testType': testType,
      'status': status,
      'duration': duration,
      'errorMessage': errorMessage,
      'stackTrace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create TestResult from a Map
  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      testName: map['testName'] as String,
      testType: map['testType'] as String,
      status: map['status'] as String,
      duration: map['duration'] as int,
      errorMessage: map['errorMessage'] as String?,
      stackTrace: map['stackTrace'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestResult &&
          runtimeType == other.runtimeType &&
          testName == other.testName &&
          testType == other.testType &&
          status == other.status &&
          duration == other.duration &&
          errorMessage == other.errorMessage &&
          stackTrace == other.stackTrace &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      testName.hashCode ^
      testType.hashCode ^
      status.hashCode ^
      duration.hashCode ^
      errorMessage.hashCode ^
      stackTrace.hashCode ^
      timestamp.hashCode;
}
