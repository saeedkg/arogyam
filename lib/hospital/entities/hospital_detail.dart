class HospitalDetail {
  final int id;
  final String slug;
  final String name;
  final String registrationNumber;
  final String type;
  final String? description;
  final HospitalContact contact;
  final HospitalAddress address;
  final HospitalMedia media;
  final HospitalFacilities facilities;
  final HospitalVerification verification;
  final List<HospitalDepartment> departments;
  final List<HospitalDoctor> doctors;
  final HospitalStatistics statistics;

  HospitalDetail({
    required this.id,
    required this.slug,
    required this.name,
    required this.registrationNumber,
    required this.type,
    this.description,
    required this.contact,
    required this.address,
    required this.media,
    required this.facilities,
    required this.verification,
    required this.departments,
    required this.doctors,
    required this.statistics,
  });

  factory HospitalDetail.fromJson(Map<String, dynamic> json) {
    return HospitalDetail(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
      type: json['type'] ?? '',
      description: json['description'],
      contact: HospitalContact.fromJson(json['contact'] ?? {}),
      address: HospitalAddress.fromJson(json['address'] ?? {}),
      media: HospitalMedia.fromJson(json['media'] ?? {}),
      facilities: HospitalFacilities.fromJson(json['facilities'] ?? {}),
      verification: HospitalVerification.fromJson(json['verification'] ?? {}),
      departments: (json['departments'] as List<dynamic>?)
          ?.map((dept) => HospitalDepartment.fromJson(dept))
          .toList() ?? [],
      doctors: (json['doctors'] as List<dynamic>?)
          ?.map((doctor) => HospitalDoctor.fromJson(doctor))
          .toList() ?? [],
      statistics: HospitalStatistics.fromJson(json['statistics'] ?? {}),
    );
  }
}

class HospitalContact {
  final String? phone;
  final String? email;
  final String? website;

  HospitalContact({
    this.phone,
    this.email,
    this.website,
  });

  factory HospitalContact.fromJson(Map<String, dynamic> json) {
    return HospitalContact(
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
    );
  }
}

class HospitalAddress {
  final String fullAddress;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final double? latitude;
  final double? longitude;

  HospitalAddress({
    required this.fullAddress,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    this.latitude,
    this.longitude,
  });

  factory HospitalAddress.fromJson(Map<String, dynamic> json) {
    return HospitalAddress(
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

class HospitalMedia {
  final String? logoUrl;
  final String? primaryImage;
  final List<String> images;

  HospitalMedia({
    this.logoUrl,
    this.primaryImage,
    required this.images,
  });

  factory HospitalMedia.fromJson(Map<String, dynamic> json) {
    return HospitalMedia(
      logoUrl: json['logo_url'],
      primaryImage: json['primary_image'],
      images: (json['images'] as List<dynamic>?)
          ?.map((img) => img.toString())
          .toList() ?? [],
    );
  }
}

class HospitalFacilities {
  final int? totalBeds;
  final int? icuBeds;
  final List<String> servicesOffered;
  final List<String> facilities;
  final List<String> accreditations;

  HospitalFacilities({
    this.totalBeds,
    this.icuBeds,
    required this.servicesOffered,
    required this.facilities,
    required this.accreditations,
  });

  factory HospitalFacilities.fromJson(Map<String, dynamic> json) {
    return HospitalFacilities(
      totalBeds: json['total_beds'],
      icuBeds: json['icu_beds'],
      servicesOffered: (json['services_offered'] as List<dynamic>?)
          ?.map((service) => service.toString())
          .toList() ?? [],
      facilities: (json['facilities'] as List<dynamic>?)
          ?.map((facility) => facility.toString())
          .toList() ?? [],
      accreditations: (json['accreditations'] as List<dynamic>?)
          ?.map((accred) => accred.toString())
          .toList() ?? [],
    );
  }
}

class HospitalVerification {
  final bool isVerified;
  final String? verifiedAt;

  HospitalVerification({
    required this.isVerified,
    this.verifiedAt,
  });

  factory HospitalVerification.fromJson(Map<String, dynamic> json) {
    return HospitalVerification(
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'],
    );
  }
}

class HospitalDepartment {
  final int id;
  final String name;
  final String? description;

  HospitalDepartment({
    required this.id,
    required this.name,
    this.description,
  });

  factory HospitalDepartment.fromJson(Map<String, dynamic> json) {
    return HospitalDepartment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

class HospitalDoctor {
  final int id;
  final String slug;
  final String name;
  final String? profilePhotoUrl;
  final List<String> qualifications;
  final int experience;
  final String consultationFee;
  final String averageRating;
  final int totalRatings;
  final List<String> languages;
  final List<HospitalDoctorSpecialization> specializations;
  final String associationType;
  final String designation;

  HospitalDoctor({
    required this.id,
    required this.slug,
    required this.name,
    this.profilePhotoUrl,
    required this.qualifications,
    required this.experience,
    required this.consultationFee,
    required this.averageRating,
    required this.totalRatings,
    required this.languages,
    required this.specializations,
    required this.associationType,
    required this.designation,
  });

  factory HospitalDoctor.fromJson(Map<String, dynamic> json) {
    return HospitalDoctor(
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
      languages: (json['languages'] as List<dynamic>?)
          ?.map((lang) => lang.toString())
          .toList() ?? [],
      specializations: (json['specializations'] as List<dynamic>?)
          ?.map((spec) => HospitalDoctorSpecialization.fromJson(spec))
          .toList() ?? [],
      associationType: json['association_type'] ?? '',
      designation: json['designation'] ?? '',
    );
  }
}

class HospitalDoctorSpecialization {
  final int id;
  final String name;
  final bool isPrimary;

  HospitalDoctorSpecialization({
    required this.id,
    required this.name,
    required this.isPrimary,
  });

  factory HospitalDoctorSpecialization.fromJson(Map<String, dynamic> json) {
    return HospitalDoctorSpecialization(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      isPrimary: json['is_primary'] == 1,
    );
  }
}

class HospitalStatistics {
  final int totalDoctors;
  final int totalDepartments;
  final int activeDepartments;
  final int emergencyDepartments;

  HospitalStatistics({
    required this.totalDoctors,
    required this.totalDepartments,
    required this.activeDepartments,
    required this.emergencyDepartments,
  });

  factory HospitalStatistics.fromJson(Map<String, dynamic> json) {
    return HospitalStatistics(
      totalDoctors: json['total_doctors'] ?? 0,
      totalDepartments: json['total_departments'] ?? 0,
      activeDepartments: json['active_departments'] ?? 0,
      emergencyDepartments: json['emergency_departments'] ?? 0,
    );
  }
}