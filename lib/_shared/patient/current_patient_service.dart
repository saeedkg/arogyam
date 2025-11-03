import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/user_management/service/current_user_provider.dart';
import '../../auth/entities/user.dart';
import 'current_patient.dart';
import 'dart:convert';


class CurrentPatientService {
  static const String _prefsKey = 'current_patient_selection';
  final CurrentUserProvider _currentUserProvider;

  CurrentPatientService({CurrentUserProvider? currentUserProvider})
      : _currentUserProvider = currentUserProvider ?? CurrentUserProvider();

  Future<CurrentPatient> getOrInitCurrentPatient() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null && stored.isNotEmpty) {
      try {
        return CurrentPatient.fromMap(_decode(stored));
      } catch (_) {
        await prefs.remove(_prefsKey);
      }
    }
    // Fallback to logged-in user as primary
    final User? user = await _currentUserProvider.getCurrentUser();
    final CurrentPatient fallback = CurrentPatient(
     // id: user?.userProfile?.id.toString() ?? user?.userProfile?.id.toString() ?? 'self',
      id: "self",
      name: user?.userProfile?.name ?? 'Patient',
      phone: user?.userProfile?.mobile,
      dateOfBirth: user?.userProfile?.mobile,
      isPrimary: true,
    );
    await setCurrentPatient(fallback);
    return fallback;
  }

  Future<void> setCurrentPatient(CurrentPatient patient) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _encode(patient.toMap()));
  }

  Map<String, dynamic> _decode(String json) {
    return Map<String, dynamic>.from(
      (jsonDecode(json) as Map<String, dynamic>),
    );
  }

  String _encode(Map<String, dynamic> map) {
    return jsonEncode(map);
  }
}


