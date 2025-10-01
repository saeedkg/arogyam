
import '../../entities/user.dart';
import 'current_user_provider.dart';

class AuthTokenProvider {
  final CurrentUserProvider _currentUserProvider;

  AuthTokenProvider() : _currentUserProvider = CurrentUserProvider();
  AuthTokenProvider.initWith(this._currentUserProvider);

  Future<String?> getToken() async {
    final User? user = await _currentUserProvider.getCurrentUser();
    return user?.token;
  }
} 