import 'dart:async';
import '../../appointment/entities/appointment.dart';
import '../entities/banner_item.dart';
import '../entities/category_item.dart';
import '../entities/doctor.dart';
import '../../find_doctor/entities/doctor_list_item.dart';
import '../entities/booking.dart';
import '../../appointment/entities/booking_detail.dart';

class MockApiService {
  Future<Appointment?> fetchNextAppointment() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return Appointment(
      id: 1,
      doctorName: 'Dr. A. Mukherjee',
      doctorImage: 'https://i.pravatar.cc/150?img=12',
      specialization: 'Cardiology',
      scheduledAt: DateTime.now().add(const Duration(hours: 4)),
      status: 'upcoming',
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

  Future<List<DoctorListItem>> fetchDoctorsList() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const [
      DoctorListItem(
        id: 'dl1',
        name: 'Dr. David Patel',
        specialization: 'Cardiologist',
        hospital: 'Cardiology Center, USA',
        imageUrl: 'https://i.pravatar.cc/150?img=14',
        rating: 5.0,
        reviews: 1872,
        favorite: false,
      ),
      DoctorListItem(
        id: 'dl2',
        name: 'Dr. Jessica Turner',
        specialization: 'Gynecologist',
        hospital: "Women's Clinic, Seattle, USA",
        imageUrl: 'https://i.pravatar.cc/150?img=49',
        rating: 4.9,
        reviews: 127,
        favorite: false,
      ),
      DoctorListItem(
        id: 'dl3',
        name: 'Dr. Michael Johnson',
        specialization: 'Orthopedic Surgery',
        hospital: 'Maple Associates, NY, USA',
        imageUrl: 'https://i.pravatar.cc/150?img=36',
        rating: 4.7,
        reviews: 5223,
        favorite: true,
      ),
      DoctorListItem(
        id: 'dl4',
        name: 'Dr. Emily Walker',
        specialization: 'Pediatrics',
        hospital: 'Serenity Pediatrics Clinic',
        imageUrl: 'https://i.pravatar.cc/150?img=5',
        rating: 5.0,
        reviews: 405,
        favorite: false,
      ),
    ];
  }

  Future<List<BookingItem>> fetchBookings(String status) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    final list = [
      BookingItem(
        id: 'b1',
        doctorName: 'Dr. James Robinson',
        specialization: 'Orthopedic Surgery',
        clinic: 'Elite Ortho Clinic, USA',
        imageUrl: 'https://i.pravatar.cc/150?img=40',
        dateTime: now.add(const Duration(days: 2)),
        status: 'upcoming',
      ),
      BookingItem(
        id: 'b2',
        doctorName: 'Dr. Daniel Lee',
        specialization: 'Gastroenterologist',
        clinic: 'Digestive Institute, USA',
        imageUrl: 'https://i.pravatar.cc/150?img=25',
        dateTime: now.add(const Duration(days: 10)),
        status: 'upcoming',
      ),
      BookingItem(
        id: 'b3',
        doctorName: 'Dr. Nathan Harris',
        specialization: 'Cardiologist',
        clinic: 'Cardiology Center, USA',
        imageUrl: 'https://i.pravatar.cc/150?img=11',
        dateTime: now.subtract(const Duration(days: 5)),
        status: 'completed',
      ),
    ];
    return list.where((e) => e.status == status).toList();
  }

  Future<BookingDetail> fetchBookingDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final now = DateTime.now().add(const Duration(days: 3));
    return BookingDetail(
      id: id,
      doctorName: 'Dr. Sarah Lee',
      specialization: 'Cardiologist',
      hospital: 'City General Hospital',
      imageUrl: 'https://i.pravatar.cc/150?img=28',
      startTime: DateTime(now.year, now.month, now.day, 10, 0),
      endTime: DateTime(now.year, now.month, now.day, 10, 30),
      status: 'Confirmed',
      prescriptionAvailable: true,
      prescriptionUrl: 'https://example.com/prescription_dr_sarah_lee_20241123.pdf',
      amountPaid: 800.0,
      paymentStatus: 'Paid',
      transactionId: 'TXN-0123456789',
    );
  }
}

