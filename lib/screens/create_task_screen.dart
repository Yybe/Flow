import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';

class CreateTaskScreen extends StatefulWidget {
  final TaskType taskType;
  final Task? existingTask;

  const CreateTaskScreen({
    super.key,
    required this.taskType,
    this.existingTask,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {

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
  void initState() {
    super.initState();

    // Initialize form with existing task data if editing
    if (widget.existingTask != null) {
      final task = widget.existingTask!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _timeController.text = task.timeSlot ?? '';
      _tagsController.text = task.tags.join(', ');
      _selectedColor = task.backgroundColor;

      // Convert deadline DateTime to TimeOfDay
      if (task.deadline != null) {
        _selectedDeadline = TimeOfDay.fromDateTime(task.deadline!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(widget.existingTask != null
            ? 'Edit Task'
            : 'Add ${widget.taskType == TaskType.routine ? 'Routine' : 'Daily'} Task'),
        backgroundColor: AppColors.lightBeige,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text(
              'SAVE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option selection
            Text(
              'Choose how to create your task:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            const SizedBox(height: 24),
            _buildCustomTaskForm(),
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
        Text(
          'Task Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Task Title *',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
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
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 3,
        ),

        if (widget.taskType == TaskType.routine) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _timeController,
            decoration: const InputDecoration(
              labelText: 'Time Slot (optional)',
              hintText: 'e.g., 9:00 AM - 5:00 PM',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],

        const SizedBox(height: 24),
        
        // Deadline section
        Text(
          'Deadline',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: AppColors.gray),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedDeadline != null 
                      ? 'Deadline: ${_selectedDeadline!.format(context)}'
                      : 'No deadline set',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(
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
                child: Text(_selectedDeadline != null ? 'Change' : 'Set Time'),
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
        ),

        const SizedBox(height: 24),
        
        // Tags
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        TextField(
          controller: _tagsController,
          decoration: const InputDecoration(
            labelText: 'Tags (optional)',
            hintText: 'work, personal, urgent (comma separated)',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        const SizedBox(height: 24),
        
        // Color selection
        Row(
          children: [
            Text(
              'Background Color:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
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
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  void _saveTask() {
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

    if (widget.existingTask != null) {
      // Update existing task
      final updatedTask = widget.existingTask!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        timeSlot: _timeController.text.trim().isEmpty
            ? null
            : _timeController.text.trim(),
        deadline: deadline,
        tags: tags.isEmpty ? [] : tags,
        backgroundColor: _selectedColor,
      );

      taskProvider.updateTask(updatedTask);
    } else {
      // Create new task
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
    }

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


