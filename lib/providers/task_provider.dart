import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;

  List<Task> get routineTasks {
    final routine = _tasks.where((task) => task.type == TaskType.routine).toList();
    // Sort: incomplete tasks first, then completed tasks
    routine.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        return a.createdAt.compareTo(b.createdAt); // Keep original order for same completion status
      }
      return a.isCompleted ? 1 : -1; // Incomplete tasks first
    });
    return routine;
  }

  List<Task> get dailyTasks {
    final daily = _tasks.where((task) => task.type == TaskType.daily).toList();
    // Sort: incomplete tasks first, then completed tasks
    daily.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        return a.createdAt.compareTo(b.createdAt); // Keep original order for same completion status
      }
      return a.isCompleted ? 1 : -1; // Incomplete tasks first
    });
    return daily;
  }

  bool get isLoading => _isLoading;

  // Get progress for routine tasks (0.0 to 1.0)
  double get routineProgress {
    final routine = routineTasks;
    if (routine.isEmpty) return 0.0;
    final completed = routine.where((task) => task.isCompleted).length;
    return completed / routine.length;
  }

  // Get progress for daily tasks (0.0 to 1.0)
  double get dailyProgress {
    final daily = dailyTasks;
    if (daily.isEmpty) return 0.0;
    final completed = daily.where((task) => task.isCompleted).length;
    return completed / daily.length;
  }

  // Initialize and load tasks from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    await _loadTasks();
    await _cleanupExpiredTasks();
    await _resetRoutineTasks();
    
    _isLoading = false;
    notifyListeners();
  }

  // Add a new task
  Future<void> addTask(
    String title,
    TaskType type, {
    String? description,
    String? timeSlot,
    DateTime? deadline,
    List<String>? tags,
    String? backgroundColor,
  }) async {
    final task = Task(
      title: title,
      description: description,
      type: type,
      timeSlot: timeSlot,
      deadline: deadline,
      tags: tags,
      backgroundColor: backgroundColor,
    );

    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  // BRAINDUMP INTEGRATION: Add a task created from braindump processing
  // This method accepts a fully formed Task object from the braindump system
  Future<void> addTaskFromBraindump(Task task) async {
    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  // Remove a task
  Future<void> removeTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks();
    notifyListeners();
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    final now = DateTime.now();

    if (task.isCompleted) {
      // Mark as incomplete
      _tasks[taskIndex] = task.copyWith(
        isCompleted: false,
        completedAt: null,
      );
    } else {
      // Mark as complete
      _tasks[taskIndex] = task.copyWith(
        isCompleted: true,
        completedAt: now,
      );
    }

    await _saveTasks();
    notifyListeners();
  }

  // Toggle completion of a specific list item within a task
  Future<void> toggleListItemCompletion(String taskId, String listItemId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    final updatedListItems = task.listItems.map((item) {
      if (item.id == listItemId) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();

    _tasks[taskIndex] = task.copyWith(listItems: updatedListItems);

    await _saveTasks();
    notifyListeners();
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks();
    notifyListeners();
  }

  // Update an existing task
  Future<void> updateTask(Task updatedTask) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (taskIndex == -1) return;

    _tasks[taskIndex] = updatedTask;
    await _saveTasks();
    notifyListeners();
  }

  // Get task by ID
  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Add some default routine tasks (for demo)
  Future<void> addDefaultRoutineTasks() async {
    if (routineTasks.isNotEmpty) return; // Don't add if already exist
    
    await addTask('Work 9-5', TaskType.routine, timeSlot: '9:00 AM - 5:00 PM');
    await addTask('Gym 7 PM', TaskType.routine, timeSlot: '7:00 PM');
    await addTask('Read before bed', TaskType.routine, timeSlot: '10:00 PM');
  }

  // Add some default daily tasks (for demo)
  Future<void> addDefaultDailyTasks() async {
    if (dailyTasks.isNotEmpty) return; // Don't add if already exist

    await addTask('Buy groceries', TaskType.daily);
    await addTask('Call mom', TaskType.daily);
    await addTask('Email boss', TaskType.daily);
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('tasks');
      
      if (tasksJson != null) {
        final List<dynamic> tasksList = json.decode(tasksJson);
        _tasks = tasksList.map((json) => Task.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      _tasks = [];
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = json.encode(_tasks.map((task) => task.toJson()).toList());
      await prefs.setString('tasks', tasksJson);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  // Clean up expired daily tasks (24 hours after completion)
  Future<void> _cleanupExpiredTasks() async {
    final initialCount = _tasks.length;
    _tasks.removeWhere((task) => task.shouldAutoRemove());
    
    if (_tasks.length != initialCount) {
      await _saveTasks();
    }
  }

  // Reset routine tasks daily (uncheck them)
  Future<void> _resetRoutineTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString('last_routine_reset');
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    
    if (lastResetDate != todayString) {
      // Reset all routine tasks
      bool hasChanges = false;
      for (int i = 0; i < _tasks.length; i++) {
        if (_tasks[i].type == TaskType.routine && _tasks[i].isCompleted) {
          _tasks[i] = _tasks[i].copyWith(
            isCompleted: false,
            completedAt: null,
          );
          hasChanges = true;
        }
      }
      
      if (hasChanges) {
        await _saveTasks();
      }
      
      await prefs.setString('last_routine_reset', todayString);
    }
  }

  // Clear all tasks (for testing/reset)
  Future<void> clearAllTasks() async {
    _tasks.clear();
    await _saveTasks();
    notifyListeners();
  }
}
