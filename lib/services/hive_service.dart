import 'package:hive_flutter/hive_flutter.dart';
import '../models/mood_entry.dart';
import '../models/journal_entry.dart';

class HiveService {
  static const String moodsBox = 'moods_box';
  static const String journalBox = 'journal_box';
  static const String settingsBox = 'settings_box';
  // Settings keys
  static const String keyProfileName = 'profile_name';
  static const String keyProfileSchool = 'profile_school';
  static const String keyProfileAvatarPath = 'profile_avatar_path';
  static const String keyProfileRole = 'profile_role';
  static const String keyMeditationStreak = 'meditation_streak';
  static const String keyMeditationLastDate = 'meditation_last_date';

  static Future<void> initialize() async {
    await Hive.openBox(moodsBox);
    await Hive.openBox(journalBox);
    await Hive.openBox(settingsBox);
  }

  // Mood entries methods
  static Future<List<MoodEntry>> getMoodEntries() async {
    final box = Hive.box(moodsBox);
    final entries = box.values.toList().cast<Map<dynamic, dynamic>>();
    return entries.map((e) => MoodEntry.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  static Future<void> saveMoodEntry(MoodEntry entry) async {
    final box = Hive.box(moodsBox);
    await box.put(entry.date.toIso8601String(), entry.toMap());
  }

  // Journal entries methods
  static Future<List<JournalEntry>> getJournalEntries() async {
    final box = Hive.box(journalBox);
    final entries = box.values.toList().cast<Map<dynamic, dynamic>>();
    return entries.map((e) => JournalEntry.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  static Future<void> saveJournalEntry(JournalEntry entry) async {
    final box = Hive.box(journalBox);
    await box.put(entry.id, entry.toMap());
  }

  // Settings methods
  static Future<void> setProfileName(String name) async {
    final box = Hive.box(settingsBox);
    await box.put(keyProfileName, name);
  }

  static String? getProfileName() {
    final box = Hive.box(settingsBox);
    return box.get(keyProfileName);
  }

  static Future<void> setProfileSchool(String school) async {
    final box = Hive.box(settingsBox);
    await box.put(keyProfileSchool, school);
  }

  static String? getProfileSchool() {
    final box = Hive.box(settingsBox);
    return box.get(keyProfileSchool);
  }

  static Future<void> setProfileAvatar(String avatarPath) async {
    final box = Hive.box(settingsBox);
    await box.put(keyProfileAvatarPath, avatarPath);
  }

  static String? getProfileAvatar() {
    final box = Hive.box(settingsBox);
    return box.get(keyProfileAvatarPath);
  }

  static Future<void> setProfileRole(String roleName) async {
    final box = Hive.box(settingsBox);
    await box.put(keyProfileRole, roleName);
  }

  static String? getProfileRole() {
    final box = Hive.box(settingsBox);
    return box.get(keyProfileRole);
  }
}


