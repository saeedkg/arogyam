import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../../_shared/utils/date_time_formatter.dart';
import '../../_shared/consultation/consultation_flow_manager.dart';
import '../controller/booking_controller.dart';
import '../../find_doctor/controller/doctor_detail_controller.dart';
import '../entities/appointment_booking_request.dart';
import '../../family_member/ui/family_member_screen.dart';
import 'components/doctor_details_popup.dart';

class DoctorBookingScreen extends StatefulWidget {
  final String doctorId;
  const DoctorBookingScreen({super.key, required this.doctorId});

  @override
  State<DoctorBookingScreen> createState() => _DoctorBookingScreenState();
}

class _DoctorBookingScreenState extends State<DoctorBookingScreen> {
  final c = Get.put(DoctorDetailController());
  final bookingController = Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    c.load(widget.doctorId);
    bookingController.loadPricing(widget.doctorId);
  }

  Future<void> _showPatientSelectionAndProceed() async {
    // Show patient selection bottom sheet
    final selectedPatientId = await Get.bottomSheet<String>(
      const FamilyMembersBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
    );

    // If a patient was selected, proceed with payment
    if (selectedPatientId != null) {
      final d = c.detail.value!;
      final selectedSlot = c.selectedSlot.value!;
      final scheduledAt = selectedSlot.dateTimeString;

      // Initiate Razorpay payment
      await bookingController.initiatePayment(
        doctorId: d.id,
        scheduledAt: scheduledAt,
        familyMemberId: selectedPatientId,
        patientNotes: "First consultation",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Booking Details'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),

      // ✅ Fixed bottom button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(() {
            // Listen to appointment ID changes (payment success)
            if (bookingController.appointmentId.value != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final apptId = bookingController.appointmentId.value!;
                Get.back(); // Go back to previous screen
                ConsultationFlowManager.instance.navigateToPendingConsultation(apptId);
                bookingController.appointmentId.value = null; // Reset
              });
            }
            
            // Listen to booking error changes
            if (bookingController.bookingError.value != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Payment Failed'),
                    content: Text(bookingController.bookingError.value!),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          bookingController.bookingError.value = null; // Reset
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              });
            }
            
            return ElevatedButton(
              onPressed: c.selectedSlot.value == null || bookingController.isBooking.value
                  ? null
                  : () async {
                // Show patient selection bottom sheet first
                await _showPatientSelectionAndProceed();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
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
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bookingController.pricing.value != null
                        ? 'Pay ₹${bookingController.pricing.value!.totalAmount}'
                        : 'Proceed to Payment',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // if (bookingController.pricing.value != null)
                  //   Text(
                  //     'Proceed to Payment',
                  //     style: TextStyle(
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.w400,
                  //       color: Colors.white.withOpacity(0.9),
                  //     ),
                  //   ),
                ],
              ),
            );
          }),
        ),
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
              _PaymentDetailsSection(bookingController: bookingController),
              const SizedBox(height: 100), // space before bottom button
            ],
          ),
        );
      }),
    );
  }
}

// ========================
// COMPONENTS
// ========================



class _DoctorProfileCard extends StatelessWidget {
  final dynamic d;
  const _DoctorProfileCard({required this.d});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => DoctorDetailsPopup.show(context, d),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Doctor image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(d.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Doctor info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    d.specialization,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Only show rating, no price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.amber.shade700),
                        const SizedBox(width: 2),
                        Text(
                          d.rating?.toString() ?? '4.8',
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tap indicator
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
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
            color: color.withValues(alpha: 0.1),
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
            color: Colors.black.withValues(alpha: 0.05),
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
                      controller.selectedSlot.value = null;
                      controller.loadSlotsForSelectedDate();
                    },
                  );
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoadingSlots.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return Column(
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
                controller.timesForSelectedDate.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No slots available for this date',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.availableSlots.map((slot) {
                          final isSelected = controller.selectedSlot.value?.datetime == slot.datetime;
                          final timeStr = DateTimeFormatter.formatTime(slot.datetime, isUtc: true);
                          return _TimeChip(
                            time: timeStr,
                            isSelected: isSelected,
                            onTap: () {
                              controller.selectedTime.value = timeStr;
                              controller.selectedSlot.value = slot;
                            },
                          );
                        }).toList(),
                      ),
              ],
            );
          }),
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
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
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
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
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

class _PaymentDetailsSection extends StatelessWidget {
  final BookingController bookingController;
  const _PaymentDetailsSection({required this.bookingController});

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
            'Payment Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (bookingController.isPricingLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              );
            }

            final pricing = bookingController.pricing.value;
            if (pricing == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Unable to load pricing'),
                ),
              );
            }

            return Column(
              children: [
                _buildFeeRow(
                  'Consultation Fee',
                  '₹${pricing.consultationFee.toStringAsFixed(2)}',
                ),
                const Divider(height: 24, thickness: 1),
                _buildFeeRow(
                  'Platform Fee (${pricing.platformFeePercentage.toStringAsFixed(0)}%)',
                  '₹${pricing.platformFee.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen.withOpacity(0.1),
                        AppColors.primaryGreen.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      Text(
                        '₹${pricing.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
