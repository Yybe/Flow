# Brain Dump Processing - API Reference

## AIService Class

The main service class for AI-powered text organization.

### Constructor
```dart
AIService()
```
Creates a new instance of the AI service. No parameters required.

### Methods

#### organizeText(String rawText)
**Main processing method** - Transforms unstructured text into organized notes.

```dart
Future<List<Note>> organizeText(String rawText)
```

**Parameters:**
- `rawText` (String): The unstructured text input to organize

**Returns:**
- `Future<List<Note>>`: List of organized notes

**Example:**
```dart
final aiService = AIService();
final notes = await aiService.organizeText("buy milk call mom clean room");
// Returns: [Note(Shopping List), Note(Call Mom), Note(Tasks)]
```

**Behavior:**
- Validates content quality first
- Calls AI API for processing
- Falls back to local parsing if AI fails
- Filters out garbage/spam input
- Adds original input to notes for reroll functionality

---

#### rerollNote(Note note)
**Reprocess a note** using its original input text.

```dart
Future<List<Note>> rerollNote(Note note)
```

**Parameters:**
- `note` (Note): The note to reroll (must have originalInput)

**Returns:**
- `Future<List<Note>>`: New list of organized notes

**Throws:**
- `Exception`: If note has no original input stored

**Example:**
```dart
final newNotes = await aiService.rerollNote(existingNote);
```

---

#### analyzeForClarification(String text)
**Analyze input** to determine if clarification questions are needed.

```dart
Map<String, dynamic> analyzeForClarification(String text)
```

**Parameters:**
- `text` (String): The input text to analyze

**Returns:**
- `Map<String, dynamic>`: Analysis result with keys:
  - `needsClarification` (bool): Whether clarification is needed
  - `questions` (List<String>): List of clarification questions
  - `confidence` (String): 'high' or 'medium'

**Example:**
```dart
final analysis = aiService.analyzeForClarification("call mom tomorrow");
if (analysis['needsClarification']) {
  final questions = analysis['questions'] as List<String>;
  // Show questions to user
}
```

---

#### organizeWithClarification(String text, Map<String, String> clarifications)
**Process text** with user-provided clarifications.

```dart
Future<List<Note>> organizeWithClarification(String text, Map<String, String> clarifications)
```

**Parameters:**
- `text` (String): The original input text
- `clarifications` (Map<String, String>): Question-answer pairs

**Returns:**
- `Future<List<Note>>`: List of organized notes with enhanced context

**Example:**
```dart
final clarifications = {
  'What specific time is your meeting?': '3:00 PM',
  'Is this a scheduled event?': 'Yes, it\'s an event'
};
final notes = await aiService.organizeWithClarification(text, clarifications);
```

---

## Note Class

Represents a structured note with metadata.

### Constructor
```dart
Note({
  String? id,
  required String title,
  required NoteType type,
  required List<String> content,
  DateTime? date,
  DateTime? createdAt,
  DateTime? updatedAt,
  String? originalInput,
  List<String> tags = const [],
})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier (auto-generated if null) |
| `title` | String | Note title/heading |
| `type` | NoteType | Type of note (todo, list, event, paragraph) |
| `content` | List<String> | Note content as list of strings |
| `date` | DateTime? | Scheduled date for events |
| `createdAt` | DateTime | Creation timestamp |
| `updatedAt` | DateTime | Last update timestamp |
| `originalInput` | String? | Original text used to create note |
| `tags` | List<String> | Tags for organization |

### Methods

#### fromJson(Map<String, dynamic> json)
**Factory constructor** to create Note from JSON.

```dart
factory Note.fromJson(Map<String, dynamic> json)
```

**Example:**
```dart
final note = Note.fromJson({
  'title': 'Shopping List',
  'type': 'list',
  'content': ['Milk', 'Eggs', 'Bread']
});
```

#### toJson()
**Convert Note to JSON** for serialization.

```dart
Map<String, dynamic> toJson()
```

#### copyWith({...})
**Create a copy** of the note with updated fields.

```dart
Note copyWith({
  String? title,
  NoteType? type,
  List<String>? content,
  DateTime? date,
  DateTime? updatedAt,
  String? originalInput,
  List<String>? tags,
})
```

---

## NoteType Enum

Defines the types of notes that can be created.

### Values
- `NoteType.todo` - Task/todo items
- `NoteType.list` - Lists (shopping, items, etc.)
- `NoteType.event` - Scheduled events/appointments
- `NoteType.paragraph` - General notes/text

### Extension Methods

#### displayName
**Get display name** for the note type.

```dart
String get displayName
```

**Example:**
```dart
print(NoteType.todo.displayName); // "To-Do"
print(NoteType.list.displayName); // "List"
print(NoteType.event.displayName); // "Event"
print(NoteType.paragraph.displayName); // "Note"
```

---

## BrainDumpParser Class

Fallback parser for local text processing when AI is unavailable.

### Methods

#### parse(String input)
**Parse input text** into content blocks.

```dart
ParsedContent parse(String input)
```

**Parameters:**
- `input` (String): Text to parse

**Returns:**
- `ParsedContent`: Parsed content with blocks and metadata

#### filterByType(ParsedContent parsed, ContentType type)
**Filter blocks** by content type.

```dart
List<ContentBlock> filterByType(ParsedContent parsed, ContentType type)
```

#### Helper Methods
- `getTasksOnly(ParsedContent parsed)` - Get only task blocks
- `getEventsOnly(ParsedContent parsed)` - Get only event blocks
- `getNotesOnly(ParsedContent parsed)` - Get only note blocks
- `getRemindersOnly(ParsedContent parsed)` - Get only reminder blocks

---

## ContentBlock Class

Represents a parsed content block from the fallback parser.

### Properties
- `id` (String): Unique identifier
- `type` (ContentType): Block type
- `content` (String): Block content
- `dueDate` (DateTime?): Extracted due date
- `isCompleted` (bool): Completion status
- `metadata` (Map<String, dynamic>): Additional metadata
- `confidence` (double): Parser confidence (0.0-1.0)
- `relatedBlocks` (List<String>): Related block IDs

---

## ContentType Enum

Types of content blocks for the fallback parser.

### Values
- `ContentType.note` - General notes
- `ContentType.task` - Tasks/todos
- `ContentType.event` - Events/appointments
- `ContentType.reminder` - Reminders
- `ContentType.todo` - Todo items
- `ContentType.list` - Lists
- `ContentType.paragraph` - Paragraphs

---

## ParsedContent Class

Container for parsed content blocks and metadata.

### Properties
- `blocks` (List<ContentBlock>): List of content blocks
- `metadata` (Map<String, dynamic>): Parsing metadata

### Aliases
- `contentBlocks` - Alias for `blocks` (backward compatibility)

---

## Error Handling

### Common Exceptions

#### Network Errors
```dart
try {
  final notes = await aiService.organizeText(text);
} catch (e) {
  if (e is SocketException) {
    // Handle network connectivity issues
  }
}
```

#### API Errors
```dart
// API errors are automatically handled and logged
// System falls back to local parsing
```

#### Validation Errors
```dart
// Content validation happens automatically
// Garbage input returns helpful error notes
```

---

## Configuration

### API Settings
```dart
// In ai_service.dart
static const String _apiKey = 'YOUR_API_KEY';
static const String _model = 'gemini-2.0-flash';
static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
```

### Timeout Settings
```dart
// API timeout is set to 30 seconds
.timeout(const Duration(seconds: 30))
```

### Debug Mode
The service automatically detects debug mode and provides detailed logging:
```dart
if (kDebugMode) {
  print('🤖 SYNAPSE AI: Processing input...');
}
```

---

## Performance Metrics

The service tracks performance automatically:
- Processing time measurement
- Success/failure rates
- Retry attempts
- Fallback usage

All metrics are logged in debug mode for optimization.
