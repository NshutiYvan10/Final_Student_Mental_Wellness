import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_entry.dart';
import '../services/hive_service.dart';

class MoodThemeProvider extends StateNotifier<MoodTheme> {
  MoodThemeProvider() : super(MoodTheme.neutral()) {
    _loadLatestMood();
  }

  Future<void> _loadLatestMood() async {
    try {
      final moodEntries = await HiveService.getMoodEntries();
      if (moodEntries.isNotEmpty) {
        // Get the most recent mood entry
        moodEntries.sort((a, b) => b.date.compareTo(a.date));
        final latestMood = moodEntries.first;
        _updateThemeFromMood(latestMood.moodType);
      }
    } catch (e) {
      print('Error loading mood for theme: $e');
    }
  }

  void updateMood(MoodType mood) {
    _updateThemeFromMood(mood);
  }

  void _updateThemeFromMood(MoodType mood) {
    state = MoodTheme.fromMood(mood);
  }
}

class MoodTheme {
  final List<Color> primaryGradient;
  final List<Color> secondaryGradient;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  MoodTheme({
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  factory MoodTheme.fromMood(MoodType mood) {
    switch (mood) {
      case MoodType.veryHappy:
        return MoodTheme(
          primaryGradient: const [
            Color(0xFF4CAF50), // Green
            Color(0xFF8BC34A), // Light Green
          ],
          secondaryGradient: const [
            Color(0xFF81C784), // Light Green
            Color(0xFFAED581), // Lighter Green
          ],
          primaryColor: const Color(0xFF4CAF50),
          secondaryColor: const Color(0xFF8BC34A),
          accentColor: const Color(0xFF2E7D32),
        );

      case MoodType.happy:
        return MoodTheme(
          primaryGradient: const [
            Color(0xFF2196F3), // Blue
            Color(0xFF64B5F6), // Light Blue
          ],
          secondaryGradient: const [
            Color(0xFF90CAF9), // Light Blue
            Color(0xFFBBDEFB), // Lighter Blue
          ],
          primaryColor: const Color(0xFF2196F3),
          secondaryColor: const Color(0xFF64B5F6),
          accentColor: const Color(0xFF1976D2),
        );

      case MoodType.neutral:
        return MoodTheme(
          primaryGradient: const [
            Color(0xFF9E9E9E), // Grey
            Color(0xFFBDBDBD), // Light Grey
          ],
          secondaryGradient: const [
            Color(0xFFE0E0E0), // Light Grey
            Color(0xFFF5F5F5), // Lighter Grey
          ],
          primaryColor: const Color(0xFF9E9E9E),
          secondaryColor: const Color(0xFFBDBDBD),
          accentColor: const Color(0xFF757575),
        );

      case MoodType.sad:
        return MoodTheme(
          primaryGradient: const [
            Color(0xFF607D8B), // Blue Grey
            Color(0xFF90A4AE), // Light Blue Grey
          ],
          secondaryGradient: const [
            Color(0xFFB0BEC5), // Light Blue Grey
            Color(0xFFCFD8DC), // Lighter Blue Grey
          ],
          primaryColor: const Color(0xFF607D8B),
          secondaryColor: const Color(0xFF90A4AE),
          accentColor: const Color(0xFF455A64),
        );

      case MoodType.verySad:
        return MoodTheme(
          primaryGradient: const [
            Color(0xFF3F51B5), // Indigo
            Color(0xFF7986CB), // Light Indigo
          ],
          secondaryGradient: const [
            Color(0xFF9FA8DA), // Light Indigo
            Color(0xFFC5CAE9), // Lighter Indigo
          ],
          primaryColor: const Color(0xFF3F51B5),
          secondaryColor: const Color(0xFF7986CB),
          accentColor: const Color(0xFF303F9F),
        );

      case MoodType.anxious:
        return MoodTheme(
          primaryGradient: const [
            Color(0xFFFF9800), // Orange
            Color(0xFFFFB74D), // Light Orange
          ],
          secondaryGradient: const [
            Color(0xFFFFCC80), // Light Orange
            Color(0xFFFFE0B2), // Lighter Orange
          ],
          primaryColor: const Color(0xFFFF9800),
          secondaryColor: const Color(0xFFFFB74D),
          accentColor: const Color(0xFFF57C00),
        );

      case MoodType.angry:
        return MoodTheme(
          primaryGradient: const [
            Color(0xFFF44336), // Red
            Color(0xFFEF5350), // Light Red
          ],
          secondaryGradient: const [
            Color(0xFFE57373), // Light Red
            Color(0xFFFFCDD2), // Lighter Red
          ],
          primaryColor: const Color(0xFFF44336),
          secondaryColor: const Color(0xFFEF5350),
          accentColor: const Color(0xFFD32F2F),
        );

      case MoodType.stressed:
        return MoodTheme(
          primaryGradient: const [
            Color(0xFF795548), // Brown
            Color(0xFFA1887F), // Light Brown
          ],
          secondaryGradient: const [
            Color(0xFFBCAAA4), // Light Brown
            Color(0xFFD7CCC8), // Lighter Brown
          ],
          primaryColor: const Color(0xFF795548),
          secondaryColor: const Color(0xFFA1887F),
          accentColor: const Color(0xFF5D4037),
        );

      case MoodType.calm:
        return MoodTheme(
          primaryGradient: const [
            Color(0xFF00BCD4), // Cyan
            Color(0xFF4DD0E1), // Light Cyan
          ],
          secondaryGradient: const [
            Color(0xFF80DEEA), // Light Cyan
            Color(0xFFB2EBF2), // Lighter Cyan
          ],
          primaryColor: const Color(0xFF00BCD4),
          secondaryColor: const Color(0xFF4DD0E1),
          accentColor: const Color(0xFF0097A7),
        );

      case MoodType.energetic:
        return MoodTheme(
          primaryGradient: const [
            Color(0xFFE91E63), // Pink
            Color(0xFFF06292), // Light Pink
          ],
          secondaryGradient: const [
            Color(0xFFF48FB1), // Light Pink
            Color(0xFFF8BBD9), // Lighter Pink
          ],
          primaryColor: const Color(0xFFE91E63),
          secondaryColor: const Color(0xFFF06292),
          accentColor: const Color(0xFFC2185B),
        );
    }
  }

  factory MoodTheme.neutral() {
    return MoodTheme.fromMood(MoodType.neutral);
  }
}

final moodThemeProvider = StateNotifierProvider<MoodThemeProvider, MoodTheme>((ref) {
  return MoodThemeProvider();
});
