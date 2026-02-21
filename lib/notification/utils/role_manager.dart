import 'package:shared_preferences/shared_preferences.dart';

/// Manager for user role handling
class RoleManager {
  static const String _userRoleKey = 'user_role';

  /// Get current user role
  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey) ?? 'patient';
  }

  /// Set user role
  static Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
    print('✅ User role set to: $role');
  }

  /// Check if user is patient
  static Future<bool> isPatient() async {
    final role = await getUserRole();
    return role == 'patient';
  }

  /// Check if user is doctor
  static Future<bool> isDoctor() async {
    final role = await getUserRole();
    return role == 'doctor';
  }

  /// Get role-specific API base path
  static Future<String> getRoleBasePath() async {
    final role = await getUserRole();
    return '/api/v1/$role';
  }

  /// Get role-specific notification types
  static Future<List<String>> getRoleNotificationTypes() async {
    final role = await getUserRole();
    
    if (role == 'patient') {
      return [
        'appointment_reminder',
        'appointment_confirmed',
        'appointment_cancelled',
        'doctor_assigned',
        'consultation_started',
        'consultation_ended',
        'chat_message',
        'prescription_ready',
        'payment_success',
        'payment_failed',
        'follow_up_available',
        'review_request',
        'promotional',
      ];
    } else if (role == 'doctor') {
      return [
        'new_appointment',
        'appointment_cancelled',
        'consultation_request',
        'chat_message',
        'patient_waiting',
        'review_received',
        'payment_received',
      ];
    }
    
    return [];
  }
}
