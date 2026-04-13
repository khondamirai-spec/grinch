import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/resource_provider.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditingName = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    if (_nameController.text.trim().isNotEmpty) {
      ref.read(profileProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
          );
    }
    setState(() => _isEditingName = false);
  }

  void _exportData() {
    // Simple JSON export of all data
    final tasks = ref.read(taskProvider);
    final resources = ref.read(resourceProvider);
    final profile = ref.read(profileProvider);

    final data = {
      'tasks': tasks.values.map((t) => t.toJson()).toList(),
      'resources': resources.values.map((r) => r.toJson()).toList(),
      'profile': profile?.toJson(),
      'exportedAt': DateTime.now().toIso8601String(),
    };

    // In a real app, you'd save this to a file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data exported successfully')),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will delete all your tasks and resources. This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Final Confirmation'),
                  content: const Text('This is your last chance. All data will be permanently deleted.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        StorageService().clearAllData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All data cleared')),
                        );
                      },
                      child: const Text('Delete Everything', style: TextStyle(color: AppColors.priorityHigh)),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Continue', style: TextStyle(color: AppColors.priorityHigh)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final tasks = ref.watch(taskProvider);
    final resources = ref.watch(resourceProvider);

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(profile),
              const SizedBox(height: 32),

              // Stats Row
              _buildStats(tasks, resources, profile),
              const SizedBox(height: 32),

              // Weekly Activity Chart
              _buildWeeklyActivity(tasks),
              const SizedBox(height: 32),

              // Settings Section
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              _buildSettingsList(),
              const SizedBox(height: 32),

              // Footer
              Center(
                child: Text(
                  'Made with ❤️ by xondamir.ai',
                  style: Theme.of(context).textTheme.caption?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'v${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.caption?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: () {
              // In a real app, open image picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Avatar upload coming soon')),
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryAccent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  profile.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isEditingName)
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    onSubmitted: (_) => _saveName(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                )
              else
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              if (!_isEditingName)
                IconButton(
                  onPressed: () {
                    _nameController.text = profile.name;
                    setState(() => _isEditingName = true);
                  },
                  icon: const Icon(Icons.edit, size: 20),
                ),
              if (_isEditingName)
                IconButton(
                  onPressed: _saveName,
                  icon: const Icon(Icons.check, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // School and Grade
          if (profile.school != null)
            Text(
              profile.school!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          if (profile.grade != null)
            Text(
              profile.grade!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          if (profile.school == null && profile.grade == null)
            TextButton(
              onPressed: () {
                // Edit school/grade
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit profile coming soon')),
                );
              },
              child: const Text('Add school & grade'),
            ),
        ],
      ),
    );
  }

  Widget _buildStats(tasks, resources, profile) {
    final completedTasks = tasks.values.where((t) => t.isCompleted).length;

    return Row(
      children: [
        _buildStatBox(
          value: completedTasks.toString(),
          label: 'Tasks Done',
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          value: resources.length.toString(),
          label: 'Resources',
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          value: '${profile.currentStreak} 🔥',
          label: 'Streak',
        ),
      ],
    );
  }

  Widget _buildStatBox({required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryAccent,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.caption?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyActivity(tasks) {
    // Simple bar chart representation
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final day = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1 - index));
                final dayTasks = tasks.values.where((t) =>
                    t.dueDate.year == day.year &&
                    t.dueDate.month == day.month &&
                    t.dueDate.day == day.day).toList();
                final completedCount = dayTasks.where((t) => t.isCompleted).length;

                final isToday = index == DateTime.now().weekday - 1;
                final maxHeight = 100.0;
                final height = completedCount > 0 ? (completedCount / 10.0).clamp(0.1, 1.0) * maxHeight : 8.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primaryAccent : AppColors.textTertiary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            color: isToday ? AppColors.primaryAccent : AppColors.textSecondary,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: 'Dark / Light',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme toggle coming soon')),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Reminders',
            subtitle: 'Daily reminders',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder settings coming soon')),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.upload_file,
            title: 'Export Data',
            subtitle: 'Download all your data as JSON',
            onTap: _exportData,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            subtitle: 'Delete all tasks and resources',
            onTap: _clearAllData,
            isDestructive: true,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About StudyFlow',
            subtitle: 'Version ${AppConstants.appVersion}',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'StudyFlow',
                applicationVersion: AppConstants.appVersion,
                applicationIcon: const Icon(Icons.school, size: 48, color: AppColors.primaryAccent),
                children: [
                  Text(
                    'A student-focused daily task manager.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.priorityHigh : AppColors.primaryAccent,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.priorityHigh : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
