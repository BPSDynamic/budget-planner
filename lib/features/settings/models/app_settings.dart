class AppSettings {
  final String userId;
  final String currency;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool darkModeEnabled;
  final String language;
  final DateTime lastUpdated;

  AppSettings({
    required this.userId,
    this.currency = 'USD',
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.darkModeEnabled = false,
    this.language = 'English',
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'currency': currency,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'language': language,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      userId: map['userId'],
      currency: map['currency'] ?? 'USD',
      pushNotificationsEnabled: map['pushNotificationsEnabled'] ?? true,
      emailNotificationsEnabled: map['emailNotificationsEnabled'] ?? true,
      darkModeEnabled: map['darkModeEnabled'] ?? false,
      language: map['language'] ?? 'English',
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
    );
  }

  AppSettings copyWith({
    String? currency,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? darkModeEnabled,
    String? language,
  }) {
    return AppSettings(
      userId: userId,
      currency: currency ?? this.currency,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      language: language ?? this.language,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          currency == other.currency &&
          pushNotificationsEnabled == other.pushNotificationsEnabled &&
          emailNotificationsEnabled == other.emailNotificationsEnabled &&
          darkModeEnabled == other.darkModeEnabled &&
          language == other.language;

  @override
  int get hashCode =>
      userId.hashCode ^
      currency.hashCode ^
      pushNotificationsEnabled.hashCode ^
      emailNotificationsEnabled.hashCode ^
      darkModeEnabled.hashCode ^
      language.hashCode;
}
