import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../controller/doctor_detail_controller.dart';
import '../../booking/ui/doctor_booking_screen.dart';
import '../entities/doctor_detail_data.dart';

class DoctorDetailBottomSheet extends StatelessWidget {
  final String doctorId;
  const DoctorDetailBottomSheet({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DoctorDetailPageController());
    c.load(doctorId);

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Obx(() {
            if (c.isLoading.value) {
              return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
            }
            if (c.error.value != null) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${c.error.value}'),
              ));
            }
            if (c.doctor.value == null) {
              return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No doctor found')));
            }
            final d = c.doctor.value!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                const SizedBox(height: 12),
                _buildHeader(d, context),
                const Divider(height: 24),
                _buildDetailSection(d),
                const SizedBox(height: 24),
                _buildActionButton(context, doctorId),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 44,
      height: 5,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildHeader(DoctorDetailData d, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              d.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade100,
                child: Icon(Icons.person, color: Colors.grey.shade400, size: 32),
              ),
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
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                d.specialization,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text('${d.rating}', style: TextStyle(color: Colors.amber.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Text('${d.totalRatings} Reviews', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        if (d.isVerified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.verified, size: 14, color: AppColors.successGreen),
              const SizedBox(width: 4),
              Text('Verified', style: TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ),
       // IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded, size: 22)),
      ],
    );
  }

  Widget _buildDetailSection(DoctorDetailData d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (d.bio.isNotEmpty) ...[
          Text('About', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.grey.shade900)),
          const SizedBox(height: 8),
          Text(d.bio, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
          const SizedBox(height: 24),
        ],
        Text('Consultation Info', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.grey.shade900)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoChip(Icons.access_time, '${d.consultationDuration} min', Colors.blue.shade600),
              _buildInfoChip(Icons.attach_money, '₹${d.consultationFee}', Colors.orange.shade600),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String doctorId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Get.back();
          Get.to(() => DoctorBookingScreen(doctorId: doctorId));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Book Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

