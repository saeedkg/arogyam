import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/utils/date_time_formatter.dart';
import '../../../_shared/routing/routing.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade900,
                ),
              ),
              const Spacer(),
              if (appointments.length > 1)
                TextButton(
                  onPressed: () {
                    // Navigate to appointments screen
                    Get.toNamed('/appointments');
                  },
                  child: const Text('See all'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Appointments List
        SizedBox(
          height: 90,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            scrollDirection: Axis.horizontal,
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return _UpcomingAppointmentCard(appointment: appointment);
            },
          ),
        ),
      ],
    );
  }
}

class _UpcomingAppointmentCard extends StatelessWidget {
  final UpcomingAppointment appointment;

  const _UpcomingAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(appointment.scheduledAt);
    final isTomorrow = _isTomorrow(appointment.scheduledAt);
    
    return GestureDetector(
      onTap: () {
        // Navigate to appointment detail
        AppNavigation.toAppointmentDetail(appointment.id.toString());
      },
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday 
                ? AppColors.primaryGreen 
                : Colors.grey.shade200,
            width: isToday ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Doctor Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isToday 
                        ? AppColors.primaryGreen.withOpacity(0.4)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: appointment.doctorImage != null
                      ? NetworkImage(appointment.doctorImage!)
                      : null,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  child: appointment.doctorImage == null
                      ? Icon(
                          Icons.person,
                          color: AppColors.primaryGreen,
                          size: 18,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              
              // Appointment Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Doctor Name and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            appointment.doctorName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isToday 
                                  ? AppColors.primaryGreen 
                                  : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(appointment.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(appointment.status),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(appointment.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Date, Time and Type
                    Row(
                      children: [
                        // Date
                        Text(
                          isToday 
                              ? 'Today' 
                              : isTomorrow 
                                  ? 'Tomorrow'
                                  : DateTimeFormatter.formatDateShort(appointment.scheduledAt),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isToday 
                                ? AppColors.primaryGreen 
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Time
                        Text(
                          DateTimeFormatter.formatTime(appointment.scheduledAt),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        // Type Icon
                        Icon(
                          appointment.type == 'online' 
                              ? Icons.video_call_rounded 
                              : Icons.location_on_rounded,
                          size: 14,
                          color: isToday 
                              ? AppColors.primaryGreen 
                              : Colors.grey.shade500,
                        ),
                      ],
                    ),
                    
                    // Patient Info (if not self)
                    if (appointment.patientType != 'self') ...[
                      const SizedBox(height: 2),
                      Text(
                        'For ${appointment.patientName}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action Arrow (only for today)
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.primaryGreen;
      case 'pending':
        return AppColors.warningOrange;
      case 'cancelled':
        return AppColors.errorRed;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}