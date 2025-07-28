import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/braindump_integration_service.dart';

/// Dialog for braindump input and AI processing
/// Allows users to input natural language text and get organized tasks
class BraindumpDialog extends StatefulWidget {
  final Function(List<Task>) onTasksCreated;

  const BraindumpDialog({
    super.key,
    required this.onTasksCreated,
  });

  @override
  State<BraindumpDialog> createState() => _BraindumpDialogState();
}

class _BraindumpDialogState extends State<BraindumpDialog> {
  final TextEditingController _textController = TextEditingController();
  final BraindumpIntegrationService _braindumpService = BraindumpIntegrationService();
  
  bool _isProcessing = false;
  List<Task>? _generatedTasks;
  List<String> _clarificationQuestions = [];
  Map<String, String> _clarificationAnswers = {};

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _processBraindump() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _generatedTasks = null;
      _clarificationQuestions = [];
      _clarificationAnswers = {};
    });

    try {
      // Get clarification questions first
      final questions = _braindumpService.getSuggestedClarifications(_textController.text);
      
      if (questions.isNotEmpty) {
        setState(() {
          _clarificationQuestions = questions;
          _isProcessing = false;
        });
        return;
      }

      // Process the braindump
      final tasks = await _braindumpService.processBraindump(_textController.text);
      
      setState(() {
        _generatedTasks = tasks;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing braindump: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processWithClarifications() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final tasks = await _braindumpService.processBraindump(
        _textController.text,
      );
      
      setState(() {
        _generatedTasks = tasks;
        _isProcessing = false;
        _clarificationQuestions = [];
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing braindump: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmTasks() {
    if (_generatedTasks != null && _generatedTasks!.isNotEmpty) {
      widget.onTasksCreated(_generatedTasks!);
      Navigator.of(context).pop();
    }
  }

  void _editTask(int index, Task updatedTask) {
    setState(() {
      _generatedTasks![index] = updatedTask;
    });
  }

  void _removeTask(int index) {
    setState(() {
      _generatedTasks!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'AI Braindump',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dump your thoughts and let AI organize them into tasks',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),

            // Input Section
            if (_generatedTasks == null) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What\'s on your mind?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'e.g., "buy milk, call mom at 3pm, clean room, dentist appointment tomorrow"',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    // Clarification Questions
                    if (_clarificationQuestions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Please clarify:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_clarificationQuestions.asMap().entries.map((entry) {
                        final question = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: question,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            onChanged: (value) {
                              _clarificationAnswers[question] = value;
                            },
                          ),
                        );
                      })),
                    ],
                  ],
                ),
              ),
              
              // Action Buttons
              const SizedBox(height: 24),
              Row(
                children: [
                  const Spacer(),
                  if (_clarificationQuestions.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _clarificationQuestions = [];
                          _clarificationAnswers = {};
                        });
                        _processBraindump();
                      },
                      child: const Text('Skip Clarifications'),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isProcessing 
                        ? null 
                        : (_clarificationQuestions.isNotEmpty 
                            ? _processWithClarifications 
                            : _processBraindump),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_clarificationQuestions.isNotEmpty 
                            ? 'Process with Clarifications' 
                            : 'Organize with AI'),
                  ),
                ],
              ),
            ],

            // Results Section
            if (_generatedTasks != null) ...[
              Text(
                'Generated Tasks (${_generatedTasks!.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: _generatedTasks!.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks generated. Try rephrasing your input.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _generatedTasks!.length,
                        itemBuilder: (context, index) {
                          final task = _generatedTasks![index];
                          return _TaskPreviewCard(
                            task: task,
                            onEdit: (updatedTask) => _editTask(index, updatedTask),
                            onRemove: () => _removeTask(index),
                          );
                        },
                      ),
              ),
              
              // Action Buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _generatedTasks = null;
                      });
                    },
                    child: const Text('Back to Edit'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _generatedTasks!.isEmpty ? null : _confirmTasks,
                    child: const Text('Add Tasks'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Preview card for generated tasks
class _TaskPreviewCard extends StatelessWidget {
  final Task task;
  final Function(Task) onEdit;
  final VoidCallback onRemove;

  const _TaskPreviewCard({
    required this.task,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Content type icon
                if (task.contentType != null) ...[
                  Text(
                    task.contentType!.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                ],
                
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                // Action buttons
                IconButton(
                  onPressed: () {
                    // TODO: Implement task editing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task editing coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 20),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                ),
              ],
            ),
            
            if (task.description != null) ...[
              const SizedBox(height: 4),
              Text(
                task.description!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
            
            // Task metadata
            if (task.timeSlot != null || task.deadline != null || task.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (task.timeSlot != null)
                    Chip(
                      label: Text('⏰ ${task.timeSlot}'),
                      backgroundColor: Colors.blue[50],
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                  if (task.deadline != null)
                    Chip(
                      label: Text('📅 ${task.deadline!.day}/${task.deadline!.month}'),
                      backgroundColor: Colors.orange[50],
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                  ...task.tags.take(3).map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey[100],
                    labelStyle: const TextStyle(fontSize: 12),
                  )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
