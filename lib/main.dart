import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_navigation.dart';
import 'providers/habit_provider.dart';
import 'providers/task_provider.dart';
import 'providers/journal_provider.dart';
import 'models/habit.dart';

void main() {
  runApp(const ProductivityApp());
}

class ProductivityApp extends StatelessWidget {
  const ProductivityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
      ],
      child: MaterialApp(
        title: 'Productivity App',
        theme: AppTheme.cozyTheme,
        home: const AppInitializer(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);

    await Future.wait([
      habitProvider.initialize(),
      taskProvider.initialize(),
      journalProvider.initialize(),
    ]);

    // Add default data if empty (for demo purposes)
    if (habitProvider.habits.isEmpty) {
      await habitProvider.addHabit('Daily Journaling', HabitType.yesNo);
      await habitProvider.addHabit('Exercise', HabitType.yesNo);
      await habitProvider.addHabit('Read 50 pages', HabitType.measurable, unit: 'pages');
      await habitProvider.addHabit('Meditate', HabitType.yesNo);
    } else {
      // Ensure journal habit exists
      final hasJournalHabit = habitProvider.habits
          .any((habit) => habit.title.toLowerCase().contains('journal'));
      if (!hasJournalHabit) {
        await habitProvider.addHabit('Daily Journaling', HabitType.yesNo);
      }
    }

    if (taskProvider.tasks.isEmpty) {
      await taskProvider.addDefaultRoutineTasks();
      await taskProvider.addDefaultDailyTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<HabitProvider, TaskProvider, JournalProvider>(
      builder: (context, habitProvider, taskProvider, journalProvider, child) {
        if (habitProvider.isLoading || taskProvider.isLoading || journalProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return const HomeNavigation();
      },
    );
  }
}


