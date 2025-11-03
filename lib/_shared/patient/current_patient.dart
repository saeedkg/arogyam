class CurrentPatient {
  final String id; // could be user id or family_member id
  final String name;
  final String? phone;
  final String? dateOfBirth; // yyyy-MM-dd
  final bool isPrimary; // true when it is the logged-in user

  const CurrentPatient({
    required this.id,
    required this.name,
    this.phone,
    this.dateOfBirth,
    this.isPrimary = false,
  });

  factory CurrentPatient.fromMap(Map<String, dynamic> map) {
    return CurrentPatient(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String?,
      dateOfBirth: map['date_of_birth'] as String?,
      isPrimary: map['is_primary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'is_primary': isPrimary,
    };
  }
}
