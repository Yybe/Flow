import 'package:uuid/uuid.dart';

enum HabitType { yesNo, measurable }

class Habit {
  final String id;
  final String title;
  final HabitType type;
  final String? unit; // For measurable habits like "miles", "pages", etc.
  final String? backgroundColor; // Background color for the habit
  final DateTime createdAt;
  final Map<String, dynamic> completions; // Date string -> completion data

  Habit({
    String? id,
    required this.title,
    required this.type,
    this.unit,
    this.backgroundColor,
    DateTime? createdAt,
    Map<String, dynamic>? completions,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        completions = completions ?? {};

  Habit copyWith({
    String? id,
    String? title,
    HabitType? type,
    String? unit,
    String? backgroundColor,
    DateTime? createdAt,
    Map<String, dynamic>? completions,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      createdAt: createdAt ?? this.createdAt,
      completions: completions ?? Map.from(this.completions),
    );
  }

  // Get completion status for a specific date
  bool isCompletedOnDate(DateTime date) {
    final dateKey = _dateToKey(date);
    return completions.containsKey(dateKey);
  }

  // Get completion value for measurable habits
  double? getCompletionValue(DateTime date) {
    final dateKey = _dateToKey(date);
    final completion = completions[dateKey];
    if (completion is Map && completion['value'] != null) {
      return completion['value'].toDouble();
    }
    return null;
  }

  // Mark habit as completed for a specific date
  Habit markCompleted(DateTime date, {double? value}) {
    final dateKey = _dateToKey(date);
    final newCompletions = Map<String, dynamic>.from(completions);
    
    if (type == HabitType.yesNo) {
      newCompletions[dateKey] = {'completed': true, 'timestamp': DateTime.now().toIso8601String()};
    } else {
      newCompletions[dateKey] = {
        'completed': true,
        'value': value ?? 1.0,
        'timestamp': DateTime.now().toIso8601String()
      };
    }
    
    return copyWith(completions: newCompletions);
  }

  // Remove completion for a specific date
  Habit markIncomplete(DateTime date) {
    final dateKey = _dateToKey(date);
    final newCompletions = Map<String, dynamic>.from(completions);
    newCompletions.remove(dateKey);
    return copyWith(completions: newCompletions);
  }

  // Get last 7 days completion status
  List<bool> getLast7DaysStatus() {
    final List<bool> status = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      status.add(isCompletedOnDate(date));
    }
    
    return status;
  }

  // Get current streak
  int getCurrentStreak() {
    int streak = 0;
    final now = DateTime.now();
    
    for (int i = 0; i < 365; i++) { // Check up to a year
      final date = now.subtract(Duration(days: i));
      if (isCompletedOnDate(date)) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'unit': unit,
      'backgroundColor': backgroundColor,
      'createdAt': createdAt.toIso8601String(),
      'completions': completions,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      type: HabitType.values.firstWhere((e) => e.name == json['type']),
      unit: json['unit'],
      backgroundColor: json['backgroundColor'],
      createdAt: DateTime.parse(json['createdAt']),
      completions: Map<String, dynamic>.from(json['completions'] ?? {}),
    );
  }
}
