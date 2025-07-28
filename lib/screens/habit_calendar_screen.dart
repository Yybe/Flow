import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class HabitCalendarScreen extends StatefulWidget {
  const HabitCalendarScreen({super.key});

  @override
  State<HabitCalendarScreen> createState() => _HabitCalendarScreenState();
}

class _HabitCalendarScreenState extends State<HabitCalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  String? _selectedHabitId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: const Text('Habit Calendar'),
        backgroundColor: AppColors.lightBeige,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          if (habitProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (habitProvider.habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: AppColors.gray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No habits to track yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create some habits to see your progress here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Habit selector dropdown
              Container(
                color: AppColors.lightBeige,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Habit',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.lightGray),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _selectedHabitId,
                          hint: const Text('All Habits'),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Habits'),
                            ),
                            ...habitProvider.habits.map((habit) {
                              return DropdownMenuItem<String?>(
                                value: habit.id,
                                child: Text(
                                  habit.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              _selectedHabitId = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Month navigation
              Container(
                color: AppColors.lightBeige,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      _getMonthYearString(_currentMonth),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),

              // Calendar
              Expanded(
                child: _selectedHabitId == null
                    ? _buildAllHabitsCalendar(habitProvider.habits)
                    : _buildSingleHabitCalendar(
                        habitProvider.getHabitById(_selectedHabitId!)!,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllHabitsCalendar(List<Habit> habits) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCalendarGrid(habits),
          const SizedBox(height: 24),
          _buildHabitLegend(habits),
        ],
      ),
    );
  }

  Widget _buildSingleHabitCalendar(Habit habit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSingleHabitGrid(habit),
          const SizedBox(height: 24),
          _buildHabitStats(habit),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<Habit> habits) {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Weekday headers
            Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            
            // Calendar grid
            ...List.generate(6, (weekIndex) {
              return Row(
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex + 1 - (startingWeekday - 1);
                  
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 40));
                  }

                  final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                  final completedHabits = habits.where((habit) => habit.isCompletedOnDate(date)).length;
                  final totalHabits = habits.length;

                  return Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(1),
                      child: _buildDayCell(date, completedHabits, totalHabits),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleHabitGrid(Habit habit) {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Habit title
            Text(
              habit.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Weekday headers
            Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            
            // Calendar grid
            ...List.generate(6, (weekIndex) {
              return Row(
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex + 1 - (startingWeekday - 1);
                  
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 40));
                  }

                  final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                  final isCompleted = habit.isCompletedOnDate(date);
                  final completionValue = habit.getCompletionValue(date);

                  return Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(1),
                      child: _buildSingleHabitDayCell(date, isCompleted, completionValue, habit.type),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  Widget _buildDayCell(DateTime date, int completedHabits, int totalHabits) {
    final isToday = _isSameDay(date, DateTime.now());
    final isFuture = date.isAfter(DateTime.now()) && !isToday;

    Color backgroundColor;
    Color textColor = AppColors.black;

    if (isFuture) {
      backgroundColor = AppColors.lightGray;
      textColor = AppColors.gray;
    } else if (totalHabits == 0) {
      backgroundColor = AppColors.white;
    } else {
      final completionRatio = completedHabits / totalHabits;
      if (completionRatio == 1.0) {
        backgroundColor = AppColors.teal;
        textColor = AppColors.white;
      } else if (completionRatio >= 0.5) {
        backgroundColor = AppColors.teal.withValues(alpha: 0.5);
      } else if (completionRatio > 0) {
        backgroundColor = AppColors.teal.withValues(alpha: 0.2);
      } else {
        backgroundColor = AppColors.white;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: AppColors.coral, width: 2) : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (totalHabits > 0 && !isFuture)
              Text(
                '$completedHabits/$totalHabits',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontSize: 8,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleHabitDayCell(DateTime date, bool isCompleted, double? completionValue, HabitType habitType) {
    final isToday = _isSameDay(date, DateTime.now());
    final isFuture = date.isAfter(DateTime.now()) && !isToday;

    Color backgroundColor;
    Color textColor = AppColors.black;

    if (isFuture) {
      backgroundColor = AppColors.lightGray;
      textColor = AppColors.gray;
    } else if (isCompleted) {
      backgroundColor = AppColors.teal;
      textColor = AppColors.white;
    } else {
      backgroundColor = AppColors.white;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: AppColors.coral, width: 2) : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isCompleted && habitType == HabitType.measurable && completionValue != null)
              Text(
                completionValue.toStringAsFixed(completionValue == completionValue.toInt() ? 0 : 1),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontSize: 8,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitLegend(List<Habit> habits) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLegendItem(AppColors.teal, 'All habits completed'),
                const SizedBox(width: 16),
                _buildLegendItem(AppColors.teal.withValues(alpha: 0.5), 'Most habits completed'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLegendItem(AppColors.teal.withValues(alpha: 0.2), 'Some habits completed'),
                const SizedBox(width: 16),
                _buildLegendItem(AppColors.white, 'No habits completed'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.coral, width: 2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Today'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildHabitStats(Habit habit) {
    final currentStreak = habit.getCurrentStreak();
    final thisMonthCompletions = _getMonthCompletions(habit, _currentMonth);
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final completionRate = thisMonthCompletions / daysInMonth;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Current Streak', '$currentStreak days'),
                ),
                Expanded(
                  child: _buildStatItem('This Month', '$thisMonthCompletions/$daysInMonth days'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Completion Rate', '${(completionRate * 100).toStringAsFixed(1)}%'),
                ),
                Expanded(
                  child: _buildStatItem('Habit Type', habit.type == HabitType.yesNo ? 'Yes/No' : 'Measurable'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.gray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  int _getMonthCompletions(Habit habit, DateTime month) {
    int completions = 0;
    final daysInMonth = _getDaysInMonth(month);

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      if (habit.isCompletedOnDate(date)) {
        completions++;
      }
    }

    return completions;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
