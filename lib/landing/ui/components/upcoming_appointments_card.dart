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
      height: 80, // Reduced height to match ConsultationToJoinCard
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          final isToday = _isToday(appointment.scheduledAt);
          final isUrgent = _isUrgent(appointment.scheduledAt);
          
          // Determine width based on number of appointments
          double itemWidth;
          if (appointments.length == 1) {
            itemWidth = MediaQuery.of(context).size.width - 40;
          } else {
            itemWidth = MediaQuery.of(context).size.width - 80;
          }
          
          return Container(
            width: itemWidth,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUrgent 
                    ? Colors.orange.withValues(alpha: 0.3)
                    : AppColors.primaryGreen.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isUrgent
                      ? Colors.orange.withValues(alpha: 0.1)
                      : AppColors.primaryGreen.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap != null ? () => onTap!(appointment) : null,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Doctor avatar with type badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundImage: (appointment.doctorImage != null && appointment.doctorImage!.isNotEmpty)
                                  ? NetworkImage(
                                      appointment.doctorImage!.startsWith('http')
                                          ? appointment.doctorImage!
                                          : '${NetworkConfig.baseUrl_Public}/storage/${appointment.doctorImage!}'
                                    )
                                  : null,
                              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                              child: (appointment.doctorImage == null || appointment.doctorImage!.isEmpty)
                                  ? Icon(
                                      Icons.medical_services_rounded,
                                      color: AppColors.primaryGreen,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          ),
                          // Type badge
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: appointment.type == 'online' 
                                    ? Colors.blue.shade500
                                    : Colors.green.shade500,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                appointment.type == 'online' 
                                    ? Icons.videocam_rounded 
                                    : Icons.local_hospital_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      
                      // Appointment details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Doctor name
                            Text(
                              'Dr. ${appointment.doctorName}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            
                            // Time with urgency indicator
                            Row(
                              children: [
                                if (isUrgent)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 13,
                                  color: isUrgent ? Colors.orange : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatShortAppointmentTime(appointment, isToday),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isUrgent ? Colors.orange : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Arrow indicator
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey.shade400,
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