import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';
import '../services/storage_service.dart';
import 'task_provider.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  return ProfileNotifier(ref.watch(storageServiceProvider));
});

class ProfileNotifier extends StateNotifier<UserProfile?> {
  final StorageService _storage;

  ProfileNotifier(this._storage) : super(null) {
    _loadProfile();
  }

  void _loadProfile() {
    final profileJson = _storage.getProfile();
    if (profileJson != null) {
      state = UserProfile.fromJson(Map<String, dynamic>.from(profileJson));
    } else {
      // Create default profile
      state = UserProfile(
        joinedAt: DateTime.now(),
      );
      _storage.saveProfile(state!.toJson());
    }
  }

  void updateProfile({
    String? name,
    String? school,
    String? grade,
  }) {
    if (state == null) return;

    state = state!.copyWith(
      name: name,
      school: school,
      grade: grade,
    );

    _storage.saveProfile(state!.toJson());
  }

  void updateStreak(int streak) {
    if (state == null) return;

    state = state!.copyWith(
      currentStreak: streak,
    );

    _storage.saveProfile(state!.toJson());
  }

  void incrementTasksCompleted() {
    if (state == null) return;

    state = state!.copyWith(
      totalTasksCompleted: state!.totalTasksCompleted + 1,
    );

    _storage.saveProfile(state!.toJson());
  }
}
