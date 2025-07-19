import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'create_task_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: const Text('Today'),
        backgroundColor: AppColors.lightBeige,
        elevation: 0,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                  onAddTask: () => _showAddTaskDialog(context, TaskType.routine),
                ),

                const SizedBox(height: 24),

                // Daily Tasks Section
                _TaskSection(
                  title: 'Daily Tasks',
                  color: AppColors.coral,
                  tasks: taskProvider.dailyTasks,
                  progress: taskProvider.dailyProgress,
                  onTaskToggle: (taskId) => taskProvider.toggleTaskCompletion(taskId),
                  onAddTask: () => _showAddTaskDialog(context, TaskType.daily),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context, TaskType.daily);
        },
        child: const Icon(Icons.add),
      ),
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
}

class _TaskSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<Task> tasks;
  final double progress;
  final Function(String) onTaskToggle;
  final VoidCallback onAddTask;

  const _TaskSection({
    required this.title,
    required this.color,
    required this.tasks,
    required this.progress,
    required this.onTaskToggle,
    required this.onAddTask,
  });

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

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((task) => task.isCompleted).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title with add button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: onAddTask,
                  icon: const Icon(Icons.add),
                  color: color,
                  iconSize: 20,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Task list or empty state
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.task_outlined,
                        size: 48,
                        color: AppColors.gray,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No ${title.toLowerCase()} yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap + to add a task',
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: task.backgroundColor != null
                          ? _hexToColor(task.backgroundColor!)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(task.backgroundColor != null ? 8 : 0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) => onTaskToggle(task.id),
                            activeColor: color,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Task title
                                Text(
                                  task.title,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: task.isCompleted
                                        ? AppColors.gray
                                        : AppColors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                // Description
                                if (task.description != null && task.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      task.description!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.gray,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                // Time slot and deadline
                                if (task.timeSlot != null || task.deadline != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        if (task.timeSlot != null) ...[
                                          Icon(Icons.schedule, size: 14, color: AppColors.gray),
                                          const SizedBox(width: 4),
                                          Text(
                                            task.timeSlot!,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.gray,
                                            ),
                                          ),
                                        ],
                                        if (task.timeSlot != null && task.deadline != null)
                                          Text(' • ', style: TextStyle(color: AppColors.gray)),
                                        if (task.deadline != null) ...[
                                          Icon(Icons.access_time, size: 14, color: AppColors.gray),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDeadline(task.deadline!),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.gray,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                // Tags
                                if (task.tags.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: task.tags.map((tag) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
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
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

            if (tasks.isNotEmpty) ...[
              const SizedBox(height: 16),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '$completedCount/${tasks.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.lightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
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
