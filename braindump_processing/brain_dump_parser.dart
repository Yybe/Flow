enum ContentType {
  note,
  task,
  event,
  reminder,
  todo,
  list,
  paragraph,
}

class ContentBlock {
  final String id;
  final ContentType type;
  final String content;
  final DateTime? dueDate;
  final bool isCompleted;
  final Map<String, dynamic> metadata;
  final double confidence;
  final List<String> relatedBlocks;

  ContentBlock({
    required this.id,
    required this.type,
    required this.content,
    this.dueDate,
    this.isCompleted = false,
    this.metadata = const {},
    this.confidence = 1.0,
    this.relatedBlocks = const [],
  });

  ContentBlock copyWith({
    String? id,
    ContentType? type,
    String? content,
    DateTime? dueDate,
    bool? isCompleted,
    Map<String, dynamic>? metadata,
    double? confidence,
    List<String>? relatedBlocks,
  }) {
    return ContentBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      metadata: metadata ?? this.metadata,
      confidence: confidence ?? this.confidence,
      relatedBlocks: relatedBlocks ?? this.relatedBlocks,
    );
  }
}

class ParsedContent {
  final List<ContentBlock> blocks;
  final Map<String, dynamic> metadata;

  ParsedContent({
    required this.blocks,
    this.metadata = const {},
  });

  // Alias for backward compatibility
  List<ContentBlock> get contentBlocks => blocks;

  ParsedContent copyWith({
    List<ContentBlock>? blocks,
    Map<String, dynamic>? metadata,
  }) {
    return ParsedContent(
      blocks: blocks ?? this.blocks,
      metadata: metadata ?? this.metadata,
    );
  }
}

class BrainDumpParser {
  static const List<String> _taskKeywords = [
    'todo',
    'task',
    'do',
    'need to',
    'should',
    'must',
    'have to',
    'remember to',
  ];

  static const List<String> _eventKeywords = [
    'meeting',
    'appointment',
    'call',
    'conference',
    'event',
    'schedule',
    'at',
    'on',
  ];

  static const List<String> _reminderKeywords = [
    'remind',
    'reminder',
    'don\'t forget',
    'remember',
    'alert',
  ];

  ParsedContent parse(String input) {
    if (input.trim().isEmpty) {
      return ParsedContent(blocks: []);
    }

    final lines = input.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final blocks = <ContentBlock>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final block = _parseBlock(line, i);
      blocks.add(block);
    }

    return ParsedContent(
      blocks: blocks,
      metadata: {
        'parsedAt': DateTime.now().toIso8601String(),
        'totalBlocks': blocks.length,
      },
    );
  }

  // Alias for backward compatibility
  ParsedContent parseInput(String input) => parse(input);

  ContentBlock _parseBlock(String content, int index) {
    final lowerContent = content.toLowerCase();

    // Check for task/todo indicators
    if (_containsAny(lowerContent, _taskKeywords) ||
        content.startsWith('- ') ||
        content.startsWith('* ') ||
        content.startsWith('• ')) {
      return ContentBlock(
        id: 'block_$index',
        type: ContentType.todo,
        content: _cleanContent(content),
        dueDate: _extractDate(content),
        confidence: 0.8,
      );
    }

    // Check for event indicators
    if (_containsAny(lowerContent, _eventKeywords)) {
      return ContentBlock(
        id: 'block_$index',
        type: ContentType.event,
        content: _cleanContent(content),
        dueDate: _extractDate(content),
        confidence: 0.7,
      );
    }

    // Check for reminder indicators
    if (_containsAny(lowerContent, _reminderKeywords)) {
      return ContentBlock(
        id: 'block_$index',
        type: ContentType.reminder,
        content: _cleanContent(content),
        dueDate: _extractDate(content),
        confidence: 0.6,
      );
    }

    // Check for list indicators
    if (content.contains(':') && content.split(':').length > 1) {
      return ContentBlock(
        id: 'block_$index',
        type: ContentType.list,
        content: _cleanContent(content),
        confidence: 0.5,
      );
    }

    // Check if it's a longer paragraph
    if (content.length > 100) {
      return ContentBlock(
        id: 'block_$index',
        type: ContentType.paragraph,
        content: _cleanContent(content),
        confidence: 0.9,
      );
    }

    // Default to note
    return ContentBlock(
      id: 'block_$index',
      type: ContentType.note,
      content: _cleanContent(content),
      confidence: 1.0,
    );
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  String _cleanContent(String content) {
    // Remove common list prefixes
    content = content.replaceFirst(RegExp(r'^[-*•]\s*'), '');
    return content.trim();
  }

  DateTime? _extractDate(String content) {
    // Simple date extraction - can be enhanced
    final dateRegex = RegExp(r'\b(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})\b');
    final match = dateRegex.firstMatch(content);
    
    if (match != null) {
      try {
        final dateStr = match.group(1)!;
        final parts = dateStr.split(RegExp(r'[/-]'));
        if (parts.length == 3) {
          final month = int.parse(parts[0]);
          final day = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final fullYear = year < 100 ? 2000 + year : year;
          return DateTime(fullYear, month, day);
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }

    // Check for time indicators
    final timeRegex = RegExp(r'\b(\d{1,2}):(\d{2})\s*(am|pm)?\b', caseSensitive: false);
    final timeMatch = timeRegex.firstMatch(content);
    
    if (timeMatch != null) {
      try {
        final hour = int.parse(timeMatch.group(1)!);
        final minute = int.parse(timeMatch.group(2)!);
        final ampm = timeMatch.group(3)?.toLowerCase();
        
        var adjustedHour = hour;
        if (ampm == 'pm' && hour != 12) {
          adjustedHour += 12;
        } else if (ampm == 'am' && hour == 12) {
          adjustedHour = 0;
        }
        
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, adjustedHour, minute);
      } catch (e) {
        // Ignore parsing errors
      }
    }

    return null;
  }

  List<ContentBlock> filterByType(ParsedContent parsed, ContentType type) {
    return parsed.blocks.where((block) => block.type == type).toList();
  }

  List<ContentBlock> getTasksOnly(ParsedContent parsed) {
    return filterByType(parsed, ContentType.task);
  }

  List<ContentBlock> getEventsOnly(ParsedContent parsed) {
    return filterByType(parsed, ContentType.event);
  }

  List<ContentBlock> getNotesOnly(ParsedContent parsed) {
    return filterByType(parsed, ContentType.note);
  }

  List<ContentBlock> getRemindersOnly(ParsedContent parsed) {
    return filterByType(parsed, ContentType.reminder);
  }
}
