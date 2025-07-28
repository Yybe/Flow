import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import 'braindump_dialog.dart'; // BRAINDUMP INTEGRATION: AI-powered task creation

class EnhancedTaskDialog extends StatefulWidget {
  final TaskType taskType;

  const EnhancedTaskDialog({
    super.key,
    required this.taskType,
  });

  @override
  State<EnhancedTaskDialog> createState() => _EnhancedTaskDialogState();
}

class _EnhancedTaskDialogState extends State<EnhancedTaskDialog> {
  int _selectedOption = 0; // 0 = Custom, 1 = Braindump with AI
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  TimeOfDay? _selectedDeadline;
  String? _selectedColor;

  // Predefined colors for task backgrounds
  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Default', 'color': null, 'displayColor': Colors.grey[200]},
    {'name': 'Red', 'color': '#FFEBEE', 'displayColor': Colors.red[50]},
    {'name': 'Blue', 'color': '#E3F2FD', 'displayColor': Colors.blue[50]},
    {'name': 'Green', 'color': '#E8F5E8', 'displayColor': Colors.green[50]},
    {'name': 'Orange', 'color': '#FFF3E0', 'displayColor': Colors.orange[50]},
    {'name': 'Purple', 'color': '#F3E5F5', 'displayColor': Colors.purple[50]},
    {'name': 'Teal', 'color': '#E0F2F1', 'displayColor': Colors.teal[50]},
    {'name': 'Yellow', 'color': '#FFFDE7', 'displayColor': Colors.yellow[50]},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBeige,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add ${widget.taskType == TaskType.routine ? 'Routine' : 'Daily'} Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Option selection
                    Text(
                      'Choose how to create your task:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _OptionCard(
                            title: 'Custom Task',
                            subtitle: 'Create with full customization',
                            icon: Icons.tune,
                            isSelected: _selectedOption == 0,
                            onTap: () => setState(() => _selectedOption = 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OptionCard(
                            title: 'Braindump with AI',
                            subtitle: 'Natural language input',
                            icon: Icons.psychology,
                            isSelected: _selectedOption == 1,
                            isEnabled: true, // BRAINDUMP INTEGRATION: Re-enabled
                            onTap: () => setState(() => _selectedOption = 1),
                          ),
                        ),
                      ],
                    ),

                    if (_selectedOption == 0) ...[
                      const SizedBox(height: 24),
                      _buildCustomTaskForm(),
                    ],

                    // BRAINDUMP INTEGRATION: AI-powered task creation interface
                    if (_selectedOption == 1) ...[
                      const SizedBox(height: 24),
                      _buildBraindumpInterface(),
                    ],
                  ],
                ),
              ),
            ),

            // Actions
            if (_selectedOption == 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightBeige,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _createTask,
                      child: const Text('Create Task'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTaskForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task title
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Task Title *',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        
        const SizedBox(height: 16),
        
        // Description
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),

        if (widget.taskType == TaskType.routine) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _timeController,
            decoration: const InputDecoration(
              labelText: 'Time Slot (optional)',
              hintText: 'e.g., 9:00 AM - 5:00 PM',
              border: OutlineInputBorder(),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Deadline time picker
        Row(
          children: [
            Expanded(
              child: Text(
                'Deadline (optional):',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedDeadline ?? TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDeadline = picked;
                  });
                }
              },
              icon: const Icon(Icons.access_time),
              label: Text(
                _selectedDeadline != null
                    ? _selectedDeadline!.format(context)
                    : 'Set Time',
              ),
            ),
            if (_selectedDeadline != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDeadline = null;
                  });
                },
                icon: const Icon(Icons.clear),
                iconSize: 20,
              ),
          ],
        ),

        const SizedBox(height: 16),
        
        // Tags
        TextField(
          controller: _tagsController,
          decoration: const InputDecoration(
            labelText: 'Tags (optional)',
            hintText: 'work, personal, urgent (comma separated)',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),
        
        // Color selection
        Text(
          'Background Color:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _colorOptions.map((colorOption) {
              final isSelected = _selectedColor == colorOption['color'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorOption['color'];
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorOption['displayColor'],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.teal : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: AppColors.teal, size: 18)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // BRAINDUMP INTEGRATION: Interface for AI-powered task creation
  Widget _buildBraindumpInterface() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: Colors.blue[700], size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'AI Braindump',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Dump your thoughts in natural language and let AI organize them into structured tasks.',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Example: "buy milk, call mom at 3pm, clean room, dentist appointment tomorrow"',
                style: TextStyle(
                  color: Colors.blue[500],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _openBraindumpDialog(),
          icon: const Icon(Icons.psychology),
          label: const Text('Start AI Braindump'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  // BRAINDUMP INTEGRATION: Open the braindump dialog
  void _openBraindumpDialog() {
    showDialog(
      context: context,
      builder: (context) => BraindumpDialog(
        onTasksCreated: (tasks) {
          // Add the generated tasks to the task provider
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          for (final task in tasks) {
            taskProvider.addTaskFromBraindump(task);
          }

          // Close the main dialog
          Navigator.of(context).pop();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${tasks.length} task${tasks.length == 1 ? '' : 's'} from braindump'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _createTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Convert TimeOfDay to DateTime for deadline
    DateTime? deadline;
    if (_selectedDeadline != null) {
      final now = DateTime.now();
      deadline = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedDeadline!.hour,
        _selectedDeadline!.minute,
      );
    }

    taskProvider.addTask(
      _titleController.text.trim(),
      widget.taskType,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      timeSlot: _timeController.text.trim().isEmpty
          ? null
          : _timeController.text.trim(),
      deadline: deadline,
      tags: tags.isEmpty ? null : tags,
      backgroundColor: _selectedColor,
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.teal : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isEnabled 
                  ? (isSelected ? AppColors.teal : Colors.grey[600])
                  : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isEnabled ? null : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isEnabled ? Colors.grey[600] : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
