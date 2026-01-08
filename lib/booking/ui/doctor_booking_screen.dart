import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../../_shared/utils/date_time_formatter.dart';
import '../../_shared/consultation/consultation_flow_manager.dart';
import '../../_shared/components/guest_mode_handler.dart';
import '../../auth/user_management/service/auth_token_provider.dart';
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
  final c = Get.put(DoctorDetailController(), tag: 'booking');
  final bookingController = Get.put(BookingController());
  bool _isGuestMode = false;
  
  // Store the worker references for disposal
  late Worker _appointmentIdWorker;
  late Worker _bookingErrorWorker;

  @override
  void initState() {
    super.initState();
    c.load(widget.doctorId);
    bookingController.loadPricing(widget.doctorId);
    _checkGuestMode();
    
    // Listen to appointment ID changes (payment success)
    _appointmentIdWorker = ever(bookingController.appointmentId, (String? appointmentId) {
      if (appointmentId != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Get.back(); // Go back to previous screen
            ConsultationFlowManager.instance.navigateToPendingConsultation(appointmentId);
            bookingController.appointmentId.value = null; // Reset
          }
        });
      }
    });
    
    // Listen to booking error changes
    _bookingErrorWorker = ever(bookingController.bookingError, (String? error) {
      if (error != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Payment Failed'),
                content: Text(error),
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
          }
        });
      }
    });
  }

  Future<void> _checkGuestMode() async {
    final authTokenProvider = AuthTokenProvider();
    final token = await authTokenProvider.getToken();
    setState(() {
      _isGuestMode = token == null;
    });
  }

  @override
  void dispose() {
    // Dispose workers to prevent memory leaks
    _appointmentIdWorker.dispose();
    _bookingErrorWorker.dispose();
    
    // Clean up controllers
    Get.delete<DoctorDetailController>(tag: 'booking');
    super.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text('Booking Details'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),

      // ✅ Floating action button with gradient style (only show when slot is selected)
      floatingActionButton: Obx(() {
        // Guest mode handling - show sign in prompt
        if (_isGuestMode) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 56,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen,
                  AppColors.primaryGreen.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                GuestModeHandler.showGuestModePrompt(
                  context,
                  featureName: 'appointment booking',
                  customMessage: 'To book an appointment with this doctor, please sign in to your account. This helps us provide personalized healthcare services.',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.login_rounded, 
                    color: Colors.white, 
                    size: 20
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Sign In to Book Appointment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Show professional indicator when no slot is selected
        if (c.selectedSlot.value == null) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 56,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: AppColors.primaryBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Please select a time slot to continue',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        final isDisabled = bookingController.isBooking.value;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: 56,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isDisabled ? null : LinearGradient(
              colors: [
                AppColors.primaryGreen,
                AppColors.primaryGreen.withValues(alpha: 0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            color: isDisabled ? Colors.grey.shade300 : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDisabled ? [] : [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isDisabled
                ? null
                : () async {
              // Show patient selection bottom sheet first
              await _showPatientSelectionAndProceed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payment_rounded, 
                  color: isDisabled ? Colors.grey.shade600 : Colors.white, 
                  size: 20
                ),
                const SizedBox(width: 10),
                Text(
                  bookingController.pricing.value != null
                      ? 'Pay ₹${bookingController.pricing.value!.totalAmount.toStringAsFixed(0)}'
                      : 'Proceed to Payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDisabled ? Colors.grey.shade600 : Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

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
              _AvailabilitySection(controller: c, doctor: d, isGuestMode: _isGuestMode),
              const SizedBox(height: 24),
              _PaymentDetailsSection(bookingController: bookingController),
              const SizedBox(height: 100), // Space for floating button
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
  final bool isGuestMode;
  const _AvailabilitySection({required this.controller, required this.doctor, this.isGuestMode = false});

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
            child: doctor.availableDates.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'No dates available',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
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
                          isGuestMode: isGuestMode,
                          onTap: () {
                            if (!isGuestMode) {
                              controller.selectedDateIndex.value = index;
                              controller.selectedTime.value = '';
                              controller.selectedSlot.value = null;
                              controller.loadSlotsForSelectedDate();
                            } else {
                              GuestModeHandler.showGuestModePrompt(
                                context,
                                featureName: 'appointment booking',
                                customMessage: 'To select appointment slots, please sign in to your account.',
                              );
                            }
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
                Row(
                  children: [
                    Text(
                      'Available Slots',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    // Add indicator when no slot is selected
                    if (controller.selectedSlot.value == null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              size: 14,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Select one',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
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
                            isGuestMode: isGuestMode,
                            onTap: () {
                              if (!isGuestMode) {
                                controller.selectedTime.value = timeStr;
                                controller.selectedSlot.value = slot;
                              } else {
                                GuestModeHandler.showGuestModePrompt(
                                  context,
                                  featureName: 'appointment booking',
                                  customMessage: 'To select appointment slots, please sign in to your account.',
                                );
                              }
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
  final bool isGuestMode;
  final VoidCallback onTap;
  const _DateChip({required this.date, required this.isSelected, required this.onTap, this.isGuestMode = false});

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
                color: isSelected ? Colors.white : (isGuestMode ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : (isGuestMode ? Colors.grey.shade400 : Colors.black87),
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
  final bool isGuestMode;
  final VoidCallback onTap;
  const _TimeChip({required this.time, required this.isSelected, required this.onTap, this.isGuestMode = false});

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
            color: isSelected ? Colors.white : (isGuestMode ? Colors.grey.shade400 : Colors.grey.shade700),
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
