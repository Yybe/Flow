import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_cta_button.dart';
import '../providers/journal_provider.dart';
import '../models/task.dart';
import 'main_screen.dart';
import 'habits_screen.dart';
import 'journal_screen.dart';
import 'profile_screen.dart';
import 'add_habit_screen.dart';
import 'create_task_screen.dart';
import 'journal_writing_screen.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MainScreen(),
    const HabitsScreen(),
    const JournalScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Today',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.track_changes_outlined),
      activeIcon: Icon(Icons.track_changes),
      label: 'Habits',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.book_outlined),
      activeIcon: Icon(Icons.book),
      label: 'Journal',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  CTAType _getCTAType() {
    switch (_currentIndex) {
      case 0:
        return CTAType.tasks;
      case 1:
        return CTAType.habits;
      case 2:
        return CTAType.journal;
      default:
        return CTAType.tasks;
    }
  }

  void _handleCTAPress() {
    switch (_currentIndex) {
      case 0:
        // Tasks screen - show task type selector
        _showTaskTypeSelector();
        break;
      case 1:
        // Habits screen - navigate to add habit
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddHabitScreen(),
          ),
        );
        break;
      case 2:
        // Journal screen - navigate to journal writing
        _showJournalWritingScreen();
        break;
    }
  }

  void _showTaskTypeSelector() {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateTaskScreen(taskType: TaskType.routine),
                    ),
                  );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateTaskScreen(taskType: TaskType.daily),
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

  void _showJournalWritingScreen() {
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    // Check if there's already an entry for today
    final todayEntry = journalProvider.todayEntries.isNotEmpty
        ? journalProvider.todayEntries.first
        : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalWritingScreen(existingEntry: todayEntry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.teal,
          unselectedItemColor: AppColors.gray,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: _navigationItems,
        ),
      ),
      floatingActionButton: _currentIndex < 3 ? AnimatedCTAButton(
        type: _getCTAType(),
        onPressed: _handleCTAPress,
        heroTag: "home_navigation_fab",
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
