import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import 'add_habit_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {

  void showAddHabitScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddHabitScreen(),
      ),
    );
  }

  int _calculateCurrentStreak(HabitProvider habitProvider) {
    if (habitProvider.habits.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) { // Check last 30 days
      final date = now.subtract(Duration(days: i));
      final completedHabits = habitProvider.habits
          .where((habit) => habit.isCompletedOnDate(date))
          .length;

      if (completedHabits > 0) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

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
                Icons.track_changes,
                color: AppColors.teal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'My Habits',
              style: TextStyle(
                color: AppColors.darkGray,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<HabitProvider>(
            builder: (context, habitProvider, child) {
              final completedToday = habitProvider.habits
                  .where((habit) => habit.isCompletedOnDate(DateTime.now()))
                  .length;
              final totalHabits = habitProvider.habits.length;
              final streak = _calculateCurrentStreak(habitProvider);

              return Row(
                children: [
                  // Completion badge
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.teal, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$completedToday/$totalHabits',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Streak badge
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: AppColors.coral, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$streak',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.coral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          return Column(
            children: [

              // Modern calendar header
              Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Habit label
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Habits',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ),

                    // Date headers for last 5 days
                    ...List.generate(5, (index) {
                      final date = DateTime.now().subtract(Duration(days: 4 - index));
                      final dayName = _getDayName(date.weekday);
                      final dayNumber = date.day;
                      final isToday = date.day == DateTime.now().day &&
                          date.month == DateTime.now().month &&
                          date.year == DateTime.now().year;

                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.teal.withValues(alpha: 0.1) : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                dayName.toUpperCase(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isToday ? AppColors.teal : AppColors.gray,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dayNumber.toString(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isToday ? AppColors.teal : AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Space for options
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
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: habitProvider.habits.length,
                        itemBuilder: (context, index) {
                          final habit = habitProvider.habits[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ModernHabitCard(
                              habit: habit,
                              onTodayToggle: (completed) {
                                habitProvider.toggleHabitCompletion(habit.id);
                              },
                              onDelete: () {
                                _showDeleteDialog(context, habitProvider, habit);
                              },
                            ),
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


}

// Modern Habit Card with better spacing and modern aesthetics
class _ModernHabitCard extends StatelessWidget {
  final Habit habit;
  final Function(bool) onTodayToggle;
  final VoidCallback onDelete;

  const _ModernHabitCard({
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

    // Use white background for better text visibility

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
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
              title: const Text('Delete Habit'),
              content: Text('Are you sure you want to delete "${habit.title}"?'),
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
      onDismissed: (direction) {
        onDelete();
      },
      child: GestureDetector(
        onLongPress: () => _showHabitOptions(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: habit.backgroundColor != null
                ? Color(int.parse(habit.backgroundColor!.replaceFirst('#', '0xFF')))
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Left side - Habit name (more prominent)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (habit.unit != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        habit.unit!,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right side - 5-day view with modern indicators (properly aligned)
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
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _buildCompletionIndicator(habit, date, isCompleted, isToday, isPast),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showHabitOptions(BuildContext context) {
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

              // Habit title
              Text(
                habit.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),

              const SizedBox(height: 20),

              // Options
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.teal),
                title: const Text('Customize Habit Name'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Show edit name dialog
                },
              ),

              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.coral),
                title: const Text('Habit Info'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Show habit info
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove Habit'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletionIndicator(Habit habit, DateTime date, bool isCompleted, bool isToday, bool isPast) {
    // Check if this is a journal habit and has mood data
    final isJournalHabit = habit.title.toLowerCase().contains('journal');
    final dateKey = '${date.year}-${date.month}-${date.day}';
    final completionData = habit.completions[dateKey];

    if (habit.type == HabitType.yesNo) {
      // For yes/no habits, show modern circular indicators
      if (isCompleted) {
        // Show mood emoji for journal habits if available
        if (isJournalHabit && completionData != null && completionData['mood'] != null) {
          try {
            final moodName = completionData['mood'] as String;
            final mood = Mood.values.firstWhere((e) => e.name == moodName);
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            );
          } catch (e) {
            // Fallback to check icon if mood parsing fails
          }
        }

        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        );
      } else if (isPast) {
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.close,
            color: AppColors.gray,
            size: 14,
          ),
        );
      } else {
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isToday ? AppColors.teal : AppColors.gray,
              width: 2,
            ),
          ),
          child: isToday ? const Icon(
            Icons.add,
            color: AppColors.teal,
            size: 14,
          ) : null,
        );
      }
    } else {
      // For measurable habits, show the number in a modern container
      final value = habit.getCompletionValue(date) ?? 0;
      final hasValue = value > 0;

      if (hasValue) {
        // Show completed state with value
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.teal,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
              ),
            ),
          ),
        );
      } else if (isPast) {
        // Show missed state for past days
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.close,
            color: AppColors.gray,
            size: 14,
          ),
        );
      } else {
        // Show empty state for today/future (similar to yes/no habits)
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isToday ? AppColors.teal : AppColors.gray,
              width: 2,
            ),
          ),
          child: isToday ? const Icon(
            Icons.add,
            color: AppColors.teal,
            size: 14,
          ) : null,
        );
      }
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
                habitProvider.markHabitCompleteForDate(habit.id, date, value: value);
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
