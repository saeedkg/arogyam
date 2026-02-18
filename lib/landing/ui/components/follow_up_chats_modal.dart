import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../_shared/constants/network_config.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../follow_up/ui/follow_up_chat_screen.dart';
import '../../entities/dashboard_data.dart';

class FollowUpChatsModal extends StatelessWidget {
  final List<FollowUpChatSummary> chats;
  final VoidCallback? onRefresh;

  const FollowUpChatsModal({
    super.key,
    required this.chats,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chat_bubble_rounded,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Follow-up Messages',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Chat list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: chats.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _ChatListItem(
                  chat: chat,
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Get.to(() => FollowUpChatScreen(
                      appointmentId: chat.appointmentId.toString(),
                    ));
                    if (result == true && onRefresh != null) {
                      onRefresh!();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _ChatListItem extends StatelessWidget {
  final FollowUpChatSummary chat;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: chat.unreadCount > 0 
                ? AppColors.primaryBlue.withValues(alpha: 0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: chat.unreadCount > 0
                  ? AppColors.primaryBlue.withValues(alpha: 0.2)
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Doctor avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: (chat.doctorImage != null && chat.doctorImage!.isNotEmpty)
                      ? NetworkImage(
                          chat.doctorImage!.startsWith('http')
                              ? chat.doctorImage!
                              : '${NetworkConfig.baseUrl_Public}/storage/${chat.doctorImage!}'
                        )
                      : null,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: (chat.doctorImage == null || chat.doctorImage!.isEmpty)
                      ? Icon(
                          Icons.medical_services_rounded,
                          color: AppColors.primaryBlue,
                          size: 18,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              
              // Chat details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${chat.doctorName}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: chat.unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.latestMessage,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // Unread badge or arrow
              if (chat.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
