
import '../../entities/user.dart';
import '../user_repo/user_local_repository.dart';

class CurrentUserProvider {
  final UserLocalRepository _userRepository;

  CurrentUserProvider() : _userRepository = UserLocalRepository();

  CurrentUserProvider.initWith(UserLocalRepository userRepository)
      : _userRepository = userRepository;

  /// Checks if a user is logged in (i.e., a user is saved locally)
  Future<bool> isLoggedIn() async {
    final user = await _userRepository.getUser();
    return user != null;
  }

  /// Gets the current user, or null if not found
  Future<User?> getCurrentUser() async {
    return await _userRepository.getUser();
  }
} 