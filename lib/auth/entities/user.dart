
import 'package:arogyam/auth/entities/user_profile.dart';

class User {
  final UserProfile? userProfile;
  final String? token;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;

  // final List<String> roles;

  User({
    required this.userProfile,
    required this.token,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    // required this.roles,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    // Accept either API shape (data.{user, access_token,...}) or locally stored shape ({user, token})
    final Map<String, dynamic> source =
        (json.containsKey('data') && json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    return User(
      userProfile: source['user'] != null ? UserProfile.fromJson(source['user'] as Map<String, dynamic>) : null,
      token: (source['access_token'] as String?) ?? (source['token'] as String?),
      refreshToken: source['refresh_token'] as String?,
      tokenType: source['token_type'] as String?,
      expiresIn: source['expires_in'] is int ? source['expires_in'] as int : null,
      //roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }


}
