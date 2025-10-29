# Student Mental Wellness


A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase ML Model Setup

1. Install Firebase CLI and configure your Firebase project.
2. Ensure `lib/firebase_options.dart` is generated via FlutterFire and app builds against the project you intend to use.
3. Deploy the sentiment TFLite model using Firebase ML:
   - In Firebase Console → ML → Custom models → Add model
   - Model name: `sentiment_analysis_model`
   - Upload your `sentiment.tflite`
   - Publish the model
4. Optionally bundle a local fallback at `assets/models/sentiment.tflite` and add it to `pubspec.yaml` under `assets:`.
5. On app start, the app attempts Firebase ML first. If Firebase is configured but no model is available, it will throw; otherwise it falls back to a heuristic when Firebase isn’t configured.

## Messaging Features Notes

- Unread badges are computed from per-user read state stored in `chat_rooms/{roomId}/read_states/{userId}`.
- Typing indicators are published under `chat_rooms/{roomId}/typing/{userId}` with `isTyping` and `updatedAt`.
- Pagination: messages are streamed with a limit (default 50) and older messages fetched in batches.

## Running Tests

- Run all tests:
```bash
flutter test
```
- Tests included:
  - `test/ml_service_test.dart`: heuristic sentiment checks
  - `test/mood_theme_provider_test.dart`: mood-based theme updates
  - `test/messaging_hub_widget_test.dart`: tabs/discover UI smoke test

## Permissions

- Android 13+ notifications permission is requested at runtime.
