import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';
import 'add_habit_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final TextEditingController _habitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: const Text('Habits'),
        backgroundColor: AppColors.lightBeige,
        elevation: 0,
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          return Column(
            children: [
              // Add habit section
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _habitController,
                        decoration: const InputDecoration(
                          hintText: 'Add a new habit...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addHabit(habitProvider),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddHabitScreen(),
                          ),
                        );
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),

              // Calendar header
              Container(
                color: AppColors.lightBeige,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Empty space for habit names
                    const Expanded(flex: 2, child: SizedBox()),

                    // Date headers for last 5 days
                    ...List.generate(5, (index) {
                      final date = DateTime.now().subtract(Duration(days: 4 - index));
                      final dayName = _getDayName(date.weekday);
                      final dayNumber = date.day;

                      return Expanded(
                        child: Column(
                          children: [
                            Text(
                              dayName.toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray,
                              ),
                            ),
                            Text(
                              dayNumber.toString(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Space for delete button
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Habits list
              Expanded(
                child: habitProvider.habits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.track_changes_outlined,
                              size: 64,
                              color: AppColors.gray,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No habits yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.gray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a habit to start tracking',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: habitProvider.habits.length,
                        itemBuilder: (context, index) {
                          final habit = habitProvider.habits[index];
                          return _HabitCard(
                            habit: habit,
                            onTodayToggle: (completed) {
                              habitProvider.toggleHabitCompletion(habit.id);
                            },
                            onDelete: () {
                              _showDeleteDialog(context, habitProvider, habit);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addHabit(HabitProvider habitProvider) {
    if (_habitController.text.trim().isNotEmpty) {
      habitProvider.addHabit(_habitController.text.trim(), HabitType.yesNo);
      _habitController.clear();
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  void _showDeleteDialog(BuildContext context, HabitProvider habitProvider, Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              habitProvider.removeHabit(habit.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final Function(bool) onTodayToggle;
  final VoidCallback onDelete;

  const _HabitCard({
    required this.habit,
    required this.onTodayToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Generate the last 5 days
    final dates = List.generate(5, (index) {
      return now.subtract(Duration(days: 4 - index));
    });

    // Parse background color
    Color? backgroundColor;
    if (habit.backgroundColor != null) {
      try {
        backgroundColor = Color(int.parse(habit.backgroundColor!.replaceFirst('#', '0xFF')));
      } catch (e) {
        backgroundColor = AppColors.white;
      }
    } else {
      backgroundColor = AppColors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Left side - Habit name
            Expanded(
              flex: 2,
              child: Text(
                habit.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),

            // Right side - 5-day view
            ...dates.map((date) {
              final isCompleted = habit.isCompletedOnDate(date);
              final isToday = _isSameDay(date, now);
              final isPast = date.isBefore(now) && !isToday;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Only allow interaction with today
                    if (isToday) {
                      if (habit.type == HabitType.yesNo) {
                        onTodayToggle(!isCompleted);
                      } else {
                        _showMeasurableInput(context, habit, date);
                      }
                    }
                  },
                  child: Center(
                    child: _buildCompletionIndicator(habit, date, isCompleted, isToday, isPast),
                  ),
                ),
              );
            }),

            // Delete button
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close),
                color: AppColors.gray,
                iconSize: 16,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionIndicator(Habit habit, DateTime date, bool isCompleted, bool isToday, bool isPast) {
    if (habit.type == HabitType.yesNo) {
      // For yes/no habits, show check or X
      if (isCompleted) {
        return const Icon(
          Icons.check,
          color: AppColors.teal,
          size: 20,
        );
      } else if (isPast) {
        return const Icon(
          Icons.close,
          color: AppColors.gray,
          size: 20,
        );
      } else {
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gray, width: 1),
          ),
        );
      }
    } else {
      // For measurable habits, show the number or 0
      final value = habit.getCompletionValue(date) ?? 0;
      return Text(
        value.toInt().toString(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isCompleted ? AppColors.teal : AppColors.gray,
        ),
      );
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _showMeasurableInput(BuildContext context, Habit habit, DateTime date) {
    final controller = TextEditingController();
    final currentValue = habit.getCompletionValue(date);
    if (currentValue != null) {
      controller.text = currentValue.toInt().toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(habit.title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: habit.unit != null ? 'Amount (${habit.unit})' : 'Amount',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                habitProvider.markHabitComplete(habit.id, date, value: value);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
