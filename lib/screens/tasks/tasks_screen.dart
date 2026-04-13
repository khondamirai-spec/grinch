import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/task_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart' as app_utils;
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/progress_ring.dart';
import 'tasks/add_task_sheet.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _sortByPriority = true;

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final profile = ref.watch(profileProvider);
    final tasksForDate = ref.read(taskProvider.notifier).getTasksForDate(
          _selectedDate,
          sortByPriority: _sortByPriority,
        );

    final completedCount = tasksForDate.where((t) => t.isCompleted).length;
    final totalCount = tasksForDate.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${app_utils.DateUtils.getGreeting(DateTime.now())}, ${profile?.name ?? 'Student'}',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (profile?.name ?? 'S')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Date Selector
            _buildDateSelector(),

            const SizedBox(height: 16),

            // Progress Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildProgressSummary(progress, completedCount, totalCount),
            ),

            const SizedBox(height: 16),

            // Task List
            Expanded(
              child: tasksForDate.isEmpty
                  ? EmptyState(
                      title: 'No tasks for this day',
                      subtitle: 'Tap the + button to add a new task and get started!',
                      icon: Icons.task_alt,
                      onAction: () => _showAddTaskSheet(),
                      actionLabel: 'Add Task',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: tasksForDate.length,
                      itemBuilder: (context, index) {
                        return TaskCard(task: tasksForDate[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildDateSelector() {
    final weekDays = app_utils.DateUtils.getCurrentWeek();

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = weekDays[index];
          final isSelected = app_utils.DateUtils.isSameDay(date, _selectedDate);
          final isToday = app_utils.DateUtils.isToday(date);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.primaryAccent, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    app_utils.DateUtils.formatShortDate(date),
                    style: Theme.of(context).textTheme.caption?.copyWith(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app_utils.DateUtils.formatDay(date),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressSummary(double progress, int completed, int total) {
    final profile = ref.watch(profileProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ProgressRing(
            progress: progress,
            size: 50,
            child: Center(
              child: Text(
                '$completed',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completed of $total tasks done',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                if ((profile?.currentStreak ?? 0) > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '🔥 ${profile?.currentStreak ?? 0} day streak',
                    style: Theme.of(context).textTheme.caption?.copyWith(
                          color: AppColors.secondaryAccent,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _sortByPriority = !_sortByPriority);
            },
            icon: Icon(
              _sortByPriority ? Icons.sort_by_alpha : Icons.sort,
              color: AppColors.textSecondary,
            ),
            tooltip: _sortByPriority ? 'Sort by Time' : 'Sort by Priority',
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddTaskSheet(),
    );
  }
}
