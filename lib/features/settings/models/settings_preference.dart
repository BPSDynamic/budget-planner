class SettingsPreference {
  final String key;
  final dynamic value;
  final String type; // 'bool', 'string', 'int', 'double'
  final DateTime lastModified;

  SettingsPreference({
    required this.key,
    required this.value,
    required this.type,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      'type': type,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory SettingsPreference.fromMap(Map<String, dynamic> map) {
    return SettingsPreference(
      key: map['key'],
      value: map['value'],
      type: map['type'],
      lastModified: map['lastModified'] != null
          ? DateTime.parse(map['lastModified'])
          : DateTime.now(),
    );
  }

  SettingsPreference copyWith({
    String? key,
    dynamic value,
    String? type,
    DateTime? lastModified,
  }) {
    return SettingsPreference(
      key: key ?? this.key,
      value: value ?? this.value,
      type: type ?? this.type,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsPreference &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          value == other.value &&
          type == other.type;

  @override
  int get hashCode => key.hashCode ^ value.hashCode ^ type.hashCode;
}
