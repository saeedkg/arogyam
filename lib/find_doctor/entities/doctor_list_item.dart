class DoctorListItem {
  final String id;
  final String name;
  final String specialization;
  final String hospital;
  final String imageUrl;
  final double rating;
  final int reviews;
  final bool favorite;
  final bool isOnline;
  final int experience;
  final String education;
  final String consultationFee;
  final bool availableToday;
  final List<String> consultationTypes;
  final String? clinicPhone; // Phone number from clinic or hospital
  final String? phoneSource; // 'clinic' or 'hospital' - indicates where phone came from

  const DoctorListItem({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    this.favorite = false,
    this.isOnline = true,
    this.experience = 5,
    required this.education,
    required this.consultationFee,
    this.availableToday = true,
    this.consultationTypes = const [],
    this.clinicPhone,
    this.phoneSource,
  });

  // Helper method to check if instant or online consultation is available
  bool get hasInstantOrOnlineConsultation {
    return consultationTypes.contains('instant') || consultationTypes.contains('online');
  }
  
  // Helper method to check if phone number is available
  bool get hasPhoneNumber {
    return clinicPhone != null && clinicPhone!.isNotEmpty;
  }
  
  // Helper method to get call button text
  String get callButtonText {
    if (phoneSource == 'clinic') return 'Call Clinic';
    if (phoneSource == 'hospital') return 'Call Hospital';
    return 'Call';
  }
}

