import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'create_task_screen.dart';
import 'braindump_screen.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback? onFABPressed;

  const MainScreen({super.key, this.onFABPressed});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.today,
                color: AppColors.teal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM d').format(DateTime.now()),
                  style: const TextStyle(
                    color: AppColors.gray,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100), // Reduced top padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Routine Tasks Section
                _TaskSection(
                  title: 'Routine Tasks',
                  color: AppColors.teal,
                  tasks: taskProvider.routineTasks,
                  progress: taskProvider.routineProgress,
                  onTaskToggle: (taskId) => taskProvider.toggleTaskCompletion(taskId),
                  onEditTask: (task) => _showEditTaskDialog(context, task),
                  onDeleteTask: (task) => _showDeleteConfirmation(context, task),
                ),

                const SizedBox(height: 16), // Reduced spacing between sections

                // Daily Tasks Section
                _TaskSection(
                  title: 'Daily Tasks',
                  color: AppColors.coral,
                  tasks: taskProvider.dailyTasks,
                  progress: taskProvider.dailyProgress,
                  onTaskToggle: (taskId) => taskProvider.toggleTaskCompletion(taskId),
                  onEditTask: (task) => _showEditTaskDialog(context, task),
                  onDeleteTask: (task) => _showDeleteConfirmation(context, task),
                ),
              ],
            ),
          );
        },
      ),

    );
  }

  void showTaskTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Add New Task',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 20),

              // Routine Task option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.repeat, color: AppColors.teal),
                ),
                title: const Text('Routine Task'),
                subtitle: const Text('Recurring daily tasks'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddTaskDialog(context, TaskType.routine);
                },
              ),

              // Daily Task option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.today, color: AppColors.coral),
                ),
                title: const Text('Daily Task'),
                subtitle: const Text('One-time tasks for today'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddTaskDialog(context, TaskType.daily);
                },
              ),

              // Braindump option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.purple),
                ),
                title: const Text('Braindump'),
                subtitle: const Text('AI-powered task creation'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BraindumpScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskType taskType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(taskType: taskType),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(
          taskType: task.type,
          existingTask: task,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                taskProvider.deleteTask(task.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted "${task.title}"'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class _TaskSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<Task> tasks;
  final double progress;
  final Function(String) onTaskToggle;
  final Function(Task) onEditTask;
  final Function(Task) onDeleteTask;

  const _TaskSection({
    required this.title,
    required this.color,
    required this.tasks,
    required this.progress,
    required this.onTaskToggle,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((task) => task.isCompleted).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Reduced margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Section header with title, progress, and add button
            Container(
              padding: const EdgeInsets.all(14), // Reduced padding
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14), // Slightly smaller radius
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Slightly smaller font
                    ),
                  ),
                  if (tasks.isNotEmpty) ...[
                    const SizedBox(height: 10), // Reduced spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                            fontSize: 13, // Slightly smaller font
                          ),
                        ),
                        Text(
                          '$completedCount/${tasks.length}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                            fontSize: 13, // Slightly smaller font
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4), // Smaller radius
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6, // Thinner progress bar
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12), // Reduced spacing

            // Task list or empty state
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16), // Reduced padding
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.task_outlined,
                        size: 48,
                        color: AppColors.gray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No ${title.toLowerCase()} yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add a task',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...tasks.map((task) {
                return _ModernTaskCard(
                  task: task,
                  color: color,
                  onTaskToggle: () => onTaskToggle(task.id),
                  onEditTask: () => onEditTask(task),
                  onDeleteTask: () => onDeleteTask(task),
                );
              }),


          ],
        ),
      );
  }
}

// Modern Task Card Component with gestures and better spacing
class _ModernTaskCard extends StatelessWidget {
  final Task task;
  final Color color;
  final VoidCallback onTaskToggle;
  final VoidCallback onEditTask;
  final VoidCallback onDeleteTask;

  const _ModernTaskCard({
    required this.task,
    required this.color,
    required this.onTaskToggle,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete Task'),
                content: const Text('Are you sure you want to delete this task?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) => onDeleteTask(),
        child: GestureDetector(
          onLongPress: onEditTask,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8), // Add margin between cards
            padding: const EdgeInsets.all(14), // Reduced padding
            decoration: BoxDecoration(
              color: task.backgroundColor != null
                  ? _hexToColor(task.backgroundColor!)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14), // Slightly smaller radius
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: task.isCompleted
                    ? color.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                width: task.isCompleted ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom checkbox with better styling
                GestureDetector(
                  onTap: onTaskToggle,
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isCompleted ? color : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: task.isCompleted ? color : Colors.transparent,
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),

                const SizedBox(width: 16),

                // Task content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task title with content type icon
                      Row(
                        children: [
                          if (task.contentType != null) ...[
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task.contentType!.icon,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              task.title,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? AppColors.gray
                                    : AppColors.darkGray,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Description
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildTaskDescription(context, task),
                      ],

                      // Time slot and deadline
                      if (task.timeSlot != null || task.deadline != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (task.timeSlot != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.schedule, size: 14, color: color),
                                    const SizedBox(width: 4),
                                    Text(
                                      task.timeSlot!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (task.deadline != null) const SizedBox(width: 8),
                            ],
                            if (task.deadline != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.access_time, size: 14, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDeadline(task.deadline!),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      // Tags
                      if (task.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: task.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color? _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return null;
    }
  }

  String _formatDeadline(DateTime deadline) {
    final hour = deadline.hour;
    final minute = deadline.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  Widget _buildTaskDescription(BuildContext context, Task task) {
    final description = task.description!;

    // For list-type content, display individual checkable items
    if (task.contentType == TaskContentType.list && task.listItems.isNotEmpty) {
      final widgets = <Widget>[];

      // Add the first 3 items as checkable
      widgets.addAll(task.listItems.take(3).map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: Checkbox(
                  value: item.isCompleted,
                  onChanged: (value) {
                    // Get the task provider from context
                    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                    taskProvider.toggleListItemCompletion(task.id, item.id);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray,
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        );
      }));

      // Show remaining count if there are more items
      if (task.listItems.length > 3) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${task.listItems.length - 3} more items',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    }

    // For event-type content, show with calendar icon
    if (task.contentType == TaskContentType.event) {
      return Row(
        children: [
          Icon(Icons.event, size: 14, color: AppColors.gray),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    // For reminder-type content, show with alarm icon
    if (task.contentType == TaskContentType.reminder) {
      return Row(
        children: [
          Icon(Icons.notifications, size: 14, color: AppColors.gray),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    // Default display for regular tasks and notes
    return Text(
      description,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.gray,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
