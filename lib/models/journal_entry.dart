import 'package:uuid/uuid.dart';

class JournalEntry {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int wordCount;

  JournalEntry({
    String? id,
    required this.content,
    DateTime? createdAt,
    this.updatedAt,
    int? wordCount,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        wordCount = wordCount ?? _calculateWordCount(content);

  static int _calculateWordCount(String content) {
    if (content.trim().isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }

  JournalEntry copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? wordCount,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  // Update content and recalculate word count
  JournalEntry updateContent(String newContent) {
    return copyWith(
      content: newContent,
      updatedAt: DateTime.now(),
      wordCount: _calculateWordCount(newContent),
    );
  }

  // Get formatted date string
  String getFormattedDate() {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // Get formatted time string
  String getFormattedTime() {
    final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : hour;
    return '$displayHour:${createdAt.minute.toString().padLeft(2, '0')} $period';
  }

  // Get preview text (first 100 characters)
  String getPreview() {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'wordCount': wordCount,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      wordCount: json['wordCount'],
    );
  }
}
