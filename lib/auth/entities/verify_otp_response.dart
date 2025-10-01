
import 'package:arogyam/auth/entities/user.dart';


class VerifyOtpResponse {
  final bool success;
  final String message;
  final bool userExists;
  final bool profileComplete;
  // final UserProfile? userProfile;
  // final String? token;
  final User? user;

  VerifyOtpResponse({
    required this.success,
    required this.message,
    required this.userExists,
    required this.profileComplete,
     this.user,
    // this.token,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      userExists: json['user_exists'] as bool,
      profileComplete: json['profile_complete'] as bool,
      user: json['user'] != null ? User.fromJson(json) : null,
      //token: json['token'] as String?,
    );
  }
} 