import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/task_provider.dart';
import '../../providers/resource_provider.dart';
import '../../models/task_model.dart';
import '../../theme/app_colors.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TaskPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    final task = ref.read(taskProvider)[widget.taskId];
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _categoryController = TextEditingController(text: task?.category ?? '');
    _selectedPriority = task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    ref.read(taskProvider.notifier).updateTask(
          widget.taskId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
          priority: _selectedPriority,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task updated successfully')),
    );
  }

  void _toggleCompletion() {
    ref.read(taskProvider.notifier).toggleTaskCompletion(widget.taskId);
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(taskProvider.notifier).deleteTask(widget.taskId);
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.priorityHigh)),
          ),
        ],
      ),
    );
  }

  void _showResourcePicker() {
    final task = ref.read(taskProvider)[widget.taskId];
    if (task == null) return;

    final resources = ref.read(resourceProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final selectedIds = List<String>.from(task.linkedResourceIds);

          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attach Resources',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: resources.isEmpty
                      ? const Center(child: Text('No resources in library'))
                      : ListView.builder(
                          itemCount: resources.length,
                          itemBuilder: (context, index) {
                            final resource = resources.values.toList()[index];
                            final isSelected = selectedIds.contains(resource.id);

                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setModalState(() {
                                  if (value == true) {
                                    selectedIds.add(resource.id);
                                  } else {
                                    selectedIds.remove(resource.id);
                                  }
                                });
                              },
                              title: Text(resource.title),
                              subtitle: Text(resource.type.displayName),
                              activeColor: AppColors.primaryAccent,
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(taskProvider.notifier).updateTask(
                            widget.taskId,
                            linkedResourceIds: selectedIds,
                          );
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: Text('Done (${selectedIds.length} selected)'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = ref.watch(taskProvider)[widget.taskId];

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Not Found')),
        body: const Center(child: Text('Task not found')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(
                    child: Text(
                      'Task Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextField(
                      controller: _titleController,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Task Title',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextField(
                      controller: _descriptionController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'Add description or notes...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 24),

                    // Priority Selector
                    Text(
                      'Priority',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _PriorityChip(
                          label: 'Low',
                          color: AppColors.priorityLow,
                          isSelected: _selectedPriority == TaskPriority.low,
                          onTap: () => setState(() => _selectedPriority = TaskPriority.low),
                        ),
                        const SizedBox(width: 8),
                        _PriorityChip(
                          label: 'Medium',
                          color: AppColors.priorityMedium,
                          isSelected: _selectedPriority == TaskPriority.medium,
                          onTap: () => setState(() => _selectedPriority = TaskPriority.medium),
                        ),
                        const SizedBox(width: 8),
                        _PriorityChip(
                          label: 'High',
                          color: AppColors.priorityHigh,
                          isSelected: _selectedPriority == TaskPriority.high,
                          onTap: () => setState(() => _selectedPriority = TaskPriority.high),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Category
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category (optional)',
                        hintText: 'e.g., Biology, Math, etc.',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Linked Resources
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Study Materials',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        TextButton.icon(
                          onPressed: _showResourcePicker,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Attach'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (task.linkedResourceIds.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No resources attached',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: task.linkedResourceIds.length,
                        itemBuilder: (context, index) {
                          final resourceId = task.linkedResourceIds[index];
                          final resource = ref.read(resourceProvider)[resourceId];

                          if (resource == null) {
                            return const SizedBox.shrink();
                          }

                          return _LinkedResourceCard(resourceId: resourceId);
                        },
                      ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _toggleCompletion,
                            icon: Icon(task.isCompleted ? Icons.undo : Icons.check),
                            label: Text(task.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: task.isCompleted
                                  ? AppColors.textTertiary
                                  : AppColors.secondaryAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _deleteTask,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Task'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.priorityHigh,
                          side: const BorderSide(color: AppColors.priorityHigh),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkedResourceCard extends ConsumerWidget {
  final String resourceId;

  const _LinkedResourceCard({required this.resourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resource = ref.read(resourceProvider)[resourceId];

    if (resource == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getResourceIcon(resource.type),
            size: 24,
            color: AppColors.primaryAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              resource.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.push('/library/$resourceId');
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  IconData _getResourceIcon(ResourceType type) {
    switch (type) {
      case ResourceType.pdf:
        return Icons.description;
      case ResourceType.audio:
        return Icons.headset;
      case ResourceType.video:
        return Icons.play_circle;
      case ResourceType.link:
        return Icons.link;
      case ResourceType.image:
        return Icons.image;
      case ResourceType.note:
        return Icons.edit_note;
    }
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.textTertiary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
