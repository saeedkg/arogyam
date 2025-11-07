
import 'package:arogyam/auth/entities/user.dart';


class VerifyOtpResponse {
  final bool success;
  final String message;
  final bool userExists;
  //final bool? profileComplete;
  // final UserProfile? userProfile;
  // final String? token;
  final User? user;

  VerifyOtpResponse({
    required this.success,
    required this.message,
    required this.userExists,
   // required this.profileComplete,
     this.user,
    // this.token,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?);
    return VerifyOtpResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      userExists: !(json['is_new_user'] as bool? ?? false),
      // profileComplete: json['profile_complete'] as bool,
      user: (data != null && data['user'] != null) ? User.fromJson(data) : null,
      // token: data?['access_token'] as String?,
    );
  }
} 