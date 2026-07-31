enum WeekStartDay {
  monday,
  sunday;

  static const defaultValue = WeekStartDay.monday;

  static WeekStartDay fromStoredName(String? name) {
    for (final value in WeekStartDay.values) {
      if (value.name == name) {
        return value;
      }
    }
    return defaultValue;
  }
}
