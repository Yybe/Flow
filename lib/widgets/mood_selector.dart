import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../theme/app_theme.dart';

class MoodSelectorDialog extends StatefulWidget {
  const MoodSelectorDialog({super.key});

  @override
  State<MoodSelectorDialog> createState() => _MoodSelectorDialogState();
}

class _MoodSelectorDialogState extends State<MoodSelectorDialog> {
  Mood? _selectedMood;

  final List<Mood> _moods = [
    Mood.verySad,
    Mood.sad,
    Mood.neutral,
    Mood.happy,
    Mood.veryHappy,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'How are you feeling?',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select your mood for this entry',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.gray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _moods.map((mood) => _buildMoodOption(mood)).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedMood != null
                      ? () => Navigator.of(context).pop(_selectedMood)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodOption(Mood mood) {
    final isSelected = _selectedMood == mood;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected 
              ? AppColors.teal.withValues(alpha: 0.1)
              : Colors.transparent,
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
  }
}
