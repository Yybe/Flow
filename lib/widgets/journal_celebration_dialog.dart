import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/journal_entry.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

class JournalCelebrationDialog extends StatefulWidget {
  final int wordCount;
  final VoidCallback onComplete;

  const JournalCelebrationDialog({
    super.key,
    required this.wordCount,
    required this.onComplete,
  });

  @override
  State<JournalCelebrationDialog> createState() => _JournalCelebrationDialogState();
}

class _JournalCelebrationDialogState extends State<JournalCelebrationDialog>
    with TickerProviderStateMixin {
  Mood? _selectedMood;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Celebration icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.celebration,
                        size: 40,
                        color: AppColors.teal,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Congratulations text
                    Text(
                      'Yay! 🎉',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'You completed today\'s journal entry!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${widget.wordCount} words written',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Mood selection
                    Text(
                      'How are you feeling?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mood options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: Mood.values.map((mood) {
                        final isSelected = _selectedMood == mood;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMood = mood;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.teal.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected ? AppColors.teal : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                mood.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 8),

                    // Mood labels
                    if (_selectedMood != null)
                      Text(
                        _selectedMood!.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              _completeJournal();
                            },
                            child: const Text('Skip'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selectedMood != null ? _completeJournal : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Complete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _completeJournal() async {
    // Mark journal habit as complete for today
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    
    // Find or create journal habit
    Habit? journalHabit = habitProvider.habits
        .where((habit) => habit.title.toLowerCase().contains('journal'))
        .firstOrNull;
    
    if (journalHabit == null) {
      // Create journal habit if it doesn't exist
      await habitProvider.addHabit('Daily Journaling', HabitType.yesNo);
      journalHabit = habitProvider.habits
          .where((habit) => habit.title.toLowerCase().contains('journal'))
          .firstOrNull;
    }

    if (journalHabit != null) {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month}-${today.day}';
      
      await habitProvider.markHabitComplete(
        journalHabit.id,
        dateKey,
        true,
        mood: _selectedMood,
      );
    }

    if (mounted) {
      Navigator.of(context).pop(_selectedMood);
      widget.onComplete();
    }
  }
}
