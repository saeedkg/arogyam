import '../entities/doctor_detail.dart';

class DoctorBookingService {
  Future<DoctorDetail> fetchDoctorDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final now = DateTime.now();
    final days = List<DateTime>.generate(4, (i) => DateTime(now.year, now.month, now.day + i));
    final slots = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM'];
    return DoctorDetail(
      id: id,
      name: 'Dr. Priya Sharma',
      specialization: 'Cardiologist',
      hospital: 'Apollo Hospitals, New Delhi',
      imageUrl: 'https://i.pravatar.cc/150?img=48',
      rating: 4.8,
      reviews: 1200,
      bio: 'Dr. Priya Sharma is a highly experienced Cardiologist with a passion for patient care and advanced cardiac treatments. She has a proven track record in complex procedures and preventative heart health.',
      experienceYears: 12,
      fee: 1200,
      availableDates: days,
      timeSlots: {
        for (final d in days) _key(d): List<String>.from(slots)
      },
    );
  }

  Future<bool> confirmBooking({required String doctorId, required DateTime date, required String timeSlot}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return true;
  }

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';
}

