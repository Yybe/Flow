import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  HabitType _selectedType = HabitType.yesNo;
  String? _selectedColor;

  // Simple color options that work well with the light theme
  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Default', 'color': null, 'displayColor': AppColors.white},
    {'name': 'Light Blue', 'color': '#E3F2FD', 'displayColor': const Color(0xFFE3F2FD)},
    {'name': 'Light Green', 'color': '#E8F5E8', 'displayColor': const Color(0xFFE8F5E8)},
    {'name': 'Light Orange', 'color': '#FFF3E0', 'displayColor': const Color(0xFFFFF3E0)},
    {'name': 'Light Purple', 'color': '#F3E5F5', 'displayColor': const Color(0xFFF3E5F5)},
    {'name': 'Light Pink', 'color': '#FCE4EC', 'displayColor': const Color(0xFFFCE4EC)},
    {'name': 'Light Yellow', 'color': '#FFFDE7', 'displayColor': const Color(0xFFFFFDE7)},
    {'name': 'Light Teal', 'color': '#E0F2F1', 'displayColor': const Color(0xFFE0F2F1)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      appBar: AppBar(
        title: const Text('New Habit'),
        backgroundColor: AppColors.lightBeige,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _canSave() ? _saveHabit : null,
            child: Text(
              'Save',
              style: TextStyle(
                color: _canSave() ? AppColors.teal : AppColors.gray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit name input
            _buildSectionTitle('Habit Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g., Exercise, Read, Meditate',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 24),

            // Habit type selection
            _buildSectionTitle('Habit Type'),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildTypeOption(
                    type: HabitType.yesNo,
                    title: 'Yes/No',
                    description: 'Track completion',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeOption(
                    type: HabitType.measurable,
                    title: 'Measurable',
                    description: 'Track with numbers',
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),

            // Unit input for measurable habits
            if (_selectedType == HabitType.measurable) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Unit (Optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _unitController,
                decoration: const InputDecoration(
                  hintText: 'e.g., pages, minutes, miles',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Color selection
            _buildSectionTitle('Background Color'),
            const SizedBox(height: 12),
            _buildColorPicker(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildTypeOption({
    required HabitType type,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.teal : AppColors.lightGray,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.teal : AppColors.gray,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.teal : AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colorOptions.map((colorOption) {
        final isSelected = _selectedColor == colorOption['color'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = colorOption['color'];
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorOption['displayColor'],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.teal : AppColors.lightGray,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: AppColors.teal, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  bool _canSave() {
    return _nameController.text.trim().isNotEmpty;
  }

  void _saveHabit() {
    if (!_canSave()) return;

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    
    habitProvider.addHabit(
      _nameController.text.trim(),
      _selectedType,
      unit: _selectedType == HabitType.measurable && _unitController.text.trim().isNotEmpty
          ? _unitController.text.trim()
          : null,
      backgroundColor: _selectedColor,
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
