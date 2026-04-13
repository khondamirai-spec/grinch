# StudyFlow - Student Task Manager

A Flutter web app for students to manage daily tasks linked to study materials.

## Features

- **Daily Task Management**: Create, complete, edit, and delete tasks organized by day
- **Study Library**: Upload and manage PDFs, audio, video, images, links, and notes
- **Resource Linking**: Link tasks to library resources with one-tap access
- **Visual Organization**: Filter resources by type with color-coded icons
- **Progress Tracking**: View stats on tasks done, resources, and daily streak
- **Dark Theme**: Polished, student-friendly dark UI
- **Offline-First**: All data persists in browser via Hive/IndexedDB

## Tech Stack

- **Framework**: Flutter Web
- **State Management**: Riverpod 2.x
- **Local Storage**: Hive
- **Audio**: just_audio
- **Routing**: go_router
- **Design**: Custom dark theme with Google Fonts (Inter)

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running Locally

```bash
flutter run -d chrome
```

### Building for Web

```bash
flutter config --enable-web
flutter build web --release --web-renderer canvaskit
```

Output will be in `build/web/`

## Deployment

### Vercel Deploy

1. Push to GitHub
2. Import to Vercel
3. Configure build:
   - **Build Command**: `flutter build web --release --web-renderer canvaskit`
   - **Output Directory**: `build/web`
   - **Install Command**: `flutter pub get`

Or use the included `vercel.json` for static deployment.

## Project Structure

```
lib/
├── main.dart                     # App entry point + Hive init
├── app.dart                      # MaterialApp + GoRouter + Theme
├── theme/
│   ├── app_theme.dart            # ThemeData configuration
│   └── app_colors.dart           # Color constants
├── models/
│   ├── task_model.dart           # Task data model
│   ├── resource_model.dart       # Resource data model
│   └── user_profile_model.dart   # User profile model
├── providers/
│   ├── task_provider.dart        # Task state + CRUD
│   ├── resource_provider.dart    # Resource state + CRUD
│   └── profile_provider.dart     # Profile state
├── services/
│   ├── storage_service.dart      # Hive storage wrapper
│   └── file_service.dart         # File handling utilities
├── screens/
│   ├── shell_screen.dart         # Bottom nav scaffold
│   ├── tasks/                    # Task screens
│   ├── library/                  # Library screens
│   └── profile/                  # Profile screen
├── widgets/                      # Reusable UI components
└── utils/                        # Helpers and constants
```

## Data Models

### Task
- Title, description, due date, priority (low/medium/high)
- Linked resources (many-to-many)
- Category, completion status

### Resource
- Title, description, type (pdf/audio/video/link/image/note)
- File storage (local) or URL (external)
- Tags, reference count

### UserProfile
- Name, school, grade
- Stats: tasks completed, resources, streak

## Storage

Uses Hive with 5 boxes:
- `tasks`: Task JSON
- `resources`: Resource JSON
- `resource_files`: Raw file bytes (IndexedDB)
- `profile`: User profile
- `settings`: App settings

## Success Criteria

✅ Create, complete, edit, delete tasks by day
✅ Upload/manage PDFs, audio, video, images, links, notes
✅ Link tasks to resources
✅ Visual library grid with type filtering
✅ Profile stats (tasks, resources, streak)
✅ Polished dark theme
✅ Web build ready for deployment
✅ Data persists via Hive/IndexedDB

## Future Enhancements (V2)

- User authentication & cloud sync
- AI-powered features (summarization, quiz generation)
- Collaboration with classmates
- Calendar integration
- Push notifications

## License

MIT License - feel free to use for personal or educational purposes.

## Credits

Made with ❤️ by xondamir.ai
