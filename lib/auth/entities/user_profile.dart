class UserProfile {
  final int id;
  final String name;
 // final String email;
  final String mobile;
 // final List<String> roles;

  UserProfile({
    required this.id,
    required this.name,
   // required this.email,
    required this.mobile,
   // required this.roles,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      name: json['name'] as String,
     // email: json['email'] as String,
      mobile: json['phone'] as String,
      //roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }
} 