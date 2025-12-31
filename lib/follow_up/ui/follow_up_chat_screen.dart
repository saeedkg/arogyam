import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../../_shared/utils/date_time_formatter.dart';
import '../controller/follow_up_chat_controller.dart';
import '../entities/follow_up_chat.dart';
import 'components/chat_message_bubble.dart';

class FollowUpChatScreen extends StatefulWidget {
  final String appointmentId;
  
  const FollowUpChatScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<FollowUpChatScreen> createState() => _FollowUpChatScreenState();
}

class _FollowUpChatScreenState extends State<FollowUpChatScreen> {
  late final FollowUpChatController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(FollowUpChatController());
    
    // Load chat data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadChat(widget.appointmentId);
    });
  }

  @override
  void dispose() {
    Get.delete<FollowUpChatController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }
        
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState();
        }
        
        if (controller.chat.value == null) {
          return _buildEmptyState();
        }
        
        return _buildChatContent();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        onPressed: Get.back,
      ),
      title: Obx(() {
        final chat = controller.chat.value;
        if (chat == null) {
          return const Text(
            'Follow-up Chat',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chat.otherParticipant.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              controller.isChatExpired 
                  ? 'Chat Expired' 
                  : controller.formattedExpiryTime,
              style: TextStyle(
                fontSize: 12,
                color: controller.isChatExpired 
                    ? Colors.red.shade600 
                    : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }),
      actions: [
        Obx(() {
          if (controller.chat.value == null) return const SizedBox.shrink();
          
          return IconButton(
            onPressed: controller.refreshChat,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          );
        }),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryBlue,
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Loading chat...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to Load Chat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.loadChat(widget.appointmentId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Chat Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Follow-up chat is not available for this appointment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent() {
    return Column(
      children: [
        // Chat expiry banner
        Obx(() {
          if (!controller.isChatExpired) return const SizedBox.shrink();
          
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.red.shade50,
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Colors.red.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This follow-up chat has expired. You can no longer send messages.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        
        // Messages list
        Expanded(
          child: Obx(() {
            if (controller.messages.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_rounded,
                        size: 60,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start the conversation',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Send a message to begin your follow-up consultation.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                return ChatMessageBubble(
                  message: message,
                  isFromCurrentUser: message.isFromPatient,
                );
              },
            );
          }),
        ),
        
        // Message input
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Obx(() {
      // Don't show input if chat is expired
      if (controller.isChatExpired) {
        return const SizedBox.shrink();
      }
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Image button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  onPressed: controller.isSendingMessage.value 
                      ? null 
                      : controller.sendImageMessage,
                  icon: Icon(
                    Icons.image_rounded,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                  tooltip: 'Send Image',
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Text input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: controller.messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => controller.sendTextMessage(),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Send button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  onPressed: controller.isSendingMessage.value 
                      ? null 
                      : controller.sendTextMessage,
                  icon: controller.isSendingMessage.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                  tooltip: 'Send Message',
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}