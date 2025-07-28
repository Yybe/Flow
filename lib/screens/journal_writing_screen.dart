import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../providers/habit_provider.dart';
import '../models/journal_entry.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../widgets/mood_selector.dart';

class JournalWritingScreen extends StatefulWidget {
  final JournalEntry? existingEntry;

  const JournalWritingScreen({super.key, this.existingEntry});

  @override
  State<JournalWritingScreen> createState() => _JournalWritingScreenState();
}

class _JournalWritingScreenState extends State<JournalWritingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late DateTime _startTime;
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _currentTime = DateTime.now();

    // Update time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    // If editing existing entry, populate the content
    if (widget.existingEntry != null) {
      final content = widget.existingEntry!.content;

      // Check if content has a title (first line followed by empty line)
      final lines = content.split('\n');
      if (lines.length > 2 && lines[1].trim().isEmpty) {
        _titleController.text = lines[0];
        _contentController.text = lines.skip(2).join('\n');
      } else {
        _contentController.text = content;
      }
    }
  }

  int get _currentWordCount {
    if (_contentController.text.trim().isEmpty) return 0;
    return _contentController.text.trim().split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige, // Use app's existing background color
      resizeToAvoidBottomInset: true, // Properly handle keyboard
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar - clean and minimal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Back button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: AppColors.darkGray, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  // Menu button (optional)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz,
                          color: AppColors.darkGray, size: 20),
                      onPressed: () {}, // Could add options menu
                    ),
                  ),
                ],
              ),
            ),

            // Main content area - simple and clean
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: "Title",
                        hintStyle: TextStyle(
                          color: AppColors.gray.withValues(alpha: 0.6),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                      onChanged: (text) => setState(() {}),
                    ),

                    const SizedBox(height: 20),

                    // Main writing area
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'Start writing...',
                          hintStyle: TextStyle(
                            color: AppColors.gray.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppColors.black,
                        ),
                        onChanged: (text) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom save button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: _currentWordCount > 0 ? _saveEntry : null,
                    backgroundColor: AppColors.teal,
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEntry() async {
    if (_contentController.text.trim().isEmpty) return;

    // Show mood selector dialog
    final mood = await showDialog<Mood>(
      context: context,
      builder: (context) => const MoodSelectorDialog(),
    );

    if (mood != null && mounted) {
      // Save the entry
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);

      // Create content with title if provided
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();
      final fullContent = title.isNotEmpty ? '$title\n\n$content' : content;

      // Check if this is the first entry of the day (for celebration)
      final isFirstEntryOfDay = widget.existingEntry == null && !journalProvider.hasJournaledToday;

      // Update existing entry or create new one
      if (widget.existingEntry != null) {
        await journalProvider.updateEntry(widget.existingEntry!.id, fullContent, mood: mood);
      } else {
        await journalProvider.addEntry(fullContent, mood: mood);
      }

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

      // Mark journal habit as complete for today with mood
      if (journalHabit != null) {
        final today = DateTime.now();
        final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        await habitProvider.markHabitComplete(journalHabit.id, dateKey, true, mood: mood);
      }

      // Show celebration dialog only for first entry of the day
      if (mounted && isFirstEntryOfDay) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _JournalCelebrationDialog(mood: mood),
        );
      } else {
        // Just go back if not first entry
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

class _JournalCelebrationDialog extends StatefulWidget {
  final Mood mood;

  const _JournalCelebrationDialog({required this.mood});

  @override
  State<_JournalCelebrationDialog> createState() => _JournalCelebrationDialogState();
}

class _JournalCelebrationDialogState extends State<_JournalCelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showCheckbox = false;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Show checkbox after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showCheckbox = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated celebration emoji
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '🎉',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Celebration text
          Text(
            'Yayyyy! 🎊',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.teal,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Nice! You completed today\'s journal entry',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),

          const SizedBox(height: 16),

          // Mood display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.mood.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  'Feeling ${widget.mood.label}',
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Achievement checkbox
          AnimatedOpacity(
            opacity: _showCheckbox ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isChecked = !_isChecked;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _isChecked ? AppColors.teal : Colors.transparent,
                        border: Border.all(
                          color: AppColors.teal,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _isChecked
                          ? const Icon(
                              Icons.check,
                              color: AppColors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Check journal entry as achievement',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(); // Close writing screen
          },
          child: const Text(
            'Continue',
            style: TextStyle(
              color: AppColors.teal,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
