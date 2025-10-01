
import 'package:arogyam/auth/entities/user_profile.dart';

class User {
  final UserProfile? userProfile;
  final String? token;

  // final List<String> roles;

  User({
    required this.userProfile,
    required this.token,
    // required this.roles,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userProfile: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
      token: json['token'] as String?,
      //roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }


}
