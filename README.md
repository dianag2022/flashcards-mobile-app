# flashcard_mobile_app

Flutter mobile app for flashcards (Android and iOS).

## Getting started

This folder contains the Dart app skeleton. Generate the Android and iOS
platform projects (required to run on a device or emulator) from this
directory:

```bash
flutter create --platforms android,ios .
flutter pub get
flutter run
```

If `flutter` is blocked by Device Guard, move the Flutter SDK out of
`Downloads` (for example to `C:\src\flutter`) and add that `bin` folder to PATH.
