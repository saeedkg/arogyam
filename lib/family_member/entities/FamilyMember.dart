class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final String dateOfBirth; // yyyy-MM-dd (display-friendly can be formatted in UI later)
  final String gender;
  final String bloodGroup;
  final String? profileImage;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    this.profileImage,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final dobRaw = json['date_of_birth'] as String?;
    final dob = dobRaw != null && dobRaw.length >= 10 ? dobRaw.substring(0, 10) : (dobRaw ?? '');
    return FamilyMember(
      id: '${json['id']??"self"}',//  comes id null for the account holder  Because id generate when creating add family member so by default member dont have id, so its comes as null// also by deafault user no need
      name: json['name'] as String? ?? '',
      relation: (json['relationship'] as String?) ?? (json['relation'] as String?) ?? '',
      dateOfBirth: dob,
      gender: json['gender'] as String? ?? '',
      bloodGroup: json['blood_group'] as String? ?? '',
      profileImage: json['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'name': name,
      'relation': relation,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'blood_group': bloodGroup,
    };
  }
}


