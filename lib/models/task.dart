import 'package:uuid/uuid.dart';

enum TaskType { routine, daily }

/// Individual item within a list-type task
class TaskListItem {
  final String id;
  final String text;
  final bool isCompleted;

  TaskListItem({
    String? id,
    required this.text,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  TaskListItem copyWith({
    String? text,
    bool? isCompleted,
  }) {
    return TaskListItem(
      id: id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
    };
  }

  factory TaskListItem.fromJson(Map<String, dynamic> json) {
    return TaskListItem(
      id: json['id'] as String?,
      text: json['text'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

/// Content type for tasks created from braindump processing
/// This helps with proper display and organization
enum TaskContentType {
  todo,      // Simple task to be completed
  list,      // List of items (shopping, checklist, etc.)
  event,     // Scheduled event or appointment
  note,      // General note or paragraph
  reminder,  // Reminder for something
}

extension TaskContentTypeExtension on TaskContentType {
  String get displayName {
    switch (this) {
      case TaskContentType.todo:
        return 'To-Do';
      case TaskContentType.list:
        return 'List';
      case TaskContentType.event:
        return 'Event';
      case TaskContentType.note:
        return 'Note';
      case TaskContentType.reminder:
        return 'Reminder';
    }
  }

  String get icon {
    switch (this) {
      case TaskContentType.todo:
        return '✓';
      case TaskContentType.list:
        return '📝';
      case TaskContentType.event:
        return '📅';
      case TaskContentType.note:
        return '📄';
      case TaskContentType.reminder:
        return '⏰';
    }
  }
}

class Task {
  final String id;
  final String title;
  final String? description;
  final TaskType type;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? timeSlot; // For routine tasks like "9-5" or "7 PM"
  final DateTime? deadline; // Deadline time for the task
  final List<String> tags; // Tags for categorization
  final String? backgroundColor; // Hex color code for background
  final TaskContentType? contentType; // Content type for braindump-created tasks
  final String? originalBraindumpText; // Original text for reprocessing
  final List<TaskListItem> listItems; // For list-type tasks with individual checkable items

  Task({
    String? id,
    required this.title,
    this.description,
    required this.type,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    this.timeSlot,
    this.deadline,
    List<String>? tags,
    this.backgroundColor,
    this.contentType,
    this.originalBraindumpText,
    List<TaskListItem>? listItems,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? [],
        listItems = listItems ?? [];

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    String? timeSlot,
    DateTime? deadline,
    List<String>? tags,
    String? backgroundColor,
    TaskContentType? contentType,
    String? originalBraindumpText,
    List<TaskListItem>? listItems,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      timeSlot: timeSlot ?? this.timeSlot,
      deadline: deadline ?? this.deadline,
      tags: tags ?? this.tags,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      contentType: contentType ?? this.contentType,
      originalBraindumpText: originalBraindumpText ?? this.originalBraindumpText,
      listItems: listItems ?? this.listItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'timeSlot': timeSlot,
      'deadline': deadline?.toIso8601String(),
      'tags': tags,
      'backgroundColor': backgroundColor,
      'contentType': contentType?.name,
      'originalBraindumpText': originalBraindumpText,
      'listItems': listItems.map((item) => item.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: TaskType.values.firstWhere((e) => e.name == json['type']),
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      timeSlot: json['timeSlot'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      backgroundColor: json['backgroundColor'],
      contentType: json['contentType'] != null
          ? TaskContentType.values.firstWhere((e) => e.name == json['contentType'])
          : null,
      originalBraindumpText: json['originalBraindumpText'],
      listItems: json['listItems'] != null
          ? (json['listItems'] as List<dynamic>)
              .map((item) => TaskListItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  // Check if daily task should be auto-removed (24 hours after completion)
  bool shouldAutoRemove() {
    if (type != TaskType.daily || !isCompleted || completedAt == null) {
      return false;
    }
    return DateTime.now().difference(completedAt!).inHours >= 24;
  }
}
