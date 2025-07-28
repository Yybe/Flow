import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'note_model.dart';

/// Enum to represent content quality for validation
enum ContentQuality {
  good,    // Clear, meaningful content
  poor,    // Unclear but potentially meaningful
  garbage, // Random letters, keyboard mashing, spam
}

/// SYNAPSE AI SERVICE - Clean AI-First Note Organization
/// Lightweight, mobile-optimized service for intelligent note processing
class AIService {
  static const String _apiKey = 'AIzaSyCsrevyqwDsl7AOpOGimclCi5emTS5qco8';
  static const String _model = 'gemini-2.0-flash';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  /// Main method - Clean AI-first approach with performance monitoring and content validation
  Future<List<Note>> organizeText(String rawText) async {
    if (rawText.trim().isEmpty) return [];

    final stopwatch = Stopwatch()..start();

    if (kDebugMode) {
      print('🤖 SYNAPSE AI: Processing input...');
    }

    // Pre-validate content quality
    final contentQuality = _validateContentQuality(rawText);
    if (contentQuality == ContentQuality.garbage) {
      if (kDebugMode) {
        print('🗑️ Input appears to be garbage, creating helpful note');
      }
      return [Note(
        title: 'Unclear Input',
        type: NoteType.paragraph,
        content: ['Please provide clearer instructions for note organization. Try describing what you want to remember or organize.'],
        originalInput: rawText,
      )];
    }

    try {
      final response = await _callAI(rawText);
      final notes = _parseAIResponse(response, rawText);

      if (notes.isNotEmpty) {
        stopwatch.stop();
        if (kDebugMode) {
          print('✅ AI SUCCESS: Generated ${notes.length} notes in ${stopwatch.elapsedMilliseconds}ms');
        }
        return notes;
      }

      // Single retry with enhanced prompt
      if (kDebugMode) {
        print('⚠️ Retrying with enhanced prompt...');
      }
      final retryResponse = await _callAI('Please organize this text into structured notes: $rawText');
      final retryNotes = _parseAIResponse(retryResponse, rawText);

      if (retryNotes.isNotEmpty) {
        stopwatch.stop();
        if (kDebugMode) {
          print('✅ RETRY SUCCESS: Generated ${retryNotes.length} notes in ${stopwatch.elapsedMilliseconds}ms');
        }
        return retryNotes;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AI API failed: $e');
      }
    }

    // Simple fallback - create a single note
    if (kDebugMode) {
      print('🆘 Creating fallback note');
    }

    final result = contentQuality == ContentQuality.poor
      ? [Note(
          title: 'Unclear Input',
          type: NoteType.paragraph,
          content: ['Please provide clearer instructions. Try describing specific tasks, events, or items you want to organize.'],
          originalInput: rawText,
        )]
      : [Note(
          title: 'Note',
          type: NoteType.paragraph,
          content: [rawText.trim()],
          originalInput: rawText,
        )];

    stopwatch.stop();
    if (kDebugMode) {
      print('⏱️ AI Processing completed in ${stopwatch.elapsedMilliseconds}ms');
    }

    return result;
  }

  /// Reroll a note using its original input
  Future<List<Note>> rerollNote(Note note) async {
    if (note.originalInput == null || note.originalInput!.isEmpty) {
      throw Exception('Cannot reroll note: no original input stored');
    }

    if (kDebugMode) {
      print('🔄 REROLL: Re-organizing note with original input...');
    }
    return organizeText(note.originalInput!);
  }

  /// Check if input needs clarification and suggest questions
  Map<String, dynamic> analyzeForClarification(String text) {
    final lower = text.toLowerCase();

    // Check for ambiguous time references
    bool hasAmbiguousTime = false;
    List<String> timeWords = ['tomorrow', 'later', 'soon', 'next week', 'this weekend'];
    for (String timeWord in timeWords) {
      if (lower.contains(timeWord)) {
        hasAmbiguousTime = true;
        break;
      }
    }

    // Check for ambiguous meeting/event references
    bool hasAmbiguousEvent = false;
    if ((lower.contains('meet') || lower.contains('call') || lower.contains('appointment'))
        && !lower.contains('at ') && !lower.contains('pm') && !lower.contains('am')) {
      hasAmbiguousEvent = true;
    }

    // Check for mixed contexts (shopping + events + todos)
    int contextCount = 0;
    if (lower.contains('buy') || lower.contains('shop') || lower.contains('get ')) contextCount++;
    if (lower.contains('call') || lower.contains('meet') || lower.contains('appointment')) contextCount++;
    if (lower.contains('study') || lower.contains('homework') || lower.contains('work on')) contextCount++;

    List<String> questions = [];

    if (hasAmbiguousTime && hasAmbiguousEvent) {
      questions.add('What specific time is your meeting/appointment?');
    }

    if (hasAmbiguousEvent) {
      questions.add('Is this a scheduled event or just a reminder to call someone?');
    }

    if (contextCount > 2) {
      questions.add('Would you like me to separate these into different types of notes?');
    }

    return {
      'needsClarification': questions.isNotEmpty,
      'questions': questions,
      'confidence': questions.isEmpty ? 'high' : 'medium',
    };
  }

  /// Process text with user clarifications
  Future<List<Note>> organizeWithClarification(String text, Map<String, String> clarifications) async {
    String enhancedText = text;

    // Apply clarifications to enhance the text
    clarifications.forEach((question, answer) {
      if (question.contains('time') && answer.isNotEmpty) {
        enhancedText += ' at $answer';
      }
      if (question.contains('scheduled event') && answer.toLowerCase().contains('event')) {
        enhancedText = enhancedText.replaceAll('call', 'meeting with');
      }
      if (question.contains('separate') && answer.toLowerCase().contains('yes')) {
        // The AI will handle separation naturally
        enhancedText = 'Please organize these into separate notes: $enhancedText';
      }
    });

    if (kDebugMode) {
      print('🤔 CLARIFIED: Processing with enhanced context...');
    }
    return organizeText(enhancedText);
  }

  /// Call AI API with Gemini format
  Future<String> _callAI(String text) async {
    try {
      if (kDebugMode) {
        print('🔄 Calling Gemini API with model: $_model');
      }

      final headers = {
        'Content-Type': 'application/json',
        'X-goog-api-key': _apiKey,
      };

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '${_getAIPrompt()}\n\nUser input: $text'
              }
            ]
          }
        ]
      });

      if (kDebugMode) {
        print('📤 Request model: $_model');
        print('📤 Request body: ${body.substring(0, 100)}...');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/$_model:generateContent'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          String content = data['candidates'][0]['content']['parts'][0]['text'];
          if (kDebugMode) {
            print('✅ Gemini API SUCCESS');
          }
          return content;
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ API call failed: $e');
      }
      rethrow;
    }
  }

  /// Enhanced AI prompt for intelligent note organization with content validation and spam filtering
  String _getAIPrompt() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final monday = DateTime.now().add(Duration(days: (8 - DateTime.now().weekday) % 7)).toIso8601String().split('T')[0];

    return '''
You are Synapse AI - an elite intelligent note organizer. Your job is to transform messy user input into perfectly organized, consolidated notes.

🧠 CRITICAL INTELLIGENCE RULES:

1. **CONTENT VALIDATION**: Filter out meaningless content intelligently
   - IGNORE random letter sequences (e.g., "asdfgh", "qwerty", "hjkl")
   - IGNORE keyboard mashing or spam text
   - IGNORE single random letters unless they're meaningful abbreviations
   - ONLY process content that has clear semantic meaning
   - If input is mostly garbage, create a simple note asking for clearer input

2. **SPELLING CORRECTION**: Fix spelling mistakes intelligently
   - "lettus" → "Lettuce"
   - "tomatos" → "Tomatoes"
   - "cheeze" → "Cheese"
   - "diwai" → "Due"
   - Use context to understand what user meant
   - BUT ignore random letter sequences that aren't real words

3. **SMART CONSOLIDATION**: Merge similar items into single notes
   - All food items → ONE shopping list
   - All study subjects → ONE study list
   - All similar tasks → ONE todo list
   - Don't create multiple notes for same category

4. **CONTEXT UNDERSTANDING**: Analyze meaningful content only
   - Look for ALL legitimate food items across the entire text
   - Group related activities together
   - Understand indirect references
   - Skip over random character sequences

📋 NOTE TYPES:
- "event": Meetings, appointments, calls, scheduled activities (with specific times/dates)
- "todo": Tasks, homework, chores, things to do
- "list": Shopping items, study subjects, collections, rankings
- "paragraph": General notes, thoughts, information

🚫 CONTENT FILTERING EXAMPLES:

Input: "buy milk todo asdfgh hjkl clean room qwerty"
WRONG: [{"title":"Shopping & Tasks","type":"todo","content":["Buy milk","asdfgh","hjkl","Clean room","qwerty"]}]
CORRECT: [{"title":"Shopping List","type":"list","content":["Milk"],"date":null},{"title":"Tasks","type":"todo","content":["Clean room"],"date":null}]

Input: "random spam letters: zxcvbn mnbvcx"
CORRECT: [{"title":"Unclear Input","type":"paragraph","content":["Please provide clearer instructions for note organization"],"date":null}]

🎯 CONSOLIDATION EXAMPLES:

Input: "buy milk eggs bread call mom dentist tomorrow 2pm need tomatos lettus cheeze clean room homework due monday"

CORRECT (consolidated):
[{"title":"Shopping List","type":"list","content":["Milk","Eggs","Bread","Tomatoes","Lettuce","Cheese"],"date":null},
 {"title":"Call Mom","type":"event","content":["Call mom"],"date":"$today"},
 {"title":"Dentist Appointment","type":"event","content":["Dentist appointment at 2:00 PM"],"date":"$today"},
 {"title":"Home & School Tasks","type":"todo","content":["Clean room","Homework due Monday"],"date":null}]

🔥 PROCESSING STEPS:
1. Read ENTIRE input and FILTER OUT meaningless content
2. Fix spelling mistakes in LEGITIMATE words only
3. Identify ALL items of each meaningful category
4. Group similar items into SINGLE notes
5. Create meaningful, specific titles
6. Extract proper dates (TODAY: $today, MONDAY: $monday)

⚡ CRITICAL: Be intelligent about content validation. Don't include random letters or spam in organized notes!

Output ONLY minified JSON array. Be intelligent, not literal!
''';
  }

  /// Parse AI response and add original input to notes
  List<Note> _parseAIResponse(String response, String originalInput) {
    try {
      String cleaned = response.trim();

      // Remove markdown code blocks if present (Gemini often wraps JSON in ```json)
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      }
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }

      cleaned = cleaned.trim();

      int start = cleaned.indexOf('[');
      int end = cleaned.lastIndexOf(']');

      if (start != -1 && end != -1) {
        cleaned = cleaned.substring(start, end + 1);
      }

      final List<dynamic> jsonList = jsonDecode(cleaned);
      return jsonList.map((json) {
        final noteJson = json as Map<String, dynamic>;
        // Add original input to each note for reroll functionality
        noteJson['originalInput'] = originalInput;
        return Note.fromJson(noteJson);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Parse error: $e');
        print('Raw response: $response');
      }
      return [];
    }
  }

  /// Validate content quality to filter out garbage input
  ContentQuality _validateContentQuality(String text) {
    final cleanText = text.trim().toLowerCase();

    if (cleanText.isEmpty) return ContentQuality.garbage;

    // Check for common keyboard mashing patterns
    final garbagePatterns = [
      RegExp(r'^[qwertyuiop]+$'),     // Top row keyboard mashing
      RegExp(r'^[asdfghjkl]+$'),      // Middle row keyboard mashing
      RegExp(r'^[zxcvbnm]+$'),        // Bottom row keyboard mashing
      RegExp(r'^[a-z]{1,3}$'),        // Single letters or very short random sequences
      RegExp(r'^[qwerty]{4,}$'),      // Repeated qwerty patterns
      RegExp(r'^[asdf]{4,}$'),        // Repeated asdf patterns
      RegExp(r'^[hjkl]{4,}$'),        // Repeated hjkl patterns
      RegExp(r'^[zxcv]{4,}$'),        // Repeated zxcv patterns
    ];

    // Check if text matches garbage patterns
    for (final pattern in garbagePatterns) {
      if (pattern.hasMatch(cleanText)) {
        return ContentQuality.garbage;
      }
    }

    // Check for very high ratio of consonants (keyboard mashing indicator)
    final consonants = cleanText.replaceAll(RegExp(r'[aeiou\s\d]'), '');
    final consonantRatio = consonants.length / cleanText.length;
    if (consonantRatio > 0.8 && cleanText.length > 5) {
      return ContentQuality.garbage;
    }

    // Check for meaningful words
    final words = cleanText.split(RegExp(r'\s+'));
    final meaningfulWords = words.where((word) =>
      word.length > 2 &&
      !RegExp(r'^[bcdfghjklmnpqrstvwxyz]{4,}$').hasMatch(word) // Not all consonants
    ).toList();

    if (meaningfulWords.isEmpty && words.length > 2) {
      return ContentQuality.garbage;
    }

    if (meaningfulWords.length < words.length * 0.3) {
      return ContentQuality.poor;
    }

    return ContentQuality.good;
  }
}
