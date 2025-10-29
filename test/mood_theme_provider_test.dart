import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:student_mental_wellness/providers/mood_theme_provider.dart';
import 'package:student_mental_wellness/models/mood_entry.dart';

late Directory _hiveTempDir;

void main() {
  setUpAll(() async {
    _hiveTempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(_hiveTempDir.path);
    await Hive.openBox('moods_box');
    await Hive.openBox('journal_box');
    await Hive.openBox('settings_box');
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      _hiveTempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('MoodThemeProvider updates theme based on mood', () {
    final provider = MoodThemeProvider();
    final initial = provider.state.primaryGradient;

    provider.updateMood(MoodType.veryHappy);
    final updated = provider.state.primaryGradient;

    expect(updated, isNot(initial));
  });
}




