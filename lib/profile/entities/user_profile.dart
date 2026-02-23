class UserProfile {
  final String id;
  final String name;
  final String email;
  final String dateOfBirth; // YYYY-MM-DD
  final String gender;
  final String? phone;
  final String? profileImage;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    this.phone,
    this.profileImage,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      phone: json['phone'] as String?,
      profileImage: json['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'name': name,
      'email': email,
      'date_of_birth': dateOfBirth,
      'gender': gender,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'phone': phone,
      'profile_image': profileImage,
    };
  }
}
