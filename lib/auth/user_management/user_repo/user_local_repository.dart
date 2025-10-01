
import '../../../_shared/local_storage/shared_prefs_service.dart';
import '../../entities/user.dart';

/// Repository for saving, retrieving, and removing a single user locally.
class UserLocalRepository {
  static final UserLocalRepository _instance = UserLocalRepository._internal();
  factory UserLocalRepository() => _instance;
  UserLocalRepository._internal();

  static const String _userKey = 'current_user';

  /// Save the user locally (overwrites any existing user)
  Future<void> saveUser(User user) async {
    await SharedPrefsService().saveMap(_userKey, _userToJson(user));
  }

  /// Retrieve the saved user, or null if not found
  Future<User?> getUser() async {
    final map = await SharedPrefsService().getMap(_userKey);
    if (map == null) return null;
    return User.fromJson(map);
  }

  /// Remove the saved user
  Future<void> removeUser() async {
    await SharedPrefsService().remove(_userKey);
  }

  Map<String, dynamic> _userToJson(User user) {
    return {
      'user': user.userProfile != null
          ? {
              'id': user.userProfile!.id,
              'name': user.userProfile!.name,
              'email': user.userProfile!.email,
              'mobile': user.userProfile!.mobile,
            }
          : null,
      'token': user.token,
    };
  }
} 