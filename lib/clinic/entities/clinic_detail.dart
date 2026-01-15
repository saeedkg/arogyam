class ClinicDetail {
  final int id;
  final String slug;
  final String name;
  final String registrationNumber;
  final String? description;
  final bool hasValidSubscription;
  final ClinicContact contact;
  final ClinicAddress address;
  final ClinicMedia media;
  final ClinicFacilities facilities;
  final Map<String, ClinicOperatingHours?> operatingHours;
  final bool isCurrentlyOpen;
  final ClinicVerification verification;
  final List<ClinicDoctor> doctors;
  final ClinicStatistics statistics;
  final String createdAt;
  final String updatedAt;

  ClinicDetail({
    required this.id,
    required this.slug,
    required this.name,
    required this.registrationNumber,
    this.description,
    required this.hasValidSubscription,
    required this.contact,
    required this.address,
    required this.media,
    required this.facilities,
    required this.operatingHours,
    required this.isCurrentlyOpen,
    required this.verification,
    required this.doctors,
    required this.statistics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClinicDetail.fromJson(Map<String, dynamic> json) {
    return ClinicDetail(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
      description: json['description'],
      hasValidSubscription: json['has_valid_subscription'] ?? false,
      contact: ClinicContact.fromJson(json['contact'] ?? {}),
      address: ClinicAddress.fromJson(json['address'] ?? {}),
      media: ClinicMedia.fromJson(json['media'] ?? {}),
      facilities: ClinicFacilities.fromJson(json['facilities'] ?? {}),
      operatingHours: _parseOperatingHours(json['operating_hours'] ?? {}),
      isCurrentlyOpen: json['is_currently_open'] ?? false,
      verification: ClinicVerification.fromJson(json['verification'] ?? {}),
      doctors: (json['doctors'] as List<dynamic>?)
          ?.map((doctor) => ClinicDoctor.fromJson(doctor))
          .toList() ?? [],
      statistics: ClinicStatistics.fromJson(json['statistics'] ?? {}),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  static Map<String, ClinicOperatingHours?> _parseOperatingHours(Map<String, dynamic> hours) {
    final result = <String, ClinicOperatingHours?>{};
    hours.forEach((day, value) {
      if (value == null) {
        result[day] = null;
      } else if (value is Map<String, dynamic>) {
        result[day] = ClinicOperatingHours.fromJson(value);
      }
    });
    return result;
  }
}

class ClinicContact {
  final String? phone;
  final String? email;
  final String? website;

  ClinicContact({
    this.phone,
    this.email,
    this.website,
  });

  factory ClinicContact.fromJson(Map<String, dynamic> json) {
    return ClinicContact(
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
    );
  }
}

class ClinicAddress {
  final String fullAddress;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final double? latitude;
  final double? longitude;

  ClinicAddress({
    required this.fullAddress,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    this.latitude,
    this.longitude,
  });

  factory ClinicAddress.fromJson(Map<String, dynamic> json) {
    return ClinicAddress(
      fullAddress: json['full_address'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

class ClinicMedia {
  final String? logoUrl;
  final String? primaryImage;
  final List<String> images;

  ClinicMedia({
    this.logoUrl,
    this.primaryImage,
    required this.images,
  });

  factory ClinicMedia.fromJson(Map<String, dynamic> json) {
    return ClinicMedia(
      logoUrl: json['logo_url'],
      primaryImage: json['primary_image'],
      images: (json['images'] as List<dynamic>?)
          ?.map((img) => img.toString())
          .toList() ?? [],
    );
  }
}

class ClinicFacilities {
  final List<String> servicesOffered;
  final List<String> facilities;

  ClinicFacilities({
    required this.servicesOffered,
    required this.facilities,
  });

  factory ClinicFacilities.fromJson(Map<String, dynamic> json) {
    return ClinicFacilities(
      servicesOffered: (json['services_offered'] as List<dynamic>?)
          ?.map((service) => service.toString())
          .toList() ?? [],
      facilities: (json['facilities'] as List<dynamic>?)
          ?.map((facility) => facility.toString())
          .toList() ?? [],
    );
  }
}

class ClinicOperatingHours {
  final String open;
  final String close;

  ClinicOperatingHours({
    required this.open,
    required this.close,
  });

  factory ClinicOperatingHours.fromJson(Map<String, dynamic> json) {
    return ClinicOperatingHours(
      open: json['open'] ?? '',
      close: json['close'] ?? '',
    );
  }
}

class ClinicVerification {
  final bool isVerified;
  final String? verifiedAt;

  ClinicVerification({
    required this.isVerified,
    this.verifiedAt,
  });

  factory ClinicVerification.fromJson(Map<String, dynamic> json) {
    return ClinicVerification(
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'],
    );
  }
}

class ClinicDoctor {
  final int id;
  final String slug;
  final String name;
  final String? profilePhotoUrl;
  final List<String> qualifications;
  final int experience;
  final String consultationFee;
  final String averageRating;
  final int totalRatings;
  final int totalConsultations;
  final List<String> languages;
  final String bio;
  final List<ClinicDoctorSpecialization> specializations;
  final String associationType;
  final List<String> availableDays;
  final List<String> availableHours;
  final String? consultationFeeOverride;

  ClinicDoctor({
    required this.id,
    required this.slug,
    required this.name,
    this.profilePhotoUrl,
    required this.qualifications,
    required this.experience,
    required this.consultationFee,
    required this.averageRating,
    required this.totalRatings,
    required this.totalConsultations,
    required this.languages,
    required this.bio,
    required this.specializations,
    required this.associationType,
    required this.availableDays,
    required this.availableHours,
    this.consultationFeeOverride,
  });

  factory ClinicDoctor.fromJson(Map<String, dynamic> json) {
    return ClinicDoctor(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      profilePhotoUrl: json['profile_photo_url'],
      qualifications: (json['qualifications'] as List<dynamic>?)
          ?.map((qual) => qual.toString())
          .toList() ?? [],
      experience: json['experience'] ?? 0,
      consultationFee: json['consultation_fee'] ?? '0',
      averageRating: json['average_rating'] ?? '0.0',
      totalRatings: json['total_ratings'] ?? 0,
      totalConsultations: json['total_consultations'] ?? 0,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((lang) => lang.toString())
          .toList() ?? [],
      bio: json['bio'] ?? '',
      specializations: (json['specializations'] as List<dynamic>?)
          ?.map((spec) => ClinicDoctorSpecialization.fromJson(spec))
          .toList() ?? [],
      associationType: json['association_type'] ?? '',
      availableDays: (json['available_days'] as List<dynamic>?)
          ?.map((day) => day.toString())
          .toList() ?? [],
      availableHours: (json['available_hours'] as List<dynamic>?)
          ?.map((hour) => hour.toString())
          .toList() ?? [],
      consultationFeeOverride: json['consultation_fee_override'],
    );
  }
}

class ClinicDoctorSpecialization {
  final int id;
  final String name;
  final bool isPrimary;

  ClinicDoctorSpecialization({
    required this.id,
    required this.name,
    required this.isPrimary,
  });

  factory ClinicDoctorSpecialization.fromJson(Map<String, dynamic> json) {
    return ClinicDoctorSpecialization(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      isPrimary: json['is_primary'] == 1,
    );
  }
}

class ClinicStatistics {
  final int totalDoctors;

  ClinicStatistics({
    required this.totalDoctors,
  });

  factory ClinicStatistics.fromJson(Map<String, dynamic> json) {
    return ClinicStatistics(
      totalDoctors: json['total_doctors'] ?? 0,
    );
  }
}
