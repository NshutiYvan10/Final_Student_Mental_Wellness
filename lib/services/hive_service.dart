import 'package:hive_flutter/hive_flutter.dart';
import '../models/mood_entry.dart';
import '../models/journal_entry.dart';
import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HiveService {
  static const String _baseMoodsBox = 'moods_box';
  static const String _baseJournalBox = 'journal_box';
  static const String _baseSettingsBox = 'settings_box';
  
  // Settings keys
  static const String keyProfileName = 'profile_name';
  static const String keyProfileSchool = 'profile_school';
  static const String keyProfileAvatarPath = 'profile_avatar_path';
  static const String keyProfileRole = 'profile_role';
  static const String keyMeditationStreak = 'meditation_streak';
  static const String keyMeditationLastDate = 'meditation_last_date';

  // Get current user-specific box names
  static String get moodsBox {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    return '${_baseMoodsBox}_$userId';
  }

  static String get journalBox {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    return '${_baseJournalBox}_$userId';
  }

  static String get settingsBox {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    return '${_baseSettingsBox}_$userId';
  }

  static Future<void> initialize() async {
    // Open default boxes for anonymous users
    await Hive.openBox('${_baseMoodsBox}_anonymous');
    await Hive.openBox('${_baseJournalBox}_anonymous');
    await Hive.openBox('${_baseSettingsBox}_anonymous');
  }

  // Initialize user-specific boxes when user logs in
  static Future<void> initializeUserBoxes(String userId) async {
    await Hive.openBox('${_baseMoodsBox}_$userId');
    await Hive.openBox('${_baseJournalBox}_$userId');
    await Hive.openBox('${_baseSettingsBox}_$userId');
  }

  // Close user-specific boxes when user logs out
  static Future<void> closeUserBoxes(String userId) async {
    try {
      await Hive.box('${_baseMoodsBox}_$userId').close();
      await Hive.box('${_baseJournalBox}_$userId').close();
      await Hive.box('${_baseSettingsBox}_$userId').close();
    } catch (e) {
      // Boxes might already be closed
    }
  }

  // Clear all data for current user (for testing/reset purposes)
  static Future<void> clearCurrentUserData() async {
    final moodBoxInstance = Hive.box(moodsBox);
    final journalBoxInstance = Hive.box(journalBox);
    final settingsBoxInstance = Hive.box(settingsBox);
    
    await moodBoxInstance.clear();
    await journalBoxInstance.clear();
    await settingsBoxInstance.clear();
  }

  // Mood entries methods
  static Future<List<MoodEntry>> getMoodEntries() async {
    try {
      final box = Hive.box(moodsBox);
      final entries = box.values.toList().cast<Map<dynamic, dynamic>>();
      return entries.map((e) => MoodEntry.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      // Box might not be open yet, return empty list
      return [];
    }
  }

  static Future<void> saveMoodEntry(MoodEntry entry) async {
    try {
      final box = Hive.box(moodsBox);
      await box.put(entry.date.toIso8601String(), entry.toMap());
    } catch (e) {
      // Try to open the box if it's not already open
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      await initializeUserBoxes(userId);
      final box = Hive.box(moodsBox);
      await box.put(entry.date.toIso8601String(), entry.toMap());
    }
  }

  // Journal entries methods
  static Future<List<JournalEntry>> getJournalEntries() async {
    try {
      final box = Hive.box(journalBox);
      final entries = box.values.toList().cast<Map<dynamic, dynamic>>();
      return entries.map((e) => JournalEntry.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      // Box might not be open yet, return empty list
      return [];
    }
  }

  static Future<void> saveJournalEntry(JournalEntry entry) async {
    try {
      final box = Hive.box(journalBox);
      await box.put(entry.id, entry.toMap());
    } catch (e) {
      // Try to open the box if it's not already open
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      await initializeUserBoxes(userId);
      final box = Hive.box(journalBox);
      await box.put(entry.id, entry.toMap());
    }
  }

  // Settings methods
  static Future<void> setProfileName(String name) async {
    try {
      final box = Hive.box(settingsBox);
      await box.put(keyProfileName, name);
    } catch (e) {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      await initializeUserBoxes(userId);
      final box = Hive.box(settingsBox);
      await box.put(keyProfileName, name);
    }
  }

  static String? getProfileName() {
    try {
      final box = Hive.box(settingsBox);
      return box.get(keyProfileName);
    } catch (e) {
      return null;
    }
  }

  static Future<void> setProfileSchool(String school) async {
    try {
      final box = Hive.box(settingsBox);
      await box.put(keyProfileSchool, school);
    } catch (e) {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      await initializeUserBoxes(userId);
      final box = Hive.box(settingsBox);
      await box.put(keyProfileSchool, school);
    }
  }

  static String? getProfileSchool() {
    try {
      final box = Hive.box(settingsBox);
      return box.get(keyProfileSchool);
    } catch (e) {
      return null;
    }
  }

  static Future<void> setProfileAvatar(String avatarPath) async {
    try {
      final box = Hive.box(settingsBox);
      await box.put(keyProfileAvatarPath, avatarPath);
    } catch (e) {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      await initializeUserBoxes(userId);
      final box = Hive.box(settingsBox);
      await box.put(keyProfileAvatarPath, avatarPath);
    }
  }

  static String? getProfileAvatar() {
    try {
      final box = Hive.box(settingsBox);
      return box.get(keyProfileAvatarPath);
    } catch (e) {
      return null;
    }
  }

  static Future<void> setProfileRole(String roleName) async {
    try {
      final box = Hive.box(settingsBox);
      await box.put(keyProfileRole, roleName);
    } catch (e) {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      await initializeUserBoxes(userId);
      final box = Hive.box(settingsBox);
      await box.put(keyProfileRole, roleName);
    }
  }

  static String? getProfileRole() {
    try {
      final box = Hive.box(settingsBox);
      return box.get(keyProfileRole);
    } catch (e) {
      return null;
    }
  }
}


