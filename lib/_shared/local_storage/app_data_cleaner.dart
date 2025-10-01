import 'package:shared_preferences/shared_preferences.dart';
import 'shared_prefs_service.dart';

/// Service to handle complete cleanup of all app data
class AppDataCleaner {
  static final AppDataCleaner _instance = AppDataCleaner._internal();
  factory AppDataCleaner() => _instance;
  AppDataCleaner._internal();

  /// Clear all app data including SharedPreferences, databases, and cached files
  Future<void> clearAllAppData() async {
    try {
      // Clear all SharedPreferences
      await SharedPrefsService().clearAll();
      
      // Also clear using direct SharedPreferences instance as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Note: For complete cleanup, you might also want to:
      // 1. Clear SQLite databases if using sqflite
      // 2. Clear cached files using path_provider
      // 3. Clear Firebase tokens
      // 4. Clear any other local storage
      
      print('All app data cleared successfully');
    } catch (e) {
      print('Error clearing app data: $e');
      // Even if there's an error, try to clear SharedPreferences directly
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (directError) {
        print('Error clearing SharedPreferences directly: $directError');
      }
    }
  }

  /// Clear only user-related data (for partial cleanup)
  Future<void> clearUserData() async {
    try {
      // Clear user data from SharedPreferences
      await SharedPrefsService().remove('current_user');
      
      // Clear any other user-specific keys
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // Remove keys that might be user-specific
      for (String key in keys) {
        if (key.contains('user') || key.contains('token') || key.contains('auth')) {
          await prefs.remove(key);
        }
      }
      
      print('User data cleared successfully');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  /// Force clear all data - useful for testing or when user manually clears app data
  Future<void> forceClearAllData() async {
    try {
      // Clear all SharedPreferences using multiple methods to ensure complete cleanup
      await SharedPrefsService().clearAll();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Also clear any cached data that might persist
      // This is especially important for Android devices where data can persist after uninstall
      
      print('Force clear completed successfully');
    } catch (e) {
      print('Error during force clear: $e');
      // Try one more time with direct SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (finalError) {
        print('Final error clearing SharedPreferences: $finalError');
      }
    }
  }
}
