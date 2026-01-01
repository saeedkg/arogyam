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
        return AppColors.primaryGreen;
      case AppointmentStatus.completed:
        return AppColors.primaryBlue;
      case AppointmentStatus.pending:
        return AppColors.warningOrange;
      case AppointmentStatus.cancelled:
        return AppColors.errorRed;
      default:
        return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main content row
            Row(
              children: [
                // Doctor avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey200, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.grey100,
                        child: Icon(
                          Icons.person,
                          color: AppColors.grey400,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Doctor info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Dr. $name',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _statusColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              status.displayName,
                              style: TextStyle(
                                color: _statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialization,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey600,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Appointment details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey200, width: 1),
              ),
              child: Row(
                children: [
                  // Date and time
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.grey600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$date • $time',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Type and fee
                  if (type.isNotEmpty || consultationFee != null)
                    Row(
                      children: [
                        Container(
                          width: 1,
                          height: 16,
                          color: AppColors.grey300,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        if (consultationFee != null)
                          Text(
                            '₹${consultationFee!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        if (type.isNotEmpty && consultationFee != null)
                          const SizedBox(width: 4),
                        if (type.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getTypeDisplayText(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            
            // Action indicators and button
            if (_hasActionItems())
              Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Quick indicators
                      if (hasPrescription || isFollowUpEligible || canJoinNow)
                        Expanded(
                          child: Row(
                            children: [
                              if (hasPrescription)
                                _buildQuickIndicator(
                                  Icons.receipt,
                                  'Rx',
                                  AppColors.primaryGreen,
                                ),
                              if (hasPrescription && (isFollowUpEligible || canJoinNow))
                                const SizedBox(width: 6),
                              if (isFollowUpEligible)
                                _buildQuickIndicator(
                                  Icons.chat_bubble_outline,
                                  'F/U',
                                  AppColors.primaryBlue,
                                ),
                              if (isFollowUpEligible && canJoinNow)
                                const SizedBox(width: 6),
                              if (canJoinNow)
                                _buildQuickIndicator(
                                  Icons.videocam,
                                  'Live',
                                  AppColors.warningOrange,
                                ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(width: 12),
                      
                      // Action button
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: onView,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getActionButtonColor(),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(
                            _getActionButtonText(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onView,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getActionButtonColor(),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _getActionButtonText(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickIndicator(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
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
            size: 10,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActionItems() {
    return hasPrescription || isFollowUpEligible || canJoinNow;
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

  String _getTypeDisplayText() {
    switch (type.toLowerCase()) {
      case 'instant':
        return 'INSTANT CONSULT';
      case 'online':
        return 'VIDEO CALL';
      case 'offline':
        return 'IN-PERSON';
      default:
        return type.toUpperCase();
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
        return AppColors.grey600;
    }
  }

  String _getActionButtonText() {
    if (canJoinNow) return 'Join';
    
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Join';
      case AppointmentStatus.pending:
        return 'View';
      case AppointmentStatus.completed:
        return 'Details';
      default:
        return 'View';
    }
  }
}