class DoctorDetail {
  final String id;
  final String name;
  final String specialization;
  final String hospital;
  final String imageUrl;
  final double rating;
  final int reviews;
  final String bio;
  final int experienceYears;
  final int fee;
  final List<DateTime> availableDates; // first 4 days
  
  // New fields from API
  final List<String>? qualifications;
  final List<String>? languages;
  final List<String>? consultationTypes;
  final List<Map<String, dynamic>>? specializations;
  final List<Map<String, dynamic>>? clinics;
  final List<Map<String, dynamic>>? hospitals;
  final String? availabilityStatus;
  final bool? availableToday;
  final int? todaySlotsCount;
  final int? totalConsultations;
  final bool? isVerified;
  final String? consultationFee;
  final String? clinicPhone; // Phone number from clinic or hospital
  final String? phoneSource; // 'clinic' or 'hospital' - indicates where phone came from

  const DoctorDetail({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.bio,
    required this.experienceYears,
    required this.fee,
    required this.availableDates,
    this.qualifications,
    this.languages,
    this.consultationTypes,
    this.specializations,
    this.clinics,
    this.hospitals,
    this.availabilityStatus,
    this.availableToday,
    this.todaySlotsCount,
    this.totalConsultations,
    this.isVerified,
    this.consultationFee,
    this.clinicPhone,
    this.phoneSource,
  });

  /// Check if doctor has instant or online consultation types available
  bool get hasInstantOrOnlineConsultation {
    return consultationTypes?.any(
      (type) => type.toLowerCase() == 'instant' || type.toLowerCase() == 'online'
    ) ?? false;
  }
  
  /// Check if phone number is available
  bool get hasPhoneNumber {
    return clinicPhone != null && clinicPhone!.isNotEmpty;
  }
  
  /// Get call button text based on phone source
  String get callButtonText {
    if (phoneSource == 'clinic') return 'Call Clinic';
    if (phoneSource == 'hospital') return 'Call Hospital';
    return 'Call';
  }
}

