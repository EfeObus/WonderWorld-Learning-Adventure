# WonderWorld Learning Adventure - Flutter Frontend

## Project Setup

This Flutter mobile app provides an engaging educational experience for children ages 2-8.

### Prerequisites

- Flutter SDK 3.16+ installed
- Dart SDK 3.2+
- Android Studio / Xcode for emulators
- VS Code with Flutter extension

### Getting Started

1. **Create Flutter project structure:**
   ```bash
   cd frontend
   flutter create . --org com.wonderworld --project-name wonderworld_learning
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   # For development
   flutter run
   
   # For specific device
   flutter run -d <device_id>
   
   # List available devices
   flutter devices
   ```

### Project Structure

```
frontend/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── app/
│   │   ├── app.dart              # MaterialApp setup
│   │   └── router.dart           # GoRouter navigation
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart    # Child-friendly theme
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   └── child_provider.dart
│   │   └── services/
│   │       ├── api_service.dart  # Backend API calls
│   │       ├── storage_service.dart
│   │       └── audio_service.dart
│   └── features/
│       ├── auth/                 # Login, Register, Child Select
│       ├── home/                 # Main dashboard
│       ├── literacy/             # Letter tracing, phonics, words
│       ├── numeracy/             # Counting, math puzzles
│       ├── sel/                  # Feelings wheel, kindness
│       ├── games/                # Achievements, mini-games
│       ├── dashboard/            # Parent dashboard
│       └── splash/               # Splash screen
├── pubspec.yaml                  # Dependencies
├── android_config.dart           # Android setup notes
└── ios_config.dart               # iOS setup notes
```

### Key Features

#### 🔤 Literacy Module
- **Letter Tracing**: Interactive finger drawing on letter guides
- **Phonics**: Letter sounds with audio feedback
- **Word Building**: Drag letters to spell words

#### 🔢 Numeracy Module
- **Counting (1-20)**: Visual number blocks (Nooms)
- **Addition & Subtraction**: Age-appropriate math puzzles
- **Shapes**: Interactive shape recognition

#### 💝 SEL Module
- **Feelings Wheel**: Emotion exploration with tips
- **Kindness Bingo**: Daily kindness activities
- **Calm Corner**: Breathing exercises

#### 🎮 Gamification
- **Stars**: Earned for completing activities
- **Streak**: Daily learning encouragement
- **Achievements**: Unlockable badges
- **Unlockable Games**: Rewards for progress

### Configuration

Update `lib/core/services/api_service.dart` to point to your backend:

```dart
static const String baseUrl = 'http://localhost:5067/api';
```

For production:
```dart
static const String baseUrl = 'https://your-api-domain.com/api/v1';
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (recommended)
flutter build appbundle --release

# iOS
flutter build ios --release
```

### Dependencies

| Package | Purpose |
|---------|---------|
| flutter_riverpod | State management |
| go_router | Navigation |
| dio | HTTP client |
| hive_flutter | Local storage |
| audioplayers | Sound effects |
| flutter_animate | Animations |
| flame | Game engine (optional) |

### Theme Colors

- Primary: `#6B4EFF` (Purple)
- Literacy: `#FF6B6B` (Coral)
- Numeracy: `#4ECDC4` (Teal)
- SEL: `#FF6B9D` (Pink)
- Games: `#FFBE0B` (Yellow)

### COPPA/GDPR-K Compliance

- No third-party ads
- No external analytics collecting PII
- Parental consent required for data processing
- Children's data stored securely
- Data deletion available through parent dashboard
