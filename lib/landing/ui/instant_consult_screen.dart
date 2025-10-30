import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/routing/routing.dart';
import '../../_shared/ui/app_colors.dart';
import '../../appointment/components/patient_card.dart';
import '../../landing/entities/doctor.dart';
import '../../landing/controller/home_controller.dart';

class InstantConsultScreen extends StatefulWidget {
  const InstantConsultScreen({super.key});

  @override
  State<InstantConsultScreen> createState() => _InstantConsultScreenState();
}

class _InstantConsultScreenState extends State<InstantConsultScreen> {
  Doctor? selectedDoctor;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
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
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Text(
                    'Select Doctor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Horizontal Doctors List
                  SizedBox(
                    height: 180,
                    child: Obx(
                          () => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.topDoctors.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, i) {
                          final doctor = controller.topDoctors[i];
                          final isSelected = selectedDoctor?.id == doctor.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDoctor = doctor;
                              });
                            },
                            child: Container(
                              width: 140,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryGreen.withOpacity(0.08)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  // Doctor Image
                                  Container(
                                    height: 100,
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
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: Colors.grey.shade400,
                                                ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryGreen,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.primaryGreen
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Doctor Info
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctor.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: isSelected
                                                  ? AppColors.primaryGreen
                                                  : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            doctor.specialization,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              Icon(Icons.star_rounded,
                                                  size: 14,
                                                  color: Colors.amber.shade600),
                                              const SizedBox(width: 2),
                                              Text(
                                                doctor.rating.toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: isSelected
                                                      ? AppColors.primaryGreen
                                                      : Colors.black87,
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
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Patient Card
                  PatientCard(
                    name: 'Jane Doe',
                    dob: '01/01/1990',
                    id: 'AXY789',
                    imageUrl: 'https://i.pravatar.cc/150?img=65',
                    onChange: () {
                      AppNavigation.toFamilyMembers();
                    },
                  ),
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
                  Container(
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
                          '\$150.00',
                          isBold: false,
                        ),
                        const Divider(height: 32, thickness: 1.2),
                        _buildFeeRow(
                          'Platform Fee',
                          '\$10.00',
                          isBold: false,
                        ),
                        const Divider(height: 32, thickness: 1.2),
                        _buildFeeRow(
                          'GST (18%)',
                          '\$28.80',
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
                                '\$188.80',
                                style: TextStyle(
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
                  ),
                ],
              ),
            ),
          ),
          // Bottom Proceed Button
          Container(
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
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: selectedDoctor == null
                          ? null
                          : () {
                        // Navigate to next screen or process payment
                        // AppNavigation.toConsultationConfirmed();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Proceed to Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: selectedDoctor == null
                              ? Colors.grey.shade600
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (selectedDoctor == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Please select a doctor',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
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
