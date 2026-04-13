# StudyFlow - Quick Start Guide

## What You've Got

A fully functional Flutter web app for student task management with:

✅ **3 Main Screens** (bottom navigation)
- Tasks: Daily task list with priority sorting
- Library: Resource grid with type filtering
- Profile: User stats and settings

✅ **Complete Task Management**
- Create tasks with title, description, priority, category
- Link tasks to study materials
- Complete/uncomplete with animations
- Edit and delete with swipe gestures
- Daily view with date selector

✅ **Full Resource Library**
- 6 resource types: PDF, Audio, Video, Image, Link, Note
- Upload files or add URLs
- Visual grid with color-coded icons
- Filter by type with counts
- Search by title, description, tags
- Audio player with speed control (1x, 1.5x, 2x)

✅ **Data Persistence**
- Hive storage with IndexedDB
- 5 storage boxes (tasks, resources, files, profile, settings)
- Automatic save on all changes
- Cross-session persistence

✅ **Polished UI**
- Dark theme with custom color palette
- Google Fonts (Inter)
- Smooth animations
- Empty states with CTAs
- Progress indicators
- Responsive design

## Run It NOW

### Option 1: If You Have Flutter Installed

```bash
cd studyflow
flutter pub get
flutter run -d chrome
```

### Option 2: If Flutter Isn't Installed Yet

1. **Install Flutter:**
   - Download from https://flutter.dev/docs/get-started/install
   - Follow the installation guide for your OS
   - Run `flutter doctor` to verify setup

2. **Enable Web:**
   ```bash
   flutter config --enable-web
   ```

3. **Run the App:**
   ```bash
   cd studyflow
   flutter pub get
   flutter run -d chrome
   ```

## File Structure Summary

```
studyflow/
├── lib/
│   ├── main.dart                 # Entry point + Hive init
│   ├── app.dart                  # Router + theme setup
│   ├── theme/                    # Colors and themes
│   ├── models/                   # Data models (Task, Resource, Profile)
│   ├── providers/                # Riverpod state management
│   ├── services/                 # Storage and file utilities
│   ├── screens/                  # All UI screens
│   ├── widgets/                  # Reusable components
│   └── utils/                    # Helpers and constants
├── web/                          # Web configuration
├── pubspec.yaml                  # Dependencies
├── vercel.json                   # Deployment config
├── README.md                     # Full documentation
└── DEPLOYMENT.md                 # Deploy guide
```

## Key Features Walkthrough

### 1. Create a Task
1. Go to Tasks tab
2. Tap "+" FAB
3. Enter title (e.g., "Listen to lecture")
4. Set priority (High/Medium/Low)
5. Tap "Attach Resources"
6. Select study materials
7. Tap "Create Task"

### 2. Upload a Resource
1. Go to Library tab
2. Tap "+" FAB
3. Select type (PDF/Audio/Video/etc.)
4. Upload file or paste URL
5. Add title and tags
6. Tap "Save to Library"

### 3. Link Task to Resource
- During task creation: "Attach Resources" button
- In task detail: "Attach" button next to Study Materials
- Resources can be linked to multiple tasks

### 4. Complete a Task
- Tap checkbox on task card
- See animation + strikethrough
- Progress bar updates automatically

### 5. View Resources
- Tap resource card to see details
- Audio: Play with speed controls
- PDF/Video: Viewer placeholder (add full player in V2)
- Link: Opens in browser
- Note: Editable text

## Next Steps (After Running)

### Test All Features
- Create 3-5 tasks with different priorities
- Upload 2-3 resources of different types
- Link tasks to resources
- Complete some tasks
- Check profile stats

### Customize
- Change your name in Profile
- Add school and grade
- Experiment with tags
- Try different date selections

### Deploy to Vercel
```bash
flutter build web --release --web-renderer canvaskit
cd build/web
vercel --prod
```

## Troubleshooting

### "flutter: command not found"
- Flutter not installed
- Download from https://flutter.dev

### "No devices found"
- Run: `flutter devices`
- Install Chrome if not available
- Try: `flutter run -d chrome`

### "Package not found"
- Run: `flutter pub get`
- Check internet connection

### "Build failed"
- Run: `flutter clean && flutter pub get`
- Check for syntax errors in code

## Architecture Highlights

### State Management (Riverpod)
- `taskProvider`: All task CRUD operations
- `resourceProvider`: All resource CRUD operations
- `profileProvider`: User profile state
- Providers auto-save to Hive on changes

### Storage (Hive)
- `tasks` box: Task JSON
- `resources` box: Resource metadata
- `resource_files` box: Raw file bytes
- `profile` box: User data
- `settings` box: App preferences

### Routing (GoRouter)
- `/tasks` - Main task list
- `/library` - Resource grid
- `/profile` - User stats
- `/tasks/:id` - Task detail
- `/library/:id` - Resource detail

### Design System
- **Colors**: Custom palette (see `app_colors.dart`)
- **Typography**: Google Fonts Inter
- **Spacing**: 12px/16px/20px system
- **Radius**: 12px buttons, 16px cards, 20px chips

## Performance Tips

- Keep files under 10MB
- Limit to ~100 tasks for best performance
- Clear browser cache if slow
- Use Chrome for best IndexedDB support

## Browser Storage

StudyFlow uses IndexedDB via Hive:
- Chrome: ~6GB available
- Firefox: ~2GB available
- Safari: ~1GB available
- Edge: ~6GB available

File limit: 50MB per file (enforced)

## Support

For issues or questions:
1. Check README.md for full documentation
2. Check DEPLOYMENT.md for deploy guide
3. Review code comments in each file
4. Check Flutter/Dart documentation

## Credits

**Built with:**
- Flutter 3.x
- Riverpod 2.x
- Hive
- GoRouter
- just_audio
- Google Fonts

**Design:** Custom dark theme optimized for students

**Ready for:** Vercel deployment

---

**You're all set! Run `flutter pub get` and `flutter run -d chrome` to see StudyFlow in action! 🚀**
