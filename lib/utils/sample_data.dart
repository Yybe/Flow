import '../models/habit.dart';
import '../providers/habit_provider.dart';

class SampleDataHelper {
  static Future<void> addSampleHabits(HabitProvider habitProvider) async {
    // Only add habits that don't already exist
    if (!habitProvider.habits.any((h) => h.title == 'Morning Exercise')) {
      await habitProvider.addHabit('Morning Exercise', HabitType.yesNo, backgroundColor: '#4A9B8E');
    }
    if (!habitProvider.habits.any((h) => h.title == 'Read Books')) {
      await habitProvider.addHabit('Read Books', HabitType.measurable, unit: 'pages', backgroundColor: '#FF6B6B');
    }
    if (!habitProvider.habits.any((h) => h.title == 'Drink Water')) {
      await habitProvider.addHabit('Drink Water', HabitType.measurable, unit: 'glasses', backgroundColor: '#7BC4B8');
    }
    if (!habitProvider.habits.any((h) => h.title == 'Meditation')) {
      await habitProvider.addHabit('Meditation', HabitType.yesNo, backgroundColor: '#FF9999');
    }
    if (!habitProvider.habits.any((h) => h.title == 'Journal Writing')) {
      await habitProvider.addHabit('Journal Writing', HabitType.yesNo, backgroundColor: '#4CAF50');
    }

    // Add some sample completions for the past few days using the provider methods
    final now = DateTime.now();

    for (final habit in habitProvider.habits) {
      for (int i = 1; i <= 10; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        // Simulate some realistic completion patterns
        bool shouldComplete = false;
        double? value;

        switch (habit.title) {
          case 'Morning Exercise':
            shouldComplete = i % 3 != 0; // Complete 2 out of 3 days
            break;
          case 'Read Books':
            shouldComplete = i % 2 == 0; // Complete every other day
            value = shouldComplete ? (10 + (i % 5) * 5).toDouble() : null; // 10-30 pages
            break;
          case 'Drink Water':
            shouldComplete = i <= 7; // Complete last 7 days
            value = shouldComplete ? (6 + (i % 3)).toDouble() : null; // 6-8 glasses
            break;
          case 'Meditation':
            shouldComplete = i % 4 != 0; // Complete 3 out of 4 days
            break;
          case 'Journal Writing':
            shouldComplete = i % 5 != 0; // Complete 4 out of 5 days
            break;
        }

        if (shouldComplete) {
          await habitProvider.markHabitComplete(habit.id, dateKey, true, value: value);
        }
      }
    }
  }
}
