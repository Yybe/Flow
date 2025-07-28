import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/journal_entry.dart';

class JournalProvider extends ChangeNotifier {
  List<JournalEntry> _entries = [];
  bool _isLoading = false;

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  // Get entries for today
  List<JournalEntry> get todayEntries {
    final today = DateTime.now();
    return _entries.where((entry) {
      return entry.createdAt.year == today.year &&
             entry.createdAt.month == today.month &&
             entry.createdAt.day == today.day;
    }).toList();
  }

  // Check if user has journaled today
  bool get hasJournaledToday => todayEntries.isNotEmpty;

  // Get total word count for today
  int get todayWordCount {
    return todayEntries.fold(0, (sum, entry) => sum + entry.wordCount);
  }

  // Get total entries this year
  int get entriesThisYear {
    final currentYear = DateTime.now().year;
    return _entries.where((entry) => entry.createdAt.year == currentYear).length;
  }

  // Get total words written this year
  int get wordsThisYear {
    final currentYear = DateTime.now().year;
    return _entries
        .where((entry) => entry.createdAt.year == currentYear)
        .fold(0, (sum, entry) => sum + entry.wordCount);
  }

  // Get days journaled this year
  int get daysJournaledThisYear {
    final currentYear = DateTime.now().year;
    final dates = _entries
        .where((entry) => entry.createdAt.year == currentYear)
        .map((entry) => '${entry.createdAt.year}-${entry.createdAt.month}-${entry.createdAt.day}')
        .toSet();
    return dates.length;
  }

  // Initialize and load entries from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    await _loadEntries();
    
    _isLoading = false;
    notifyListeners();
  }

  // Add a new journal entry
  Future<void> addEntry(String content, {Mood? mood}) async {
    final today = DateTime.now();

    // Check if there's already an entry for today
    final todayEntry = _entries.where((entry) {
      return entry.createdAt.year == today.year &&
             entry.createdAt.month == today.month &&
             entry.createdAt.day == today.day;
    }).firstOrNull;

    if (todayEntry != null) {
      // Append to existing entry as continuation
      final updatedContent = '${todayEntry.content}\n\n--- Continuation ---\n\n$content';
      final updatedEntry = todayEntry.copyWith(
        content: updatedContent,
        mood: mood ?? todayEntry.mood, // Keep existing mood if no new mood
        updatedAt: DateTime.now(),
      );

      // Replace the existing entry
      final index = _entries.indexWhere((entry) => entry.id == todayEntry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
      }
    } else {
      // Create new entry
      final entry = JournalEntry(
        content: content,
        mood: mood,
      );
      _entries.insert(0, entry); // Add to beginning for chronological order
    }

    await _saveEntries();
    notifyListeners();
  }

  // Update an existing entry
  Future<void> updateEntry(String entryId, String content, {Mood? mood}) async {
    final index = _entries.indexWhere((entry) => entry.id == entryId);
    if (index == -1) return;

    _entries[index] = _entries[index].copyWith(
      content: content,
      mood: mood,
      updatedAt: DateTime.now(),
    );
    
    await _saveEntries();
    notifyListeners();
  }

  // Delete an entry
  Future<void> deleteEntry(String entryId) async {
    _entries.removeWhere((entry) => entry.id == entryId);
    await _saveEntries();
    notifyListeners();
  }

  // Get entry by ID
  JournalEntry? getEntryById(String entryId) {
    try {
      return _entries.firstWhere((entry) => entry.id == entryId);
    } catch (e) {
      return null;
    }
  }

  // Get mood statistics for a date range
  Map<Mood, int> getMoodStats({DateTime? startDate, DateTime? endDate}) {
    final filteredEntries = _entries.where((entry) {
      if (startDate != null && entry.createdAt.isBefore(startDate)) return false;
      if (endDate != null && entry.createdAt.isAfter(endDate)) return false;
      return entry.mood != null;
    });

    final moodCounts = <Mood, int>{};
    for (final mood in Mood.values) {
      moodCounts[mood] = 0;
    }

    for (final entry in filteredEntries) {
      if (entry.mood != null) {
        moodCounts[entry.mood!] = (moodCounts[entry.mood!] ?? 0) + 1;
      }
    }

    return moodCounts;
  }

  // Load entries from SharedPreferences
  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getString('journal_entries');
      
      if (entriesJson != null) {
        final List<dynamic> entriesList = json.decode(entriesJson);
        _entries = entriesList.map((json) => JournalEntry.fromJson(json)).toList();
        
        // Sort by creation date (newest first)
        _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      debugPrint('Error loading journal entries: $e');
      _entries = [];
    }
  }

  // Save entries to SharedPreferences
  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = json.encode(_entries.map((entry) => entry.toJson()).toList());
      await prefs.setString('journal_entries', entriesJson);
    } catch (e) {
      debugPrint('Error saving journal entries: $e');
    }
  }
}
