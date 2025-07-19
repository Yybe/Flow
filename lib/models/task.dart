import 'package:uuid/uuid.dart';

enum TaskType { routine, daily }

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
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? [];

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
