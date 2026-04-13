class UserProfile {
  String name;
  String? avatarKey;
  String? school;
  String? grade;
  int totalTasksCompleted;
  int currentStreak;
  DateTime joinedAt;

  UserProfile({
    this.name = 'Student',
    this.avatarKey,
    this.school,
    this.grade,
    this.totalTasksCompleted = 0,
    this.currentStreak = 0,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarKey': avatarKey,
      'school': school,
      'grade': grade,
      'totalTasksCompleted': totalTasksCompleted,
      'currentStreak': currentStreak,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'Student',
      avatarKey: json['avatarKey'] as String?,
      school: json['school'] as String?,
      grade: json['grade'] as String?,
      totalTasksCompleted: json['totalTasksCompleted'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  UserProfile copyWith({
    String? name,
    String? avatarKey,
    String? school,
    String? grade,
    int? totalTasksCompleted,
    int? currentStreak,
    DateTime? joinedAt,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatarKey: avatarKey ?? this.avatarKey,
      school: school ?? this.school,
      grade: grade ?? this.grade,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
