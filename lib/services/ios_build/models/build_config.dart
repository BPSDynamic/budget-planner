/// Configuration for iOS app build process
class BuildConfig {
  final String buildMode;
  final String targetPlatform;
  final int buildNumber;
  final DateTime buildTimestamp;
  final String sourceHash;
  final String? artifactPath;

  BuildConfig({
    required this.buildMode,
    required this.targetPlatform,
    required this.buildNumber,
    required this.buildTimestamp,
    required this.sourceHash,
    this.artifactPath,
  });

  /// Convert BuildConfig to a Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'buildMode': buildMode,
      'targetPlatform': targetPlatform,
      'buildNumber': buildNumber,
      'buildTimestamp': buildTimestamp.toIso8601String(),
      'sourceHash': sourceHash,
      'artifactPath': artifactPath,
    };
  }

  /// Create BuildConfig from a Map
  factory BuildConfig.fromMap(Map<String, dynamic> map) {
    return BuildConfig(
      buildMode: map['buildMode'] as String,
      targetPlatform: map['targetPlatform'] as String,
      buildNumber: map['buildNumber'] as int,
      buildTimestamp: DateTime.parse(map['buildTimestamp'] as String),
      sourceHash: map['sourceHash'] as String,
      artifactPath: map['artifactPath'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildConfig &&
          runtimeType == other.runtimeType &&
          buildMode == other.buildMode &&
          targetPlatform == other.targetPlatform &&
          buildNumber == other.buildNumber &&
          buildTimestamp == other.buildTimestamp &&
          sourceHash == other.sourceHash &&
          artifactPath == other.artifactPath;

  @override
  int get hashCode =>
      buildMode.hashCode ^
      targetPlatform.hashCode ^
      buildNumber.hashCode ^
      buildTimestamp.hashCode ^
      sourceHash.hashCode ^
      artifactPath.hashCode;
}
