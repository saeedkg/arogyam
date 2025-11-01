import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../controller/booking_controller.dart';
import '../../find_doctor/controller/doctor_detail_controller.dart';
import '../../find_doctor/entities/doctor_detail.dart';
import '../entities/appointment_booking_request.dart';
import '../entities/booking_response.dart';
import '../../consultation_pending/ui/pending_consultation_screen.dart';

class DoctorBookingScreen extends StatefulWidget {
  final String doctorId;
  const DoctorBookingScreen({super.key, required this.doctorId});

  @override
  State<DoctorBookingScreen> createState() => _DoctorBookingScreenState();
}

class _DoctorBookingScreenState extends State<DoctorBookingScreen> {
  final c = Get.put(DoctorDetailController());
  final bookingController = Get.put(BookingController());
  String? selectedFamilyMemberId; // can be set from patient selection later

  @override
  void initState() {
    super.initState();
    c.load(widget.doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Doctor Details'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),

      // ✅ Fixed bottom button
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Obx(() => ElevatedButton(
          onPressed: c.selectedTime.value.isEmpty || bookingController.isBooking.value
              ? null
              : () async {
            final d = c.detail.value!;
            final scheduledDate = d.availableDates[c.selectedDateIndex.value];
            final slot = c.selectedTime.value;
            final dateStr = "${scheduledDate.toIso8601String().substring(0, 10)}T${_parseTimeTo24Hr(slot)}:00Z";
            final scheduledAt = DateTime.parse(dateStr).toUtc();

            final req = AppointmentBookingRequest(
              doctorId: d.id,
              scheduledAt: scheduledAt,
              type: "online",
              paymentMode: "online",
              paymentMethod: "online",
              symptoms: "Chest pain and shortness of breath",
              notes: "First consultation",
              patientId: selectedFamilyMemberId,
            );

            await bookingController.book(req);

            if (bookingController.bookingResult.value != null) {
              final result = bookingController.bookingResult.value!;
              Get.back();
              Get.to(() => PendingConsultationScreen(appointmentId: result.id));
            } else if (bookingController.bookingError.value != null) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Booking Failed"),
                  content: Text(bookingController.bookingError.value!),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close")),
                  ],
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            disabledBackgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: bookingController.isBooking.value
              ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        )),
      ),

      body: Obx(() {
        if (c.isLoading.value || c.detail.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final d = c.detail.value!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _DoctorProfileCard(d: d),
              const SizedBox(height: 24),
              _AvailabilitySection(controller: c, doctor: d),
              const SizedBox(height: 24),
              _PatientSelection(
                selectedId: selectedFamilyMemberId,
                onTap: () {
                  // TODO: Open FamilyMembers flow and set selectedFamilyMemberId
                },
              ),
              const SizedBox(height: 80), // space before bottom button
            ],
          ),
        );
      }),
    );
  }

  // Convert '09:56 AM' to '09:56'
  String _parseTimeTo24Hr(String t) {
    final reg = RegExp(r"(\d{1,2}):(\d{2}) ([AP]M)");
    final match = reg.firstMatch(t);
    if (match == null) return '09:00';
    int hour = int.parse(match.group(1)!);
    final minute = match.group(2);
    final ampm = match.group(3);
    if (ampm == 'PM' && hour != 12) hour += 12;
    if (ampm == 'AM' && hour == 12) hour = 0;
    return "${hour.toString().padLeft(2, '0')}:$minute";
  }
}

// ========================
// COMPONENTS
// ========================

class _PatientSelection extends StatelessWidget {
  final String? selectedId;
  final VoidCallback onTap;
  const _PatientSelection({this.selectedId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.person, color: AppColors.primaryGreen),
      title: Text(selectedId != null ? 'Patient $selectedId' : 'Select patient'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _DoctorProfileCard extends StatelessWidget {
  final dynamic d;
  const _DoctorProfileCard({required this.d});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(d.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.specialization,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                              const SizedBox(width: 4),
                              Text(
                                d.rating?.toString() ?? '4.8',
                                style: TextStyle(
                                  color: Colors.amber.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${d.reviews} Reviews',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailItem(
                  icon: Icons.work_outline,
                  title: '${d.experienceYears} Years',
                  color: Colors.blue.shade600,
                ),
                _DetailItem(
                  icon: Icons.place_outlined,
                  title: 'Hospital',
                  color: Colors.green.shade600,
                ),
                _DetailItem(
                  icon: Icons.attach_money_outlined,
                  title: '₹${d.fee}',
                  color: Colors.orange.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _DetailItem({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AvailabilitySection extends StatelessWidget {
  final DoctorDetailController controller;
  final dynamic doctor;
  const _AvailabilitySection({required this.controller, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date & Time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Text(
            'Available Dates',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: doctor.availableDates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final date = doctor.availableDates[index];
                return Obx(() {
                  final isSelected = controller.selectedDateIndex.value == index;
                  return _DateChip(
                    date: date,
                    isSelected: isSelected,
                    onTap: () {
                      controller.selectedDateIndex.value = index;
                      controller.selectedTime.value = '';
                    },
                  );
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Slots',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.timesForSelectedDate.map((time) {
                  final isSelected = controller.selectedTime.value == time;
                  return _TimeChip(
                    time: time,
                    isSelected: isSelected,
                    onTap: () => controller.selectedTime.value = time,
                  );
                }).toList(),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;
  const _DateChip({required this.date, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.teal : Colors.grey.shade300,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getWeekday(date.weekday),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onTap;
  const _TimeChip({required this.time, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final chipWidth = screenWidth * 0.24;
    final fontSize = screenWidth < 360 ? 12.0 : screenWidth < 400 ? 12.0 : 13.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: chipWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.teal : Colors.grey.shade300,
          ),
        ),
        child: Text(
          time,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
