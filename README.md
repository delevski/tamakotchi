# Tamakochi

A cross-platform virtual-pet app built with Flutter. Players care for a pet whose hunger, hygiene, fun, energy, age, and evolution continue changing over time, with local persistence and optional Firebase authentication.

The current interface is Hebrew-first and includes English localization resources.

## Features

- Four evolving life stages: baby, child, teen, and adult
- Dog, cat, and dinosaur pet paths
- Feed, clean, play, and sleep actions
- Time-based stat decay and automatic stage progression
- Local state persistence with SharedPreferences
- Email/password and Google sign-in flows through Firebase
- Riverpod-based state management
- Android, iOS, web, Windows, macOS, and Linux targets

## Stack

- Flutter and Dart
- Riverpod
- Firebase Core, Authentication, and Cloud Firestore
- Google Sign-In
- SharedPreferences
- Flutter internationalization (`intl` and ARB files)

## Run locally

### Requirements

- Flutter SDK compatible with Dart `^3.10.4`
- A Firebase project for authentication features

```bash
git clone https://github.com/delevski/tamakotchi.git
cd tamakotchi
flutter pub get
flutter run
```

Choose a target explicitly when needed, for example:

```bash
flutter run -d chrome
```

## Firebase setup

Create a Firebase project, enable the authentication providers you want, and add the generated platform configuration files before using the sign-in features. Do not commit service-account credentials.

## Project structure

- `lib/logic` - pet state and authentication providers
- `lib/screens` - authentication and game screens
- `lib/l10n` - Hebrew and English translations
- `assets` - pet images and audio
