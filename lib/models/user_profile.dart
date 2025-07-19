enum MoodType { happy, neutral, sad }

enum MoodTime { wakeUp, day, sleep }

class MoodEntry {
  final MoodType mood;
  final MoodTime time;
  final DateTime timestamp;

  MoodEntry({
    required this.mood,
    required this.time,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'mood': mood.name,
      'time': time.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      mood: MoodType.values.firstWhere((e) => e.name == json['mood']),
      time: MoodTime.values.firstWhere((e) => e.name == json['time']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class UserProfile {
  final String name;
  final String status; // e.g., "Student", "Working", etc.
  final List<String> hobbies;
  final bool hibernationMode;
  final String selectedTheme; // e.g., "light", "dark", "cozy"
  final Map<String, List<MoodEntry>> moodEntries; // Date string -> List of mood entries
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.name,
    required this.status,
    List<String>? hobbies,
    this.hibernationMode = false,
    this.selectedTheme = 'cozy',
    Map<String, List<MoodEntry>>? moodEntries,
    DateTime? createdAt,
    this.updatedAt,
  })  : hobbies = hobbies ?? [],
        moodEntries = moodEntries ?? {},
        createdAt = createdAt ?? DateTime.now();

  UserProfile copyWith({
    String? name,
    String? status,
    List<String>? hobbies,
    bool? hibernationMode,
    String? selectedTheme,
    Map<String, List<MoodEntry>>? moodEntries,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      name: name ?? this.name,
      status: status ?? this.status,
      hobbies: hobbies ?? List.from(this.hobbies),
      hibernationMode: hibernationMode ?? this.hibernationMode,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      moodEntries: moodEntries ?? Map.from(this.moodEntries),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Add mood entry for a specific date
  UserProfile addMoodEntry(DateTime date, MoodEntry entry) {
    final dateKey = _dateToKey(date);
    final newMoodEntries = Map<String, List<MoodEntry>>.from(moodEntries);
    
    if (!newMoodEntries.containsKey(dateKey)) {
      newMoodEntries[dateKey] = [];
    }
    
    // Remove existing entry for the same time if it exists
    newMoodEntries[dateKey]!.removeWhere((e) => e.time == entry.time);
    newMoodEntries[dateKey]!.add(entry);
    
    return copyWith(
      moodEntries: newMoodEntries,
      updatedAt: DateTime.now(),
    );
  }

  // Get mood entries for a specific date
  List<MoodEntry> getMoodEntriesForDate(DateTime date) {
    final dateKey = _dateToKey(date);
    return moodEntries[dateKey] ?? [];
  }

  // Get mood entry for a specific date and time
  MoodEntry? getMoodEntry(DateTime date, MoodTime time) {
    final entries = getMoodEntriesForDate(date);
    try {
      return entries.firstWhere((e) => e.time == time);
    } catch (e) {
      return null;
    }
  }

  // Toggle hibernation mode
  UserProfile toggleHibernation() {
    return copyWith(
      hibernationMode: !hibernationMode,
      updatedAt: DateTime.now(),
    );
  }

  // Update profile info
  UserProfile updateProfile({
    String? name,
    String? status,
    List<String>? hobbies,
  }) {
    return copyWith(
      name: name ?? this.name,
      status: status ?? this.status,
      hobbies: hobbies ?? this.hobbies,
      updatedAt: DateTime.now(),
    );
  }

  // Change theme
  UserProfile changeTheme(String theme) {
    return copyWith(
      selectedTheme: theme,
      updatedAt: DateTime.now(),
    );
  }

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    final moodEntriesJson = <String, dynamic>{};
    moodEntries.forEach((key, value) {
      moodEntriesJson[key] = value.map((e) => e.toJson()).toList();
    });

    return {
      'name': name,
      'status': status,
      'hobbies': hobbies,
      'hibernationMode': hibernationMode,
      'selectedTheme': selectedTheme,
      'moodEntries': moodEntriesJson,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final moodEntriesJson = json['moodEntries'] as Map<String, dynamic>? ?? {};
    final moodEntries = <String, List<MoodEntry>>{};
    
    moodEntriesJson.forEach((key, value) {
      moodEntries[key] = (value as List)
          .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    });

    return UserProfile(
      name: json['name'],
      status: json['status'],
      hobbies: List<String>.from(json['hobbies'] ?? []),
      hibernationMode: json['hibernationMode'] ?? false,
      selectedTheme: json['selectedTheme'] ?? 'cozy',
      moodEntries: moodEntries,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
}
