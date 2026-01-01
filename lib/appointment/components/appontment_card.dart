import 'package:flutter/material.dart';
import '../../_shared/ui/app_colors.dart';
import '../entities/appointment_status.dart';

class AppointmentCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String name;
  final String specialization;
  final String date;
  final String time;
  final AppointmentStatus status;
  final String type;
  final VoidCallback onView;
  
  // Enhanced fields from API
  final double? consultationFee;
  final bool hasPrescription;
  final bool isFollowUpEligible;
  final String? consultationStatus;
  final int? doctorExperience;
  final List<String>? doctorQualifications;
  final bool canJoinNow;

  const AppointmentCard({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.specialization,
    required this.date,
    required this.time,
    required this.status,
    required this.type,
    required this.onView,
    this.consultationFee,
    this.hasPrescription = false,
    this.isFollowUpEligible = false,
    this.consultationStatus,
    this.doctorExperience,
    this.doctorQualifications,
    this.canJoinNow = false,
  });

  Color get _statusColor {
    switch (status) {
      case AppointmentStatus.confirmed:
        return AppColors.confirmedGreen;
      case AppointmentStatus.completed:
        return AppColors.pendingBlue;
      case AppointmentStatus.pending:
        return AppColors.cancelledOrange;
      case AppointmentStatus.cancelled:
        return AppColors.errorRed;
      default:
        return AppColors.defaultGrey;
    }
  }

  Color get _statusTextColor {
    switch (status) {
      case AppointmentStatus.confirmed:
        return AppColors.textDark;
      case AppointmentStatus.completed:
        return AppColors.textBlue;
      case AppointmentStatus.pending:
        return AppColors.textOrange;
      case AppointmentStatus.cancelled:
        return AppColors.errorRed;
      default:
        return AppColors.grey800;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatus.completed:
        return Icons.verified_outlined;
      case AppointmentStatus.pending:
        return Icons.pending_outlined;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with doctor info and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor avatar with experience badge
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey.shade100,
                                child: Icon(
                                  Icons.person_rounded,
                                  color: Colors.grey.shade400,
                                  size: 28,
                                ),
                              ),
                        ),
                      ),
                    ),
                    // Experience badge
                    if (doctorExperience != null && doctorExperience! > 0)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.primaryBlue.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            '${doctorExperience}Y',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Doctor details and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // Qualifications
                                if (doctorQualifications != null && doctorQualifications!.isNotEmpty)
                                  Text(
                                    doctorQualifications!.join(', '),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  specialization,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _statusColor,
                                  _statusColor.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _statusColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _statusIcon,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Appointment details with enhanced information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade50,
                    Colors.grey.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // Date and Time row
                  Row(
                    children: [
                      _buildDetailItem(
                        icon: Icons.calendar_today_rounded,
                        text: date,
                        color: AppColors.primaryBlue,
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      _buildDetailItem(
                        icon: Icons.access_time_rounded,
                        text: time,
                        color: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                  
                  // Additional info row
                  if (consultationFee != null || _shouldShowAdditionalInfo())
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Consultation fee
                            if (consultationFee != null)
                              Expanded(
                                child: _buildInfoChip(
                                  icon: Icons.currency_rupee_rounded,
                                  text: '₹${consultationFee!.toStringAsFixed(0)}',
                                  color: AppColors.successGreen,
                                ),
                              ),
                            
                            // Consultation type
                            if (consultationFee != null && type.isNotEmpty)
                              const SizedBox(width: 8),
                            if (type.isNotEmpty)
                              Expanded(
                                child: _buildInfoChip(
                                  icon: _getTypeIcon(),
                                  text: type.toUpperCase(),
                                  color: _getTypeColor(),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Status indicators row
            if (_shouldShowStatusIndicators())
              Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Prescription indicator
                      if (hasPrescription)
                        _buildStatusIndicator(
                          icon: Icons.receipt_long_rounded,
                          text: 'Prescription',
                          color: AppColors.primaryGreen,
                        ),
                      
                      if (hasPrescription && (isFollowUpEligible || canJoinNow))
                        const SizedBox(width: 8),
                      
                      // Follow-up indicator
                      if (isFollowUpEligible)
                        _buildStatusIndicator(
                          icon: Icons.chat_bubble_outline_rounded,
                          text: 'Follow-up',
                          color: AppColors.primaryBlue,
                        ),
                      
                      if (isFollowUpEligible && canJoinNow)
                        const SizedBox(width: 8),
                      
                      // Can join now indicator
                      if (canJoinNow)
                        _buildStatusIndicator(
                          icon: Icons.videocam_rounded,
                          text: 'Join Now',
                          color: AppColors.warningOrange,
                          isBlinking: true,
                        ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Enhanced action button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: onView,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getActionButtonColor(),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: _getActionButtonColor().withValues(alpha: 0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getActionButtonIcon(), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _getActionButtonText(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

  Widget _buildDetailItem({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primaryGreen).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color ?? AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator({
    required IconData icon,
    required String text,
    required Color color,
    bool isBlinking = false,
  }) {
    Widget indicator = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );

    if (isBlinking) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.5, end: 1.0),
        duration: const Duration(milliseconds: 800),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: indicator,
          );
        },
        onEnd: () {
          // This creates a continuous blinking effect
        },
      );
    }

    return indicator;
  }

  bool _shouldShowAdditionalInfo() {
    return consultationFee != null || type.isNotEmpty;
  }

  bool _shouldShowStatusIndicators() {
    return hasPrescription || isFollowUpEligible || canJoinNow;
  }

  IconData _getTypeIcon() {
    switch (type.toLowerCase()) {
      case 'instant':
        return Icons.flash_on_rounded;
      case 'online':
        return Icons.videocam_rounded;
      case 'offline':
        return Icons.location_on_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  Color _getTypeColor() {
    switch (type.toLowerCase()) {
      case 'instant':
        return AppColors.warningOrange;
      case 'online':
        return AppColors.primaryBlue;
      case 'offline':
        return AppColors.infoBlue;
      default:
        return AppColors.primaryGreen;
    }
  }

  Color _getActionButtonColor() {
    if (canJoinNow) return AppColors.warningOrange;
    
    switch (status) {
      case AppointmentStatus.confirmed:
      case AppointmentStatus.pending:
        return AppColors.primaryBlue;
      case AppointmentStatus.completed:
        return AppColors.primaryGreen;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getActionButtonIcon() {
    if (canJoinNow) return Icons.videocam_rounded;
    
    switch (status) {
      case AppointmentStatus.confirmed:
      case AppointmentStatus.pending:
        return Icons.video_call_rounded;
      case AppointmentStatus.completed:
        return Icons.visibility_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getActionButtonText() {
    if (canJoinNow) return 'Join Now';
    
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Join Consultation';
      case AppointmentStatus.pending:
        return 'View Consultation';
      case AppointmentStatus.completed:
        return 'View Details';
      default:
        return 'View Details';
    }
  }
}