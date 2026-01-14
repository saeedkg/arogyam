import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../entities/doctor_list_item.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../booking/ui/doctor_booking_screen.dart';
import '../doctor_detail_info_screen.dart';
import '../speciality_doctors_screen.dart';

class DoctorCard extends StatelessWidget {
  final DoctorListItem doctor;
  final Function(String doctorId, Map<String, dynamic> doctorData)? onDoctorSelected;
  final AppointmentFilterType? appointmentType;
  
  const DoctorCard({
    required this.doctor, 
    this.onDoctorSelected,
    this.appointmentType,
    super.key,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not make phone call',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Container click -> Navigate to DoctorDetailInfoScreen
          // Pass isFromPhysicalAppointment based on current filter
          Get.to(() => DoctorDetailInfoScreen(
            doctorId: doctor.id,
            isFromPhysicalAppointment: appointmentType == AppointmentFilterType.physical,
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🩺 Top Section (Photo + Info)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Image with Online Badge
                  Stack(
                    children: [
                      ClipOval(
                        child: Image.network(
                          doctor.imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey.shade200,
                            child: Icon(Icons.person, color: Colors.grey.shade500, size: 32),
                          ),
                        ),
                      ),
                      // Online Status Badge
                      if (doctor.isOnline)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.green.shade500,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Rating
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                doctor.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Rating instead of favorite
                            Row(
                              children: [
                                Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 16),
                                const SizedBox(width: 2),
                                Text(
                                  doctor.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 2),
                        // Specialization
                        Text(
                          doctor.specialization,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 3),
                        // Qualification
                        Text(
                          doctor.education,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Experience + Fee
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Exp: ${doctor.experience}+ yrs',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            Text(
                              'Fee: ₹${doctor.consultationFee}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 🏥 Hospital Section
              /// 🏥 Hospital Section
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFF8F9FB), // subtle neutral background
              //     borderRadius: BorderRadius.circular(10),
              //     border: Border.all(color: Colors.grey.shade200),
              //   ),
              //   child: Row(
              //     children: [
              //       Icon(
              //         Icons.location_on_outlined,
              //         size: 18,
              //         color: Colors.blueGrey.shade600,
              //       ),
              //       const SizedBox(width: 6),
              //       Expanded(
              //         child: Text(
              //           doctor.hospital,
              //           style: const TextStyle(
              //             fontSize: 13,
              //             fontWeight: FontWeight.w500,
              //             color: Colors.black87,
              //             height: 1.3,
              //           ),
              //           overflow: TextOverflow.ellipsis,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),


              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey.shade300),
              const SizedBox(height: 12),

              /// ✅ Availability + Book Now Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Availability Status
                  Expanded(
                    child: Row(
                      children: [
                        // Online Status Tag
                        if (doctor.isOnline)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade500,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Online',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Available Today (if online, add spacing)
                      //  if (doctor.isOnline && doctor.availableToday) const SizedBox(width: 8),
                        
                        // if (doctor.availableToday)
                        //   Row(
                        //     children: [
                        //       Icon(
                        //         Icons.schedule_rounded,
                        //         color: doctor.isOnline ? Colors.blue.shade600 : Colors.green.shade600,
                        //         size: 16,
                        //       ),
                        //       const SizedBox(width: 4),
                        //       Text(
                        //         'Available Today',
                        //         style: TextStyle(
                        //           fontSize: 12,
                        //           fontWeight: FontWeight.w500,
                        //           color: doctor.isOnline ? Colors.blue.shade700 : Colors.green.shade700,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        
                        // If not available today but online
                        // if (doctor.isOnline && !doctor.availableToday)
                        //   Row(
                        //     children: [
                        //       const SizedBox(width: 8),
                        //       Icon(
                        //         Icons.schedule_rounded,
                        //         color: Colors.orange.shade600,
                        //         size: 16,
                        //       ),
                        //       const SizedBox(width: 4),
                        //       Text(
                        //         'Next Available',
                        //         style: TextStyle(
                        //           fontSize: 12,
                        //           fontWeight: FontWeight.w500,
                        //           color: Colors.orange.shade700,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                      ],
                    ),
                  ),

                  // Book Now / Call Clinic Button
                  if (doctor.hasInstantOrOnlineConsultation || appointmentType == AppointmentFilterType.physical)
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // If physical appointment, make phone call
                          if (appointmentType == AppointmentFilterType.physical) {
                            // Use a default clinic number or doctor's contact
                            // You can modify this to use actual clinic phone number from doctor data
                            _makePhoneCall('+911234567890'); // Replace with actual clinic number
                          } else {
                            // Button press -> Direct navigation to booking for video consult
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorBookingScreen(
                                  doctorId: doctor.id,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appointmentType == AppointmentFilterType.physical 
                              ? AppColors.primaryGreen 
                              : AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(
                          appointmentType == AppointmentFilterType.physical 
                              ? Icons.phone_rounded 
                              : Icons.calendar_today_rounded,
                          size: 16,
                        ),
                        label: Text(
                          appointmentType == AppointmentFilterType.physical 
                              ? 'Call Clinic' 
                              : 'Book Consult',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
