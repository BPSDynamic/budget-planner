/// Configuration for an iOS simulator instance
class SimulatorConfig {
  final String simulatorId;
  final String deviceType;
  final String iOSVersion;
  final bool isRunning;
  final DateTime? bootTime;
  final int memoryUsage;

  SimulatorConfig({
    required this.simulatorId,
    required this.deviceType,
    required this.iOSVersion,
    required this.isRunning,
    this.bootTime,
    required this.memoryUsage,
  });

  /// Convert SimulatorConfig to a Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'simulatorId': simulatorId,
      'deviceType': deviceType,
      'iOSVersion': iOSVersion,
      'isRunning': isRunning,
      'bootTime': bootTime?.toIso8601String(),
      'memoryUsage': memoryUsage,
    };
  }

  /// Create SimulatorConfig from a Map
  factory SimulatorConfig.fromMap(Map<String, dynamic> map) {
    return SimulatorConfig(
      simulatorId: map['simulatorId'] as String,
      deviceType: map['deviceType'] as String,
      iOSVersion: map['iOSVersion'] as String,
      isRunning: map['isRunning'] as bool,
      bootTime: map['bootTime'] != null ? DateTime.parse(map['bootTime'] as String) : null,
      memoryUsage: map['memoryUsage'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulatorConfig &&
          runtimeType == other.runtimeType &&
          simulatorId == other.simulatorId &&
          deviceType == other.deviceType &&
          iOSVersion == other.iOSVersion &&
          isRunning == other.isRunning &&
          bootTime == other.bootTime &&
          memoryUsage == other.memoryUsage;

  @override
  int get hashCode =>
      simulatorId.hashCode ^
      deviceType.hashCode ^
      iOSVersion.hashCode ^
      isRunning.hashCode ^
      bootTime.hashCode ^
      memoryUsage.hashCode;
}
