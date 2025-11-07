import 'package:shared_preferences/shared_preferences.dart';
import '../../_shared/patient/current_patient_service.dart';
import '../user_management/user_repo/user_local_repository.dart';

class LogoutService {
  static final LogoutService _instance = LogoutService._internal();
  factory LogoutService() => _instance;
  LogoutService._internal();

  /// Clear all user data and preferences
  Future<void> clearAllUserData() async {
    try {
      // Clear user data from repository
      final userRepo = UserLocalRepository();
      await userRepo.removeUser();

      // Clear current patient selection
      final currentPatientService = CurrentPatientService();
      await currentPatientService.clearCurrentPatient();

      // Clear any onboarding completion flag if you want users to see onboarding again
      // Uncomment the line below if you want to reset onboarding on logout
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.remove('onboarding_complete');

      // Clear any other auth-related preferences if needed
      // You can add more cleanup here as needed
    } catch (e) {
      // Log error but don't throw - we want to continue with logout even if cleanup fails
      print('Error clearing user data: $e');
    }
  }
}

