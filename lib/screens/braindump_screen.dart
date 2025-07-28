import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/braindump_integration_service.dart';
import '../theme/app_theme.dart';

class BraindumpScreen extends StatefulWidget {
  const BraindumpScreen({super.key});

  @override
  State<BraindumpScreen> createState() => _BraindumpScreenState();
}

class _BraindumpScreenState extends State<BraindumpScreen> {
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
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      for (final task in _generatedTasks!) {
        taskProvider.addTaskFromBraindump(task);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${_generatedTasks!.length} task${_generatedTasks!.length == 1 ? '' : 's'} from braindump'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form
      setState(() {
        _textController.clear();
        _generatedTasks = null;
        _clarificationQuestions = [];
        _clarificationAnswers = {};
      });
    }
  }

  void _clearAll() {
    setState(() {
      _textController.clear();
      _generatedTasks = null;
      _clarificationQuestions = [];
      _clarificationAnswers = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text(
          'Brain Dump',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkGray),
        actions: [
          if (_textController.text.isNotEmpty || _generatedTasks != null)
            IconButton(
              onPressed: _clearAll,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input section
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.coral.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: AppColors.coral,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Dump your thoughts here',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _textController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Enter your messy thoughts, tasks, ideas...\n\nExample: "buy milk eggs bread call mom dentist tomorrow 2pm clean room homework due monday"',
                      hintStyle: TextStyle(
                        color: AppColors.gray.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.gray.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.teal, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.lightGray.withValues(alpha: 0.3),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Trigger rebuild to show/hide clear button
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processBraindump,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isProcessing
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Processing with AI...'),
                              ],
                            )
                          : const Text(
                              'Organize with AI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Results section
            Expanded(
              child: _buildResultsSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_clarificationQuestions.isNotEmpty) {
      return _buildClarificationSection();
    }

    if (_generatedTasks != null && _generatedTasks!.isNotEmpty) {
      return _buildTasksPreview();
    }

    return _buildEmptyState();
  }

  Widget _buildClarificationSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: AppColors.coral,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Need clarification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Please answer these questions to help organize your thoughts better:',
            style: TextStyle(
              color: AppColors.gray,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _clarificationQuestions.length,
              itemBuilder: (context, index) {
                final question = _clarificationQuestions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. $question',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Your answer...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.gray.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.teal, width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.lightGray.withValues(alpha: 0.3),
                        ),
                        onChanged: (value) {
                          _clarificationAnswers[question] = value;
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _clarificationQuestions = [];
                      _clarificationAnswers = {};
                    });
                    _processBraindump(); // Process without clarifications
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gray,
                    side: const BorderSide(color: AppColors.gray),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processWithClarifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : const Text('Process with answers'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksPreview() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Generated ${_generatedTasks!.length} task${_generatedTasks!.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _generatedTasks!.length,
              itemBuilder: (context, index) {
                final task = _generatedTasks![index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: task.backgroundColor != null
                        ? Color(int.parse(task.backgroundColor!.replaceFirst('#', '0xFF')))
                        : AppColors.lightGray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.gray.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (task.contentType != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${task.contentType!.icon} ${task.contentType!.displayName}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ),
                          const Spacer(),
                          if (task.timeSlot != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task.timeSlot!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGray,
                        ),
                      ),
                      if (task.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gray.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                      if (task.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: task.tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.gray,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirmTasks,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add ${_generatedTasks!.length} task${_generatedTasks!.length == 1 ? '' : 's'} to my list',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_outlined,
              size: 48,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ready to organize your thoughts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Type your messy thoughts above and let AI organize them into structured tasks for you.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
