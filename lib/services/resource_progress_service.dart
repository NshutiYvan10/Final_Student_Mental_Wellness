import 'package:shared_preferences/shared_preferences.dart';

class ResourceProgressService {
  static const String _keyPrefix = 'resource_completed_';
  
  // Check if a resource has been completed
  static Future<bool> isResourceCompleted(String resourceId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyPrefix$resourceId') ?? false;
  }
  
  // Mark a resource as completed
  static Future<void> markResourceCompleted(String resourceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$resourceId', true);
  }
  
  // Get all completed resource IDs
  static Future<List<String>> getCompletedResources() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    return keys
        .where((key) => key.startsWith(_keyPrefix) && prefs.getBool(key) == true)
        .map((key) => key.replaceFirst(_keyPrefix, ''))
        .toList();
  }
  
  // Get completion percentage
  static Future<double> getCompletionPercentage(int totalResources) async {
    final completed = await getCompletedResources();
    if (totalResources == 0) return 0.0;
    return completed.length / totalResources;
  }
  
  // Reset all progress
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
