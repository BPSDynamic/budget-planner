/// Report of iOS app build process
class BuildReport {
  final String buildId;
  final String status;
  final int duration;
  final String? artifactPath;
  final int dependencyCount;
  final int cacheHitCount;
  final DateTime timestamp;

  BuildReport({
    required this.buildId,
    required this.status,
    required this.duration,
    this.artifactPath,
    required this.dependencyCount,
    required this.cacheHitCount,
    required this.timestamp,
  });

  /// Convert BuildReport to a Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'buildId': buildId,
      'status': status,
      'duration': duration,
      'artifactPath': artifactPath,
      'dependencyCount': dependencyCount,
      'cacheHitCount': cacheHitCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create BuildReport from a Map
  factory BuildReport.fromMap(Map<String, dynamic> map) {
    return BuildReport(
      buildId: map['buildId'] as String,
      status: map['status'] as String,
      duration: map['duration'] as int,
      artifactPath: map['artifactPath'] as String?,
      dependencyCount: map['dependencyCount'] as int,
      cacheHitCount: map['cacheHitCount'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildReport &&
          runtimeType == other.runtimeType &&
          buildId == other.buildId &&
          status == other.status &&
          duration == other.duration &&
          artifactPath == other.artifactPath &&
          dependencyCount == other.dependencyCount &&
          cacheHitCount == other.cacheHitCount &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      buildId.hashCode ^
      status.hashCode ^
      duration.hashCode ^
      artifactPath.hashCode ^
      dependencyCount.hashCode ^
      cacheHitCount.hashCode ^
      timestamp.hashCode;
}
