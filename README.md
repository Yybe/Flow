# Flow

A beautiful and intuitive productivity app built with Flutter that helps you manage your habits, tasks, and daily reflections.

## Features

### 🎯 Habits
- **Yes/No Habits**: Track simple completion-based habits
- **Measurable Habits**: Track habits with specific numbers (pages read, miles run, etc.)
- **Calendar View**: See your progress over the last 5 days
- **Custom Colors**: Personalize each habit with background colors
- **Streak Tracking**: Monitor your current streaks

### ✅ Tasks
- **Task Management**: Create, edit, and organize your daily tasks
- **Time Tracking**: Set estimated time and track actual time spent
- **Priority Levels**: Organize tasks by importance
- **Custom Colors**: Color-code your tasks for better organization
- **Progress Tracking**: Visual progress indicators

### 📝 Journal
- **Daily Reflections**: Capture your thoughts and experiences
- **Mood Tracking**: Track your daily mood with visual indicators
- **Rich Text**: Write detailed entries with formatting support

## Design Philosophy

Flow embraces a **cozy, warm design** with:
- Soft beige and cream color palette
- Clean, minimalist interface
- Intuitive navigation
- Consistent visual language
- Focus on user experience

## Technology Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Fonts**: Google Fonts (Inter)
- **Platform**: Android & iOS

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Yybe/Flow.git
cd Flow
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── models/          # Data models (Habit, Task, etc.)
├── providers/       # State management with Provider
├── screens/         # UI screens and pages
├── theme/          # App theme and styling
├── widgets/        # Reusable UI components
└── main.dart       # App entry point
```

## Contributing

We welcome contributions! Please feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Roadmap

- [ ] Cloud synchronization
- [ ] Advanced analytics
- [ ] Widget support
- [ ] Dark theme
- [ ] Export/import functionality
- [ ] Reminder notifications

---

Built with ❤️ using Flutter
