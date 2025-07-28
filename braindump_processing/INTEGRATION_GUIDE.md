# Brain Dump Processing - Integration Guide

## Step-by-Step Integration

### 1. Copy Files to Your Project

Copy these 3 files to your Flutter project's `lib/` directory:
```
your_project/
├── lib/
│   ├── services/
│   │   ├── ai_service.dart
│   │   └── brain_dump_parser.dart
│   └── models/
│       └── note_model.dart
```

### 2. Add Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0      # For AI API calls
  uuid: ^4.2.1      # For generating unique note IDs
```

Run:
```bash
flutter pub get
```

### 3. Configure API Key

**IMPORTANT**: Replace the API key in `ai_service.dart`:

```dart
// In ai_service.dart, line 16
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

Get your free API key from: https://makersuite.google.com/app/apikey

### 4. Basic Implementation

Create a simple brain dump processor:

```dart
import 'package:flutter/material.dart';
import 'services/ai_service.dart';
import 'models/note_model.dart';

class BrainDumpProcessor extends StatefulWidget {
  @override
  _BrainDumpProcessorState createState() => _BrainDumpProcessorState();
}

class _BrainDumpProcessorState extends State<BrainDumpProcessor> {
  final AIService _aiService = AIService();
  final TextEditingController _controller = TextEditingController();
  List<Note> _notes = [];
  bool _isProcessing = false;

  Future<void> _processText() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final notes = await _aiService.organizeText(_controller.text);
      setState(() {
        _notes = notes;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Brain Dump')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter your messy thoughts here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processText,
              child: _isProcessing 
                ? CircularProgressIndicator()
                : Text('Organize'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    child: ListTile(
                      title: Text(note.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${note.type.displayName}'),
                          ...note.content.map((content) => Text('• $content')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 5. Advanced Features

#### Reroll Functionality
```dart
Future<void> _rerollNote(Note note) async {
  try {
    final newNotes = await _aiService.rerollNote(note);
    // Handle the new notes
  } catch (e) {
    // Handle error
  }
}
```

#### Clarification System
```dart
Future<void> _processWithClarification(String text) async {
  // Check if clarification is needed
  final analysis = _aiService.analyzeForClarification(text);
  
  if (analysis['needsClarification']) {
    // Show questions to user
    final questions = analysis['questions'] as List<String>;
    final clarifications = await _showClarificationDialog(questions);
    
    // Process with clarifications
    final notes = await _aiService.organizeWithClarification(text, clarifications);
    setState(() {
      _notes = notes;
    });
  } else {
    // Process normally
    final notes = await _aiService.organizeText(text);
    setState(() {
      _notes = notes;
    });
  }
}
```

### 6. Error Handling

The system includes built-in error handling:

```dart
try {
  final notes = await _aiService.organizeText(text);
  // Success - notes will contain organized data
} catch (e) {
  // Handle network errors, API failures, etc.
  print('Error processing text: $e');
  // The system will automatically fall back to local parsing
}
```

### 7. Fallback Parser Usage

If you want to use the fallback parser directly:

```dart
import 'services/brain_dump_parser.dart';

final parser = BrainDumpParser();
final parsed = parser.parse("buy milk call mom clean room");

// Access parsed content blocks
for (final block in parsed.blocks) {
  print('${block.type}: ${block.content}');
}
```

### 8. Customization Options

#### Custom API Model
```dart
// In ai_service.dart, change the model
static const String _model = 'gemini-1.5-pro'; // or other models
```

#### Custom Prompt
Modify the `_getAIPrompt()` method in `ai_service.dart` to customize AI behavior.

#### Custom Content Validation
Modify the `_validateContentQuality()` method to adjust garbage detection.

### 9. Testing Your Integration

Test with these sample inputs:

```dart
// Simple test
final notes = await aiService.organizeText("buy milk call mom");

// Complex test
final notes = await aiService.organizeText(
  "buy milk eggs bread call mom dentist tomorrow 2pm need tomatos lettus cheeze clean room homework due monday"
);

// Garbage test
final notes = await aiService.organizeText("asdfgh qwerty hjkl");
```

### 10. Performance Optimization

For better performance:

1. **Cache the AIService instance** - don't create new instances
2. **Implement request debouncing** for real-time processing
3. **Add loading states** for better UX
4. **Handle network timeouts** gracefully

### 11. Security Considerations

1. **API Key Security**: Never commit API keys to version control
2. **Input Validation**: The system validates input, but add your own checks
3. **Rate Limiting**: Implement rate limiting for API calls
4. **Error Logging**: Log errors securely without exposing sensitive data

### 12. Troubleshooting

#### Common Issues:

**API Key Error**:
```
Error: API Error 403: API key not valid
```
Solution: Check your API key in `ai_service.dart`

**Network Error**:
```
Error: SocketException: Failed host lookup
```
Solution: Check internet connection, API will fall back to local parser

**Parse Error**:
```
Parse error: FormatException: Unexpected character
```
Solution: This is handled automatically, system will retry or fall back

**Empty Results**:
```
No notes were generated from the input text
```
Solution: Input might be too unclear, try more descriptive text

### 13. Next Steps

After integration:
1. Test with various input types
2. Customize the UI to match your app's design
3. Add persistence to save notes
4. Implement search and filtering
5. Add export functionality

### Support

If you encounter issues:
1. Check the console for debug messages
2. Verify API key is correct
3. Test with simple inputs first
4. Check network connectivity
5. Review the API_REFERENCE.md for detailed method documentation
