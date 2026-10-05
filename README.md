# Sahaaya

Sahaaya is a Flutter application designed to connect people in need with nearby shelters, SOS support, and assistance resources. The app integrates Firebase for authentication, uses `go_router` for navigation, and ships with responsive layouts powered by Device Preview to streamline development across platforms.

## Features
- **Firebase integration**: Centralized authentication and configuration via `firebase_core`.
- **Router-driven navigation**: Declarative routing handled through `go_router` with graceful fallbacks when Firebase is unavailable.
- **Device preview tooling**: Device Preview enables rapid UI validation across form factors during development.
- **Resource discovery**: Screens for discovering shelters, reporting incidents, SOS support, IVR demos, and chat-based care.

## Project Structure
```text
lib/
├── main.dart                # App bootstrap, Firebase init, router wiring
├── router.dart              # Route definitions for authenticated/unauth flows
├── firebase_options.dart    # Environment-specific Firebase configuration
├── pages/                   # Feature screens (authentication, SOS, maps, etc.)
├── services/                # Business logic (e.g., auth, credit)
└── widgets/                 # Reusable UI components
```

## Prerequisites
- Flutter 3.22.0+ (stable channel recommended)
- Dart 3.4+
- Firebase project with Web configuration (matching `lib/firebase_options.dart`)
- Chrome or a Flutter-supported device/emulator

## Getting Started
1. **Install dependencies**
   ```powershell
   flutter pub get
   ```
2. **Configure Firebase**
   - Ensure the Firebase project referenced in `lib/firebase_options.dart` is valid.
   - For mobile platforms, add the platform-specific `google-services`/`GoogleService-Info` files as required by Firebase documentation.
3. **Run the app**
   ```powershell
   flutter run -d chrome
   ```
   Use `flutter run` with another device ID for mobile targets..

## Development Tips
- **Router fallback**: If Firebase initialization fails, the app falls back to a minimal router via `createRouterWithoutAuth()` to prevent blank screens on Web builds.
- **Device Preview**: Enabled automatically for non-release builds to validate layouts quickly. Disable by setting `enabled: false` in `main.dart` if not needed.
- **Clearing stale builds**: If you encounter disk-space related compiler errors, free space on the system drive and run `flutter clean` before rebuilding.

## Testing
Run the bundled widget test suite:
```powershell
flutter test
```
Add additional unit/widget/integration tests under the `test/` directory to cover new features.

## Troubleshooting
- **"There is not enough space on the disk" during compilation**: Clear `%LOCALAPPDATA%\Temp`, run `flutter clean`, and ensure the system drive has several GB free before retrying the build.
- **Missing Firebase configuration**: Double-check `firebase_options.dart` and platform-specific Firebase config files.

## Contributing
- Follow Flutter/Dart best practices (`flutter analyze` and `dart format`).
- Keep widgets modular and favor composition over large monolithic screens.
- Document new routes and services as needed.

## License
Internal hackathon project. Add licensing information here if the project is open-sourced in the future.
