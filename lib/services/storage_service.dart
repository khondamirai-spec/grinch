import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box _tasksBox;
  late Box _resourcesBox;
  late Box _resourceFilesBox;
  late Box _profileBox;
  late Box _settingsBox;

  Future<void> init() async {
    _tasksBox = Hive.box(AppConstants.tasksBox);
    _resourcesBox = Hive.box(AppConstants.resourcesBox);
    _resourceFilesBox = Hive.box(AppConstants.resourceFilesBox);
    _profileBox = Hive.box(AppConstants.profileBox);
    _settingsBox = Hive.box(AppConstants.settingsBox);
  }

  // Tasks Box
  Box get tasksBox => _tasksBox;

  // Resources Box
  Box get resourcesBox => _resourcesBox;

  // Resource Files Box
  Box get resourceFilesBox => _resourceFilesBox;

  // Profile Box
  Box get profileBox => _profileBox;

  // Settings Box
  Box get settingsBox => _settingsBox;

  // Helper methods for tasks
  Future<void> saveTask(String id, Map<String, dynamic> taskJson) async {
    await _tasksBox.put(id, taskJson);
  }

  Map<String, dynamic>? getTask(String id) {
    final data = _tasksBox.get(id);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  Future<void> deleteTask(String id) async {
    await _tasksBox.delete(id);
  }

  Map<String, dynamic> getAllTasks() {
    final Map<String, dynamic> tasks = {};
    for (final key in _tasksBox.keys) {
      tasks[key as String] = _tasksBox.get(key);
    }
    return tasks;
  }

  // Helper methods for resources
  Future<void> saveResource(String id, Map<String, dynamic> resourceJson) async {
    await _resourcesBox.put(id, resourceJson);
  }

  Map<String, dynamic>? getResource(String id) {
    final data = _resourcesBox.get(id);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  Future<void> deleteResource(String id) async {
    await _resourcesBox.delete(id);
    await _resourceFilesBox.delete(id);
  }

  Map<String, dynamic> getAllResources() {
    final Map<String, dynamic> resources = {};
    for (final key in _resourcesBox.keys) {
      resources[key as String] = _resourcesBox.get(key);
    }
    return resources;
  }

  // Helper methods for resource files
  Future<void> saveResourceFile(String id, List<int> data) async {
    await _resourceFilesBox.put(id, data);
  }

  List<int>? getResourceFile(String id) {
    final data = _resourceFilesBox.get(id);
    if (data is List) {
      return List<int>.from(data);
    }
    return null;
  }

  Future<void> deleteResourceFile(String id) async {
    await _resourceFilesBox.delete(id);
  }

  // Helper methods for profile
  Future<void> saveProfile(Map<String, dynamic> profileJson) async {
    await _profileBox.put('user', profileJson);
  }

  Map<String, dynamic>? getProfile() {
    final data = _profileBox.get('user');
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Helper methods for settings
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _tasksBox.clear();
    await _resourcesBox.clear();
    await _resourceFilesBox.clear();
    // Keep profile and settings
  }
}
