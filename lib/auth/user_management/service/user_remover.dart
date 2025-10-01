
import '../user_repo/user_local_repository.dart';

class UserRemover {
  late UserLocalRepository _userRepository;

  UserRemover() {
    _userRepository = UserLocalRepository();
  }

  UserRemover.initWith(UserLocalRepository userRepository) {
    _userRepository = userRepository;
  }

  Future<void> removeUser() async {
    await _userRepository.removeUser();
  }
} 