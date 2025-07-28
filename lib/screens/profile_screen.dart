import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/habit_provider.dart';
import '../utils/sample_data.dart';
import 'habit_calendar_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hibernationMode = false;
  String _selectedTheme = 'Cozy';
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.darkGray,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.lightBeige,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Progress Tracking section
            Text(
              'Progress Tracking',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 16),

            // Habit calendar
            _CalendarCard(
              title: 'Habit Calendar',
              subtitle: 'Track your daily habits',
              icon: Icons.check_circle_outline,
              color: AppColors.teal,
            ),

            const SizedBox(height: 12),

            // Mood calendar
            _CalendarCard(
              title: 'Mood Calendar',
              subtitle: 'Track your daily moods',
              icon: Icons.mood,
              color: AppColors.coral,
            ),

            const SizedBox(height: 24),

            // Settings section
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 16),

            // Settings cards
            _SettingsCard(
              title: 'Theme',
              subtitle: _selectedTheme,
              icon: Icons.palette_outlined,
              onTap: _showThemeSelector,
            ),

            const SizedBox(height: 12),

            _SettingsCard(
              title: 'Hibernation Mode',
              subtitle: _hibernationMode ? 'Active - All tracking paused' : 'Inactive',
              icon: Icons.pause_circle_outline,
              trailing: Switch(
                value: _hibernationMode,
                onChanged: (value) {
                  setState(() {
                    _hibernationMode = value;
                  });
                },
                activeColor: AppColors.coral,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _SettingsCard(
              title: 'Routine Tasks',
              subtitle: 'Manage your daily routine',
              icon: Icons.schedule,
              onTap: () {
                // TODO: Navigate to routine management
              },
            ),
            
            const SizedBox(height: 12),
            
            _SettingsCard(
              title: 'Edit Profile',
              subtitle: 'Update your information',
              icon: Icons.person_outline,
              onTap: () {
                // TODO: Navigate to profile edit
              },
            ),

            const SizedBox(height: 12),

            // Debug section - Add sample data
            _SettingsCard(
              title: 'Add Sample Habits',
              subtitle: 'For testing the calendar view',
              icon: Icons.science,
              onTap: () async {
                final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                final messenger = ScaffoldMessenger.of(context);
                await SampleDataHelper.addSampleHabits(habitProvider);
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Sample habits added!')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Cozy', 'Light', 'Dark'].map((theme) {
            return RadioListTile<String>(
              title: Text(theme),
              value: theme,
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.pop(context);
              },
              activeColor: AppColors.teal,
            );
          }).toList(),
        ),
      ),
    );
  }
}



class _CalendarCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _CalendarCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Habit Calendar') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HabitCalendarScreen(),
            ),
          );
        }
        // TODO: Navigate to mood calendar view for mood calendar
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.gray,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.darkGray,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? (onTap != null
                ? Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.gray,
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
