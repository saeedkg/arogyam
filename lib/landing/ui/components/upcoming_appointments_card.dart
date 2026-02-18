import 'package:flutter/material.dart';
import '../../../_shared/constants/network_config.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/utils/date_time_formatter.dart';
import '../../entities/dashboard_data.dart';

class UpcomingAppointmentsCard extends StatelessWidget {
  final List<UpcomingAppointment> appointments;
  final Function(UpcomingAppointment)? onTap;

  const UpcomingAppointmentsCard({
    super.key,
    required this.appointments,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Increased height from 90 to 100
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero, // Start from the beginning
        itemCount: appointments.length, // No "View All" button
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          final isToday = _isToday(appointment.scheduledAt);
          final isUrgent = _isUrgent(appointment.scheduledAt);
          
          // Determine width based on number of appointments
          double itemWidth;
          if (appointments.length == 1) {
            itemWidth = MediaQuery.of(context).size.width - 40; // Full width for single item
          } else {
            itemWidth = MediaQuery.of(context).size.width - 80; // Partial width to show next item
          }
          
          return Container(
            width: itemWidth,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 8, // No left margin for first item
              right: appointments.length == 1 ? 0 : 0, // No right margin
              top: 4, // Reduced from 8 to 4
              bottom: 4, // Reduced from 8 to 4
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap != null ? () => onTap!(appointment) : null,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12), // Reduced from 16 to 12
                  child: Row(
                    children: [
                      // Doctor avatar with video icon positioned below
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryGreen.withOpacity(0.1),
                                  AppColors.primaryGreen.withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.primaryGreen.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 23,
                              backgroundImage: (appointment.doctorImage != null && appointment.doctorImage!.isNotEmpty)
                                  ? NetworkImage(
                                      appointment.doctorImage!.startsWith('http')
                                          ? appointment.doctorImage!
                                          : '${NetworkConfig.baseUrl_Public+"/storage"}/${appointment.doctorImage!}'
                                    )
                                  : null,
                              backgroundColor: Colors.transparent,
                              child: (appointment.doctorImage == null || appointment.doctorImage!.isEmpty)
                                  ? Icon(
                                      Icons.medical_services_rounded,
                                      color: AppColors.primaryGreen,
                                      size: 24,
                                    )
                                  : null,
                            ),
                          ),
                          // Video/Clinic icon positioned at bottom right of profile
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: appointment.type == 'online' 
                                      ? [Colors.blue.shade400, Colors.blue.shade600]
                                      : [Colors.green.shade400, Colors.green.shade600],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                appointment.type == 'online' 
                                    ? Icons.videocam_rounded 
                                    : Icons.local_hospital_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      
                      // Appointment details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Doctor name with urgency indicator
                            Row(
                              children: [
                                if (isUrgent)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.4),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    'Dr. ${appointment.doctorName}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            
                            // Time only (shortened)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryGreen.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: AppColors.primaryGreen,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatShortAppointmentTime(appointment, isToday),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Arrow
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatShortAppointmentTime(UpcomingAppointment appointment, bool isToday) {
    if (isToday) {
      return 'Today ${DateTimeFormatter.formatTime(appointment.scheduledAt)}';
    } else {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      
      if (appointment.scheduledAt.year == tomorrow.year &&
          appointment.scheduledAt.month == tomorrow.month &&
          appointment.scheduledAt.day == tomorrow.day) {
        return 'Tom ${DateTimeFormatter.formatTime(appointment.scheduledAt)}';
      }
      
      return DateTimeFormatter.formatDate(appointment.scheduledAt);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  bool _isUrgent(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inHours <= 2 && difference.inHours >= 0;
  }
}