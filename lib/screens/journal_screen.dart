import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _journalController = TextEditingController();
  final List<Map<String, dynamic>> _entries = [
    {
      'content': 'Today was a productive day. I managed to complete most of my tasks and felt really good about the progress I made on my project.',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'wordCount': 25,
    },
    {
      'content': 'Feeling a bit overwhelmed with work lately. Need to find better ways to manage my time and stress levels.',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'wordCount': 20,
    },
  ];

  int get _currentWordCount {
    if (_journalController.text.trim().isEmpty) return 0;
    return _journalController.text.trim().split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: AppColors.lightBeige,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Writing area
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and time
                Text(
                  DateFormat('EEEE, MMMM d, y • h:mm a').format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Text area
                TextField(
                  controller: _journalController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'What\'s on your mind today?',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16),
                  ),
                  onChanged: (text) {
                    setState(() {}); // Update word count
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Word count and save button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Words: $_currentWordCount',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _currentWordCount > 0 ? _saveEntry : null,
                      child: const Text('Save Entry'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            color: AppColors.lightGray,
          ),
          
          // Past entries
          Expanded(
            child: _entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: AppColors.gray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No journal entries yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start writing to see your entries here',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return _JournalEntryCard(
                        content: entry['content'],
                        date: entry['date'],
                        wordCount: entry['wordCount'],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _saveEntry() {
    if (_journalController.text.trim().isNotEmpty) {
      setState(() {
        _entries.insert(0, {
          'content': _journalController.text.trim(),
          'date': DateTime.now(),
          'wordCount': _currentWordCount,
        });
      });
      _journalController.clear();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journal entry saved!'),
          backgroundColor: AppColors.teal,
        ),
      );
    }
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }
}

class _JournalEntryCard extends StatelessWidget {
  final String content;
  final DateTime date;
  final int wordCount;

  const _JournalEntryCard({
    required this.content,
    required this.date,
    required this.wordCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and word count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM d, y • h:mm a').format(date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$wordCount words',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Content preview
            Text(
              content.length > 150 ? '${content.substring(0, 150)}...' : content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
