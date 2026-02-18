import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/routing/routing.dart';
import '../../_shared/ui/app_colors.dart';
import '../../appointment/components/patient_card.dart';
import '../controller/instant_consult_controller.dart';
import '../entities/instant_doctor.dart';
import 'doctors_selection_bottom_sheet.dart';
import '../../_shared/patient/current_patient_controller.dart';
import '../../consultation_pending/ui/pending_consultation_screen.dart';

class InstantConsultScreen extends StatelessWidget {
  const InstantConsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(InstantConsultController());
    final currentPatientController = Get.put(CurrentPatientController());
    final controller = Get.find<InstantConsultController>();
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Instant Consult',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Get.back(), // Return true to indicate refresh needed
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: GetBuilder<InstantConsultController>(
        builder: (controller) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    Text(
                      'Available Doctors',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Horizontal Doctors List
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const SizedBox(
                          height: 140,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return SizedBox(
                        height: 153,
                        child: controller.availableDoctors.isEmpty
                            ? Center(
                                child: Text(
                                  'No doctors available at the moment',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.availableDoctors.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, i) {
                                  final doctor = controller.availableDoctors[i];
                                  return _InstantDoctorCard(doctor: doctor);
                                },
                              ),
                      );
                    }),
                    const SizedBox(height: 32),
                    // Patient Card
                    Obx(() {
                      final p = currentPatientController.current.value;
                      return PatientCard(
                        name: p?.name ?? 'Patient',
                        dob: p?.dateOfBirth ?? '',
                        id: p?.id ?? '',
                        imageUrl: 'https://i.pravatar.cc/150?img=65',
                        onChange: () {
                          AppNavigation.toFamilyMembers();
                          Future.delayed(const Duration(milliseconds: 300), () {
                            currentPatientController.refreshFromPrefs();
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 32),
                    // Payment Details Section
                    Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (controller.isPricingLoading.value) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade100, width: 1.5),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        );
                      }

                      final pricing = controller.pricing.value;
                      if (pricing == null) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade100, width: 1.5),
                          ),
                          child: const Center(
                            child: Text('Unable to load pricing'),
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildFeeRow(
                              'Consultation Fee',
                              '₹${pricing.consultationFee.toStringAsFixed(2)}',
                              isBold: false,
                            ),
                            const Divider(height: 32, thickness: 1.2),
                            _buildFeeRow(
                              'Platform Fee (${pricing.platformFeePercentage.toStringAsFixed(0)}%)',
                              '₹${pricing.platformFee.toStringAsFixed(2)}',
                              isBold: false,
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
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Bottom Button - Hide when loading, Refresh when no doctors, Proceed when doctors available
            Obx(() {
              // Hide button completely when loading
              if (controller.isLoading.value) {
                return const SizedBox.shrink();
              }
              
              if (controller.availableDoctors.isEmpty) {
                // Show professional refresh section when no doctors available
                return Container(
                  padding: const EdgeInsets.all(20),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Professional message
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'All doctors are currently busy. Please try refreshing to check for availability.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Professional refresh button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              controller.loadAvailableDoctors();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Check for Available Doctors',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              // Show proceed button when doctors are available
              return Container(
              padding: const EdgeInsets.all(20),
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
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Obx(() {
                    // Listen to appointment ID changes (payment success)
                    if (controller.appointmentId.value != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final apptId = controller.appointmentId.value!;
                        Get.to(() => PendingConsultationScreen(appointmentId: apptId));
                        controller.appointmentId.value = null; // Reset
                      });
                    }
                    
                    // Listen to booking error changes
                    if (controller.bookingError.value != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Payment Failed'),
                            content: Text(controller.bookingError.value!),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  controller.bookingError.value = null; // Reset
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      });
                    }
                    
                    return ElevatedButton(
                      onPressed: controller.isBooking.value
                          ? null
                          : () async {
                              if (controller.availableDoctors.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No doctors available right now')),
                                );
                                return;
                              }

                              // Initiate Razorpay payment
                              await controller.initiatePayment();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isBooking.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Proceed to Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    );
                  }),
                ),
              ) );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String amount, {required bool isBold}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _InstantDoctorCard extends StatelessWidget {
  final InstantDoctor doctor;

  const _InstantDoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          const DoctorsSelectionBottomSheet(),
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
        );
      },
      child: Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Doctor Image - Smaller and compact
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.primaryGreen.withOpacity(0.05),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Image.network(
                    doctor.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Doctor Info - Compact
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    doctor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    doctor.specialization,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, size: 12, color: Colors.amber.shade600),
                      const SizedBox(width: 2),
                      Text(
                        doctor.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

