enum TaskPriority { low, medium, high }

class Task {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  DateTime dueDate;
  DateTime? completedAt;
  TaskPriority priority;
  List<String> linkedResourceIds;
  String? category;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.dueDate,
    this.completedAt,
    this.priority = TaskPriority.medium,
    this.linkedResourceIds = const [],
    this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority.name,
      'linkedResourceIds': linkedResourceIds,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: DateTime.parse(json['dueDate'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      linkedResourceIds: (json['linkedResourceIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? completedAt,
    TaskPriority? priority,
    List<String>? linkedResourceIds,
    String? category,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      linkedResourceIds: linkedResourceIds ?? this.linkedResourceIds,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
