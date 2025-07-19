import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;

  // Initialize and load habits from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    await _loadHabits();
    
    _isLoading = false;
    notifyListeners();
  }

  // Add a new habit
  Future<void> addHabit(String title, HabitType type, {String? unit, String? backgroundColor}) async {
    final habit = Habit(
      title: title,
      type: type,
      unit: unit,
      backgroundColor: backgroundColor,
    );
    
    _habits.add(habit);
    await _saveHabits();
    notifyListeners();
  }

  // Remove a habit
  Future<void> removeHabit(String habitId) async {
    _habits.removeWhere((habit) => habit.id == habitId);
    await _saveHabits();
    notifyListeners();
  }

  // Toggle habit completion for today
  Future<void> toggleHabitCompletion(String habitId, {double? value}) async {
    final habitIndex = _habits.indexWhere((habit) => habit.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];
    final today = DateTime.now();
    
    if (habit.isCompletedOnDate(today)) {
      // Mark as incomplete
      _habits[habitIndex] = habit.markIncomplete(today);
    } else {
      // Mark as complete
      _habits[habitIndex] = habit.markCompleted(today, value: value);
    }
    
    await _saveHabits();
    notifyListeners();
  }

  // Get habit by ID
  Habit? getHabitById(String habitId) {
    try {
      return _habits.firstWhere((habit) => habit.id == habitId);
    } catch (e) {
      return null;
    }
  }

  // Check if habit is completed today
  bool isHabitCompletedToday(String habitId) {
    final habit = getHabitById(habitId);
    if (habit == null) return false;
    return habit.isCompletedOnDate(DateTime.now());
  }

  // Get completion value for today (for measurable habits)
  double? getHabitValueToday(String habitId) {
    final habit = getHabitById(habitId);
    if (habit == null) return null;
    return habit.getCompletionValue(DateTime.now());
  }

  // Get habit streak
  int getHabitStreak(String habitId) {
    final habit = getHabitById(habitId);
    if (habit == null) return 0;
    return habit.getCurrentStreak();
  }

  // Mark habit as complete for a specific date
  Future<void> markHabitComplete(String habitId, DateTime date, {double? value}) async {
    final habitIndex = _habits.indexWhere((habit) => habit.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];
    _habits[habitIndex] = habit.markCompleted(date, value: value);

    await _saveHabits();
    notifyListeners();
  }

  // Mark habit as incomplete for a specific date
  Future<void> markHabitIncomplete(String habitId, DateTime date) async {
    final habitIndex = _habits.indexWhere((habit) => habit.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];
    _habits[habitIndex] = habit.markIncomplete(date);

    await _saveHabits();
    notifyListeners();
  }

  // Load habits from SharedPreferences
  Future<void> _loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getString('habits');
      
      if (habitsJson != null) {
        final List<dynamic> habitsList = json.decode(habitsJson);
        _habits = habitsList.map((json) => Habit.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading habits: $e');
      _habits = [];
    }
  }

  // Save habits to SharedPreferences
  Future<void> _saveHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = json.encode(_habits.map((habit) => habit.toJson()).toList());
      await prefs.setString('habits', habitsJson);
    } catch (e) {
      debugPrint('Error saving habits: $e');
    }
  }

  // Clear all habits (for testing/reset)
  Future<void> clearAllHabits() async {
    _habits.clear();
    await _saveHabits();
    notifyListeners();
  }
}
