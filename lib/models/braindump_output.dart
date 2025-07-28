import 'package:uuid/uuid.dart';

/// Structured output format for braindump processing
/// This ensures tasks, lists, and schedules integrate seamlessly with the existing system
class BraindumpOutput {
  final List<BraindumpTask> tasks;
  final List<BraindumpList> lists;
  final List<BraindumpSchedule> schedules;

  BraindumpOutput({
    required this.tasks,
    required this.lists,
    required this.schedules,
  });

  factory BraindumpOutput.fromJson(Map<String, dynamic> json) {
    return BraindumpOutput(
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((e) => BraindumpTask.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      lists: (json['lists'] as List<dynamic>?)
          ?.map((e) => BraindumpList.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      schedules: (json['schedules'] as List<dynamic>?)
          ?.map((e) => BraindumpSchedule.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tasks': tasks.map((e) => e.toJson()).toList(),
      'lists': lists.map((e) => e.toJson()).toList(),
      'schedules': schedules.map((e) => e.toJson()).toList(),
    };
  }
}

/// Individual todo task from braindump
class BraindumpTask {
  final String id;
  final String title;
  final String? description;
  final String status; // "pending" or "done"
  final String priority; // "low", "medium", "high"
  final DateTime? dueDate;

  BraindumpTask({
    String? id,
    required this.title,
    this.description,
    this.status = "pending",
    this.priority = "medium",
    this.dueDate,
  }) : id = id ?? const Uuid().v4();

  factory BraindumpTask.fromJson(Map<String, dynamic> json) {
    return BraindumpTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? "pending",
      priority: json['priority'] as String? ?? "medium",
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
    };
  }
}

/// List with checkable items from braindump
class BraindumpList {
  final String id;
  final String name;
  final List<BraindumpListItem> items;

  BraindumpList({
    String? id,
    required this.name,
    required this.items,
  }) : id = id ?? const Uuid().v4();

  factory BraindumpList.fromJson(Map<String, dynamic> json) {
    return BraindumpList(
      id: json['id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => BraindumpListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

/// Individual item in a braindump list
class BraindumpListItem {
  final String item;
  final bool checked;

  BraindumpListItem({
    required this.item,
    this.checked = false,
  });

  factory BraindumpListItem.fromJson(Map<String, dynamic> json) {
    return BraindumpListItem(
      item: json['item'] as String,
      checked: json['checked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'checked': checked,
    };
  }
}

/// Scheduled event from braindump
class BraindumpSchedule {
  final String id;
  final String event;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? location;
  final List<String> relatedTaskIds;

  BraindumpSchedule({
    String? id,
    required this.event,
    this.startTime,
    this.endTime,
    this.location,
    this.relatedTaskIds = const [],
  }) : id = id ?? const Uuid().v4();

  factory BraindumpSchedule.fromJson(Map<String, dynamic> json) {
    return BraindumpSchedule(
      id: json['id'] as String,
      event: json['event'] as String,
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time'] as String)
          : null,
      location: json['location'] as String?,
      relatedTaskIds: (json['related_task_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'location': location,
      'related_task_ids': relatedTaskIds,
    };
  }
}
