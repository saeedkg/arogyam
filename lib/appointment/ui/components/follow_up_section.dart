import 'package:flutter/material.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../follow_up/entities/follow_up_eligibility.dart';
import '../../../appointment/entities/booking_detail.dart';

class FollowUpSection extends StatelessWidget {
  final BookingDetail bookingDetail;
  final FollowUpEligibility eligibility;
  final VoidCallback onTap;

  const FollowUpSection({
    super.key,
    required this.bookingDetail,
    required this.eligibility,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the current state
    final bool hasExistingChat = eligibility.hasExistingChat;
    final bool isActive = eligibility.hasActiveChat;
    final String buttonText = hasExistingChat ? 'Continue Chat' : 'Start Chat';
    final String statusText = hasExistingChat 
        ? (isActive ? 'Active chat available' : 'Chat created')
        : 'New follow-up available';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Follow-up Consultation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: eligibility.isExpired
                  ? [
                      Colors.orange.shade50,
                      Colors.orange.shade100,
                    ]
                  : hasExistingChat
                      ? [
                          AppColors.primaryGreen.withValues(alpha: 0.08),
                          AppColors.primaryGreen.withValues(alpha: 0.04),
                        ]
                      : [
                          AppColors.primaryBlue.withValues(alpha: 0.08),
                          AppColors.primaryBlue.withValues(alpha: 0.04),
                        ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: eligibility.isExpired
                  ? Colors.orange.shade200
                  : hasExistingChat
                      ? AppColors.primaryGreen.withValues(alpha: 0.2)
                      : AppColors.primaryBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: eligibility.isExpired
                          ? Colors.orange.shade100
                          : hasExistingChat
                              ? AppColors.primaryGreen
                              : AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      eligibility.isExpired
                          ? Icons.schedule_rounded
                          : hasExistingChat
                              ? Icons.chat_rounded
                              : Icons.medical_services_rounded,
                      size: 20,
                      color: eligibility.isExpired
                          ? Colors.orange.shade700
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eligibility.isExpired
                              ? 'Follow-up Period Expired'
                              : hasExistingChat
                                  ? 'Follow-up Chat Active'
                                  : 'Follow-up Available',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: eligibility.isExpired
                                ? Colors.orange.shade800
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          eligibility.isExpired
                              ? 'The follow-up consultation period has ended'
                              : '$statusText • ${eligibility.formattedExpiryTime}',
                          style: TextStyle(
                            color: eligibility.isExpired
                                ? Colors.orange.shade700
                                : Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!eligibility.isExpired) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasExistingChat 
                                ? AppColors.primaryGreen 
                                : AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasExistingChat 
                                    ? Icons.chat_bubble_rounded 
                                    : Icons.add_comment_rounded, 
                                size: 18
                              ),
                              const SizedBox(width: 8),
                              Text(
                                buttonText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              if (bookingDetail.unreadChatCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${bookingDetail.unreadChatCount}',
                                    style: TextStyle(
                                      color: hasExistingChat 
                                          ? AppColors.primaryGreen 
                                          : AppColors.primaryBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
