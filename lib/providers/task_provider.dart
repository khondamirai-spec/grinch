import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';

const _uuid = Uuid();

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final taskProvider = StateNotifierProvider<TaskNotifier, Map<String, Task>>((ref) {
  return TaskNotifier(ref.watch(storageServiceProvider));
});

class TaskNotifier extends StateNotifier<Map<String, Task>> {
  final StorageService _storage;

  TaskNotifier(this._storage) : super({}) {
    _loadTasks();
  }

  void _loadTasks() {
    final tasksJson = _storage.getAllTasks();
    final tasks = <String, Task>{};
    tasksJson.forEach((key, value) {
      try {
        tasks[key] = Task.fromJson(Map<String, dynamic>.from(value));
      } catch (e) {
        // Skip invalid tasks
      }
    });
    state = tasks;
  }

  void addTask({
    required String title,
    String? description,
    required DateTime dueDate,
    TaskPriority priority = TaskPriority.medium,
    List<String> linkedResourceIds = const [],
    String? category,
  }) {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      linkedResourceIds: linkedResourceIds,
      category: category,
      createdAt: DateTime.now(),
    );

    _storage.saveTask(task.id, task.toJson());
    state = {...state, task.id: task};
  }

  void updateTask(String id, {
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    TaskPriority? priority,
    List<String>? linkedResourceIds,
    String? category,
  }) {
    final task = state[id];
    if (task == null) return;

    final updatedTask = task.copyWith(
      title: title,
      description: description,
      isCompleted: isCompleted,
      dueDate: dueDate,
      priority: priority,
      linkedResourceIds: linkedResourceIds,
      category: category,
      completedAt: isCompleted == true && task.completedAt == null
          ? DateTime.now()
          : isCompleted == false
              ? null
              : task.completedAt,
    );

    _storage.saveTask(id, updatedTask.toJson());
    state = {...state, id: updatedTask};
  }

  void toggleTaskCompletion(String id) {
    final task = state[id];
    if (task == null) return;

    updateTask(
      id,
      isCompleted: !task.isCompleted,
    );
  }

  void deleteTask(String id) {
    _storage.deleteTask(id);
    final newState = Map<String, Task>.from(state);
    newState.remove(id);
    state = newState;
  }

  List<Task> getTasksForDate(DateTime date, {bool sortByPriority = true}) {
    final tasks = state.values.where((task) {
      return task.dueDate.year == date.year &&
          task.dueDate.month == date.month &&
          task.dueDate.day == date.day;
    }).toList();

    if (sortByPriority) {
      tasks.sort((a, b) {
        return b.priority.index.compareTo(a.priority.index);
      });
    } else {
      tasks.sort((a, b) {
        return a.createdAt.compareTo(b.createdAt);
      });
    }

    return tasks;
  }

  int getCompletedTasksCount() {
    return state.values.where((task) => task.isCompleted).length;
  }

  int getTotalTasksCount() {
    return state.length;
  }

  List<String> getAllCategories() {
    final categories = state.values
        .where((task) => task.category != null && task.category!.isNotEmpty)
        .map((task) => task.category!)
        .toSet()
        .toList();
    return categories;
  }
}
