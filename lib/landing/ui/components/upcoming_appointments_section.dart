import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/utils/date_time_formatter.dart';
import '../../../_shared/routing/routing.dart';
import '../../../consultation_pending/ui/pending_consultation_screen.dart';
import '../../entities/dashboard_data.dart';

class UpcomingAppointmentsSection extends StatelessWidget {
  final List<UpcomingAppointment> appointments;

  const UpcomingAppointmentsSection({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink(); // Remove from main content
  }
}

// New floating widget for bottom right corner
class FloatingAppointmentWidget extends StatelessWidget {
  final List<UpcomingAppointment> appointments;

  const FloatingAppointmentWidget({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const SizedBox.shrink();
    }

    final mostUrgentAppointment = _getMostUrgentAppointment();
    final isToday = _isToday(mostUrgentAppointment.scheduledAt);
    
    return Positioned(
      bottom: 20,
      right: 16,
      child: GestureDetector(
        onTap: () {
          if (appointments.length == 1) {
            Get.to(() => PendingConsultationScreen(
              appointmentId: mostUrgentAppointment.id.toString()
            ));
          } else {
            Get.toNamed('/appointments');
          }
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isToday 
                  ? [
                      AppColors.primaryGreen,
                      AppColors.primaryGreen.withOpacity(0.8),
                    ]
                  : [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withOpacity(0.8),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isToday ? AppColors.primaryGreen : AppColors.primaryBlue)
                    .withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Doctor Avatar (small)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundImage: mostUrgentAppointment.doctorImage != null
                          ? NetworkImage(mostUrgentAppointment.doctorImage!)
                          : null,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: mostUrgentAppointment.doctorImage == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Appointment Info (compact)
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Time and count
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isToday 
                                  ? 'Today ${DateTimeFormatter.formatTime(mostUrgentAppointment.scheduledAt)}'
                                  : DateTimeFormatter.formatTime(mostUrgentAppointment.scheduledAt),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (appointments.length > 1) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '+${appointments.length - 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        
                        // Doctor name (truncated)
                        Text(
                          mostUrgentAppointment.doctorName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Type icon
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      mostUrgentAppointment.type == 'online' 
                          ? Icons.video_call_rounded 
                          : Icons.location_on_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  UpcomingAppointment _getMostUrgentAppointment() {
    final sortedAppointments = List<UpcomingAppointment>.from(appointments);
    sortedAppointments.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    
    final now = DateTime.now();
    final todayAppointments = sortedAppointments.where((apt) {
      return apt.scheduledAt.year == now.year &&
             apt.scheduledAt.month == now.month &&
             apt.scheduledAt.day == now.day;
    }).toList();
    
    if (todayAppointments.isNotEmpty) {
      return todayAppointments.first;
    }
    
    return sortedAppointments.first;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}
