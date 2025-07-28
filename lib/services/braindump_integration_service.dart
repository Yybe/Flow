import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../braindump_processing/ai_service.dart';
import '../braindump_processing/note_model.dart';

/// Service to integrate braindump processing with the main task system
/// This service creates properly structured tasks that blend seamlessly with manually created ones
class BraindumpIntegrationService {
  final AIService _aiService = AIService();

  /// Process raw braindump text and convert to organized tasks
  /// Returns a list of tasks that look exactly like manually created ones
  Future<List<Task>> processBraindump(String rawText) async {
    if (rawText.trim().isEmpty) return [];

    try {
      if (kDebugMode) {
        print('🧠 BRAINDUMP: Processing input text...');
      }

      // Use AI service to organize the text into structured notes
      final notes = await _aiService.organizeText(rawText);

      if (kDebugMode) {
        print('🧠 BRAINDUMP: Generated ${notes.length} notes');
      }

      // Convert notes to properly structured tasks
      final tasks = <Task>[];
      for (final note in notes) {
        final convertedTasks = _convertNoteToStructuredTasks(note);
        tasks.addAll(convertedTasks);
      }

      if (kDebugMode) {
        print('🧠 BRAINDUMP: Converted to ${tasks.length} structured tasks');
      }

      return tasks;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BRAINDUMP ERROR: $e');
      }

      // Fallback: create a simple task from the raw text
      return [
        Task(
          title: 'Braindump Note',
          description: rawText.trim(),
          type: TaskType.daily,
          contentType: TaskContentType.note,
        )
      ];
    }
  }

  /// Convert a Note from the braindump system to properly structured Tasks
  /// This creates tasks that look exactly like manually created ones
  List<Task> _convertNoteToStructuredTasks(Note note) {
    final tasks = <Task>[];

    switch (note.type) {
      case NoteType.todo:
        // Create individual tasks for each todo item
        for (final content in note.content) {
          if (content.trim().isNotEmpty) {
            tasks.add(_createTodoTask(content.trim(), note));
          }
        }
        break;

      case NoteType.list:
        // Create a single list-type task with proper formatting
        tasks.add(_createListTask(note));
        break;

      case NoteType.event:
        // Create event/schedule tasks with proper time formatting
        tasks.add(_createEventTask(note));
        break;

      case NoteType.paragraph:
        // Create note-type tasks
        tasks.add(_createNoteTask(note));
        break;
    }

    return tasks;
  }

  /// Create a todo task that looks like a manually created task
  Task _createTodoTask(String content, Note note) {
    return Task(
      title: content,
      type: TaskType.daily,
      contentType: TaskContentType.todo,
      backgroundColor: '#E3F2FD', // Light blue
      tags: [...note.tags, 'braindump', 'todo'],
      originalBraindumpText: note.originalInput,
    );
  }

  /// Create a list task with individual checkable items
  Task _createListTask(Note note) {
    // Create individual TaskListItem objects for each list item
    final listItems = note.content
        .where((item) => item.trim().isNotEmpty)
        .map((item) => TaskListItem(text: item.trim()))
        .toList();

    return Task(
      title: note.title.isNotEmpty ? note.title : 'List',
      description: 'List with ${listItems.length} items',
      type: TaskType.daily,
      contentType: TaskContentType.list,
      backgroundColor: '#F3E5F5', // Light purple
      tags: [...note.tags, 'braindump', 'list'],
      originalBraindumpText: note.originalInput,
      listItems: listItems,
    );
  }

  /// Create an event/schedule task with proper time formatting
  Task _createEventTask(Note note) {
    String? timeSlot;

    // Extract time information if available and format it properly
    if (note.date != null) {
      final eventTime = note.date!;
      final hour = eventTime.hour;
      final minute = eventTime.minute;

      // Format as 12-hour time (like manually created tasks)
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final displayMinute = minute.toString().padLeft(2, '0');
      timeSlot = '$displayHour:$displayMinute $period';
    }

    // Use first content item as description if available
    final description = note.content.isNotEmpty ? note.content.first : null;

    return Task(
      title: note.title.isNotEmpty ? note.title : 'Event',
      description: description,
      type: TaskType.routine, // Events are typically routine
      contentType: TaskContentType.event,
      backgroundColor: '#FFF3E0', // Light orange
      timeSlot: timeSlot, // Only set timeSlot, not deadline
      tags: [...note.tags, 'braindump', 'event'],
      originalBraindumpText: note.originalInput,
    );
  }

  /// Create a note task for general content
  Task _createNoteTask(Note note) {
    final description = note.content.join('\n');

    return Task(
      title: note.title.isNotEmpty ? note.title : 'Note',
      description: description.isNotEmpty ? description : null,
      type: TaskType.daily,
      contentType: TaskContentType.note,
      backgroundColor: '#E8F5E8', // Light green
      tags: [...note.tags, 'braindump', 'note'],
      originalBraindumpText: note.originalInput,
    );
  }

  /// Get suggested clarification questions for ambiguous input
  List<String> getSuggestedClarifications(String rawText) {
    final suggestions = <String>[];
    final lowerText = rawText.toLowerCase();

    // Check for time-related ambiguity
    if (lowerText.contains(RegExp(r'\b(call|meeting|appointment)\b')) && 
        !lowerText.contains(RegExp(r'\b\d{1,2}:\d{2}\b|\b\d{1,2}\s*(am|pm)\b'))) {
      suggestions.add('What time is this scheduled for?');
    }

    // Check for date ambiguity
    if (lowerText.contains(RegExp(r'\b(tomorrow|today|next week|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b')) &&
        !lowerText.contains(RegExp(r'\b\d{1,2}/\d{1,2}\b|\b\d{4}-\d{2}-\d{2}\b'))) {
      suggestions.add('What specific date is this for?');
    }

    // Check for multiple items that might need separation
    if (rawText.split(RegExp(r'\s+')).length > 10) {
      suggestions.add('Should these be separated into different tasks?');
    }

    // Check for shopping/list items
    if (lowerText.contains(RegExp(r'\b(buy|get|pick up|purchase)\b'))) {
      suggestions.add('Is this a shopping list or separate tasks?');
    }

    return suggestions;
  }
}
