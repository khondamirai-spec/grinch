class AppConstants {
  AppConstants._();

  static const String appName = 'StudyFlow';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tasksBox = 'tasks';
  static const String resourcesBox = 'resources';
  static const String resourceFilesBox = 'resource_files';
  static const String profileBox = 'profile';
  static const String settingsBox = 'settings';
  
  // Settings Keys
  static const String settingTheme = 'theme_mode';
  static const String settingReminders = 'reminders_enabled';
  static const String settingReminderTime = 'reminder_time';
  
  // File Size Limit (50MB)
  static const int maxFileSize = 50 * 1024 * 1024;
  
  // Date Format Patterns
  static const String dateFormatFull = 'EEEE, MMMM d, y';
  static const String dateFormatShort = 'EEE';
  static const String dateFormatDay = 'd';
}
