import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hibernationMode = false;
  String _selectedTheme = 'Cozy';
  
  // Mock user data
  final Map<String, dynamic> _userProfile = {
    'name': 'Alex Johnson',
    'status': 'Student',
    'hobbies': ['Reading', 'Coding', 'Photography'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.lightBeige,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            _ProfileCard(
              name: _userProfile['name'],
              status: _userProfile['status'],
              hobbies: List<String>.from(_userProfile['hobbies']),
            ),
            
            const SizedBox(height: 24),
            
            // Calendars section
            Text(
              'Progress Tracking',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
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
                fontWeight: FontWeight.bold,
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

class _ProfileCard extends StatelessWidget {
  final String name;
  final String status;
  final List<String> hobbies;

  const _ProfileCard({
    required this.name,
    required this.status,
    required this.hobbies,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.teal,
              child: Text(
                name.split(' ').map((n) => n[0]).join(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Name
            Text(
              name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Status
            Text(
              status,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.gray,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Hobbies
            Wrap(
              spacing: 8,
              children: hobbies.map((hobby) {
                return Chip(
                  label: Text(hobby),
                  backgroundColor: AppColors.lightBeige,
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                );
              }).toList(),
            ),
          ],
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
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navigate to calendar view
        },
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
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.gray, size: 24),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing ?? (onTap != null 
            ? const Icon(Icons.arrow_forward_ios, size: 16) 
            : null),
        onTap: onTap,
      ),
    );
  }
}
