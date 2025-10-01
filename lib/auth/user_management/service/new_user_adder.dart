
import '../../entities/user.dart';
import '../user_repo/user_local_repository.dart';

class NewUserAdder {
  late UserLocalRepository _userRepository;

  NewUserAdder() {
    _userRepository = UserLocalRepository();
  }

  NewUserAdder.initWith(UserLocalRepository userRepository) {
    _userRepository = userRepository;
  }

  Future<void> addUser(User user) async {
    await _userRepository.saveUser(user);
  }
} 