import '../../_shared/ui/app_colors.dart';
import '../entities/popular_specialty.dart';
import '../entities/common_symptom.dart';
import '../entities/health_concern.dart';

/// Service class for managing care discovery data
/// Currently uses hardcoded data, but structured for easy API integration in the future
class CareDiscoveryDataService {
  /// Fetches popular specialties
  /// Returns hardcoded list of 8 most popular specialties
  /// Can be replaced with API call in future
  Future<List<PopularSpecialty>> fetchPopularSpecialties() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    return [
      PopularSpecialty(
        id: '1',
        name: 'Dentistry',
        iconPath: 'assets/icon_svg/ic_dentel.svg',
        backgroundColor: AppColors.peach,
      ),
      PopularSpecialty(
        id: '2',
        name: 'Cardiology',
        iconPath: 'assets/icon_svg/ic_cardio.svg',
        backgroundColor: AppColors.roseDust,
      ),
      PopularSpecialty(
        id: '3',
        name: 'Pulmonology',
        iconPath: 'assets/icon_svg/ic_pulmanology.svg',
        backgroundColor: AppColors.sageGreen,
      ),
      PopularSpecialty(
        id: '4',
        name: 'General Medicine',
        iconPath: 'assets/icon_svg/ic_general.svg',
        backgroundColor: AppColors.blueBell,
      ),
      PopularSpecialty(
        id: '5',
        name: 'Neurology',
        iconPath: 'assets/icon_svg/ic_neurology.svg',
        backgroundColor: AppColors.mediumSkyBlue,
      ),
      PopularSpecialty(
        id: '6',
        name: 'Gastroenterology',
        iconPath: 'assets/icon_svg/ic_gastrom.svg',
        backgroundColor: AppColors.teal,
      ),
      PopularSpecialty(
        id: '7',
        name: 'Orthopedics',
        iconPath: 'assets/icon_svg/ic_general.svg',
        backgroundColor: AppColors.blush,
      ),
      PopularSpecialty(
        id: '8',
        name: 'Dermatology',
        iconPath: 'assets/icon_svg/ic_general.svg',
        backgroundColor: AppColors.deepPurple,
      ),
    ];
  }

  /// Fetches common symptoms
  /// Returns hardcoded list of 8 common symptoms
  /// Can be replaced with API call in future
  Future<List<CommonSymptom>> fetchCommonSymptoms() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    return [
      CommonSymptom(
        id: '1',
        name: 'Fever',
        description: 'High temperature & chills',
        iconPath: 'assets/icon_svg/ic_general.svg',
        backgroundColor: AppColors.warningOrange.withValues(alpha: 0.1),
        iconColor: AppColors.warningOrange,
        relatedSpecialties: ['General Medicine', 'Internal Medicine'],
      ),
      CommonSymptom(
        id: '2',
        name: 'Cough',
        description: 'Persistent coughing',
        iconPath: 'assets/icon_svg/ic_pulmanology.svg',
        backgroundColor: AppColors.mediumSkyBlue.withValues(alpha: 0.1),
        iconColor: AppColors.mediumSkyBlue,
        relatedSpecialties: ['Pulmonology', 'General Medicine'],
      ),
      CommonSymptom(
        id: '3',
        name: 'Headache',
        description: 'Head pain & migraines',
        iconPath: 'assets/icon_svg/ic_neurology.svg',
        backgroundColor: AppColors.deepPurple.withValues(alpha: 0.1),
        iconColor: AppColors.deepPurple,
        relatedSpecialties: ['Neurology', 'General Medicine'],
      ),
      CommonSymptom(
        id: '4',
        name: 'Stomach Pain',
        description: 'Abdominal discomfort',
        iconPath: 'assets/icon_svg/ic_gastrom.svg',
        backgroundColor: AppColors.peach.withValues(alpha: 0.1),
        iconColor: AppColors.peach,
        relatedSpecialties: ['Gastroenterology', 'General Medicine'],
      ),
      CommonSymptom(
        id: '5',
        name: 'Back Pain',
        description: 'Lower or upper back pain',
        iconPath: 'assets/icon_svg/ic_general.svg',
        backgroundColor: AppColors.roseDust.withValues(alpha: 0.1),
        iconColor: AppColors.roseDust,
        relatedSpecialties: ['Orthopedics', 'General Medicine'],
      ),
      CommonSymptom(
        id: '6',
        name: 'Skin Issues',
        description: 'Rashes, itching & allergies',
        iconPath: 'assets/icon_svg/ic_general.svg',
        backgroundColor: AppColors.blush.withValues(alpha: 0.1),
        iconColor: AppColors.blush,
        relatedSpecialties: ['Dermatology'],
      ),
      CommonSymptom(
        id: '7',
        name: 'Chest Pain',
        description: 'Chest discomfort',
        iconPath: 'assets/icon_svg/ic_cardio.svg',
        backgroundColor: AppColors.errorRed.withValues(alpha: 0.1),
        iconColor: AppColors.errorRed,
        relatedSpecialties: ['Cardiology', 'General Medicine'],
      ),
      CommonSymptom(
        id: '8',
        name: 'Fatigue',
        description: 'Tiredness & low energy',
        iconPath: 'assets/icon_svg/ic_general.svg',
        backgroundColor: AppColors.sageGreen.withValues(alpha: 0.1),
        iconColor: AppColors.sageGreen,
        relatedSpecialties: ['General Medicine', 'Internal Medicine'],
      ),
    ];
  }

  /// Fetches health concerns by body part/system
  /// Returns hardcoded list of 12 health concern categories
  /// Can be replaced with API call in future
  Future<List<HealthConcern>> fetchHealthConcerns() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    return [
      HealthConcern(
        id: '1',
        name: 'Heart & Circulation',
        subtitle: 'Cardiology',
        iconPath: 'assets/icon_svg/ic_cardio.svg',
        primaryColor: AppColors.roseDust,
        relatedSpecialty: 'Cardiology',
      ),
      HealthConcern(
        id: '2',
        name: 'Digestive System',
        subtitle: 'Gastroenterology',
        iconPath: 'assets/icon_svg/ic_gastrom.svg',
        primaryColor: AppColors.peach,
        relatedSpecialty: 'Gastroenterology',
      ),
      HealthConcern(
        id: '3',
        name: 'Respiratory System',
        subtitle: 'Pulmonology',
        iconPath: 'assets/icon_svg/ic_pulmanology.svg',
        primaryColor: AppColors.mediumSkyBlue,
        relatedSpecialty: 'Pulmonology',
      ),
      HealthConcern(
        id: '4',
        name: 'Bones & Joints',
        subtitle: 'Orthopedics',
        iconPath: 'assets/icon_svg/ic_general.svg',
        primaryColor: AppColors.sageGreen,
        relatedSpecialty: 'Orthopedics',
      ),
      HealthConcern(
        id: '5',
        name: 'Skin & Hair',
        subtitle: 'Dermatology',
        iconPath: 'assets/icon_svg/ic_general.svg',
        primaryColor: AppColors.blush,
        relatedSpecialty: 'Dermatology',
      ),
      HealthConcern(
        id: '6',
        name: 'Mental Health',
        subtitle: 'Psychiatry',
        iconPath: 'assets/icon_svg/ic_neurology.svg',
        primaryColor: AppColors.deepPurple,
        relatedSpecialty: 'Psychiatry',
      ),
      HealthConcern(
        id: '7',
        name: 'Women\'s Health',
        subtitle: 'Gynecology',
        iconPath: 'assets/icon_svg/ic_general.svg',
        primaryColor: AppColors.roseDust,
        relatedSpecialty: 'Gynecology',
      ),
      HealthConcern(
        id: '8',
        name: 'Children\'s Health',
        subtitle: 'Pediatrics',
        iconPath: 'assets/icon_svg/ic_general.svg',
        primaryColor: AppColors.blueBell,
        relatedSpecialty: 'Pediatrics',
      ),
      HealthConcern(
        id: '9',
        name: 'Eye Care',
        subtitle: 'Ophthalmology',
        iconPath: 'assets/icon_svg/ic_general.svg',
        primaryColor: AppColors.mediumSkyBlue,
        relatedSpecialty: 'Ophthalmology',
      ),
      HealthConcern(
        id: '10',
        name: 'Dental Care',
        subtitle: 'Dentistry',
        iconPath: 'assets/icon_svg/ic_dentel.svg',
        primaryColor: AppColors.peach,
        relatedSpecialty: 'Dentistry',
      ),
      HealthConcern(
        id: '11',
        name: 'Ear Nose Throat',
        subtitle: 'ENT',
        iconPath: 'assets/icon_svg/ic_general.svg',
        primaryColor: AppColors.teal,
        relatedSpecialty: 'ENT',
      ),
      HealthConcern(
        id: '12',
        name: 'General Health',
        subtitle: 'General Medicine',
        iconPath: 'assets/icon_svg/ic_general.svg',
        primaryColor: AppColors.sageGreen,
        relatedSpecialty: 'General Medicine',
      ),
    ];
  }
}
