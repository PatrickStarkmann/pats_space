class NotificationSettings {
  const NotificationSettings({
    this.enabled = false,
    this.focusEndEnabled = true,
    this.breakEndEnabled = true,
  });

  final bool enabled;
  final bool focusEndEnabled;
  final bool breakEndEnabled;

  NotificationSettings copyWith({
    bool? enabled,
    bool? focusEndEnabled,
    bool? breakEndEnabled,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      focusEndEnabled: focusEndEnabled ?? this.focusEndEnabled,
      breakEndEnabled: breakEndEnabled ?? this.breakEndEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationSettings &&
        other.enabled == enabled &&
        other.focusEndEnabled == focusEndEnabled &&
        other.breakEndEnabled == breakEndEnabled;
  }

  @override
  int get hashCode => Object.hash(enabled, focusEndEnabled, breakEndEnabled);
}
