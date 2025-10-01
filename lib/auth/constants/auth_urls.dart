import '../../_shared/constants/network_config.dart';

class AuthUrls {
  static String getOtPUrl() {
    return '${NetworkConfig.baseUrl}/auth/send-otp';
  }
  static String getVerifyOtpUrl() {
    return '${NetworkConfig.baseUrl}/auth/verify-otp';
  }
  static String deleteAccountUrl() {
    return '${NetworkConfig.baseUrl}/auth/account';
  }
  
  static String logoutUrl() {
    return '${NetworkConfig.baseUrl}/auth/logout';
  }
}