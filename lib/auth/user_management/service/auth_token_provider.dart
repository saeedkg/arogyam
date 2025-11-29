
import '../../../_shared/constants/network_config.dart';
import '../../../_shared/device/device_info.dart';
import '../../../network/entities/api_request.dart';
import '../../../network/entities/api_response.dart';
import '../../../network/services/network_adapter.dart';
import '../../../network/services/network_request_executor.dart';
import '../../entities/user.dart';
import '../user_repo/user_local_repository.dart';
import 'current_user_provider.dart';

class AuthTokenProvider {
  //late CurrentUserProvider _currentUserProvider;
  late UserLocalRepository _userRepository;


  // AuthTokenProvider() : _currentUserProvider = CurrentUserProvider();
  // AuthTokenProvider.initWith(this._currentUserProvider);


  ///late UserRepository _userRepository;
  late DeviceInfoProvider _deviceInfoProvider;
  late NetworkAdapter _networkAdapter;

  AuthTokenProvider() {
    //_userRepository = UserRepository.getInstance();
    //_currentUserProvider = CurrentUserProvider();
    _userRepository = UserLocalRepository();
    _deviceInfoProvider = DeviceInfoProvider();
    _networkAdapter = NetworkRequestExecutor();
  }

  // Future<String?> getToken() async {
  //   final User? user = await _currentUserProvider.getCurrentUser();
  //   return user?.token;
  // }
  Future<String?> getToken({bool forceRefresh = false}) async {
    final User? user = await _userRepository.getUser();

    if (forceRefresh == false && user != null ) {
      return user?.token;
    } else if (user != null && (forceRefresh == true )) {
      var refreshedToken = await _refreshSessionForUser(user);
      return refreshedToken;
    } else {
      return null;
    }
  }
  Future<String?> _refreshSessionForUser(User user) async {
    var apiRequest = APIRequest('${NetworkConfig.baseUrl}/auth/refresh-token');
    var inactiveSession = user.token;
    apiRequest.addHeader('Authorization', inactiveSession.toString());
    apiRequest.addParameters({
      'refresh_token': user.refreshToken,
     // 'username': user.username,
      'deviceuid': await _deviceInfoProvider.getDeviceId(),
    });

    try {
      var apiResponse = await _networkAdapter.post(apiRequest);
      var accessToken = _processResponse(apiResponse, user);
      return accessToken;
    } catch (e) {
      return null;
    }
  }
  String? _processResponse(APIResponse apiResponse, User user) {
    if (apiResponse.data == null || apiResponse.data is! Map<String, dynamic>) {
      return null;
    }

    var responseMap = apiResponse.data as Map<String, dynamic>;
    try {

      final tokens = responseMap['tokens'];
      if (tokens == null || tokens is! Map<String, dynamic>) {
        return null;
      }

      // Create updated user object using previous userProfile
      final User newUser = User(
        userProfile: user.userProfile,
        token: tokens['access_token'] as String?,
        refreshToken: tokens['refresh_token'] as String?,

      );

      // Save the new user
      _userRepository.saveUser(newUser);
      //user.updateAccessToken(token, expirationTimeStamp);

      return newUser.token;
    } catch (e) {
      return null;
    }
  }
}

