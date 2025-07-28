import 'package:uuid/uuid.dart';

/// Enum representing different types of notes that can be created
enum NoteType {
  todo,
  list,
  event,
  paragraph,
}

/// Extension to provide display names for note types
extension NoteTypeExtension on NoteType {
  String get displayName {
    switch (this) {
      case NoteType.todo:
        return 'To-Do';
      case NoteType.list:
        return 'List';
      case NoteType.event:
        return 'Event';
      case NoteType.paragraph:
        return 'Note';
    }
  }
}

/// Model class representing a structured note
class Note {
  final String id;
  final String title;
  final NoteType type;
  final List<String> content;
  final DateTime? date; // For events - the scheduled date
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? originalInput; // Store original text for reroll functionality
  final List<String> tags; // Tags for organization and search

  Note({
    String? id,
    required this.title,
    required this.type,
    required this.content,
    this.date,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.originalInput,
    this.tags = const [],
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Factory constructor to create a Note from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    DateTime? eventDate;
    if (json['date'] != null && json['date'] is String) {
      try {
        eventDate = DateTime.parse(json['date'] as String);
      } catch (e) {
        eventDate = null;
      }
    }

    return Note(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String,
      type: NoteType.values.firstWhere(
        (e) => e.toString() == 'NoteType.${json['type']}',
        orElse: () => NoteType.paragraph,
      ),
      content: List<String>.from(json['content'] as List),
      date: eventDate,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      originalInput: json['originalInput'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : [],
    );
  }

  /// Convert Note to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.toString().split('.').last,
      'content': content,
      'date': date?.toIso8601String().split('T')[0],
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'originalInput': originalInput,
      'tags': tags,
    };
  }

  /// Create a copy of this note with updated fields
  Note copyWith({
    String? title,
    NoteType? type,
    List<String>? content,
    DateTime? date,
    DateTime? updatedAt,
    String? originalInput,
    List<String>? tags,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      content: content ?? this.content,
      date: date ?? this.date,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      originalInput: originalInput ?? this.originalInput,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, type: $type, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model class for checklist items
class ChecklistItem {
  final String text;
  final bool isCompleted;

  ChecklistItem({
    required this.text,
    this.isCompleted = false,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      text: json['text'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCompleted': isCompleted,
    };
  }

  ChecklistItem copyWith({
    String? text,
    bool? isCompleted,
  }) {
    return ChecklistItem(
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'ChecklistItem(text: $text, isCompleted: $isCompleted)';
  }
}
