import 'dart:async';
import '../entities/appointment.dart';
import '../entities/banner_item.dart';
import '../entities/category_item.dart';
import '../entities/doctor.dart';

class MockApiService {
  Future<Appointment?> fetchNextAppointment() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return Appointment(
      id: 'apt_1',
      doctorName: 'Dr. A. Mukherjee',
      specialization: 'Cardiology',
      startTime: DateTime.now().add(const Duration(hours: 4)),
    );
  }

  Future<List<CategoryItem>> fetchCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const [
      CategoryItem(id: 'cat_cardio', name: 'Cardiology', icon: '❤️'),
      CategoryItem(id: 'cat_gyno', name: 'dentistry', icon: '🤰'),
      CategoryItem(id: 'cat_general', name: 'General', icon: '🩺'),
      CategoryItem(id: 'cat_derma', name: 'gastroen', icon: '🧴'),
      CategoryItem(id: 'cat_ortho', name: 'vaccination', icon: '🦴'),
      CategoryItem(id: 'cat_ent', name: 'laboratory', icon: '👂'),
      CategoryItem(id: 'cat_ent', name: 'pulmonology', icon: '👂'),
      CategoryItem(id: 'cat_ent', name: 'neurology', icon: '👂'),


    ];
  }

  Future<List<BannerItem>> fetchBanners() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const [
      BannerItem(id: 'bn_1', title: 'Heart Health Checkup', imageUrl: 'https://picsum.photos/seed/heart/800/300'),
      BannerItem(id: 'bn_2', title: 'Women Wellness Week', imageUrl: 'https://picsum.photos/seed/women/800/300'),
      BannerItem(id: 'bn_3', title: 'Monsoon Care Tips', imageUrl: 'https://picsum.photos/seed/monsoon/800/300'),
    ];
  }

  Future<List<Doctor>> fetchTopDoctors() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const [
      Doctor(
        id: 'd1',
        name: 'Dr. Riya Sharma',
        specialization: 'Cardiologist',
        imageUrl: 'https://i.pravatar.cc/150?img=47',
        rating: 4.9,
      ),
      Doctor(
        id: 'd2',
        name: 'Dr. Neeraj Gupta',
        specialization: 'General Physician',
        imageUrl: 'https://i.pravatar.cc/150?img=12',
        rating: 4.8,
      ),
      Doctor(
        id: 'd3',
        name: 'Dr. Meera Iyer',
        specialization: 'Gynecologist',
        imageUrl: 'https://i.pravatar.cc/150?img=32',
        rating: 4.9,
      ),
    ];
  }
}

