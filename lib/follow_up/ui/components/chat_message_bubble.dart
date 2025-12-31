import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/utils/date_time_formatter.dart';
import '../../entities/follow_up_chat.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isFromCurrentUser;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isSystemMessage) {
      return _buildSystemMessage();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isFromCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromCurrentUser) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: isFromCurrentUser 
                    ? CrossAxisAlignment.end 
                    : CrossAxisAlignment.start,
                children: [
                  // Sender name (only for other users)
                  if (!isFromCurrentUser) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 4),
                      child: Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                  
                  // Message bubble
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isFromCurrentUser 
                          ? AppColors.primaryGreen 
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isFromCurrentUser ? 18 : 4),
                        bottomRight: Radius.circular(isFromCurrentUser ? 4 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message content
                        if (message.isImageMessage) 
                          _buildImageMessage()
                        else 
                          _buildTextMessage(),
                        
                        const SizedBox(height: 6),
                        
                        // Timestamp and read status
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateTimeFormatter.formatTime(message.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: isFromCurrentUser 
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            if (isFromCurrentUser) ...[
                              const SizedBox(width: 4),
                              Icon(
                                message.isRead 
                                    ? Icons.done_all_rounded 
                                    : Icons.done_rounded,
                                size: 14,
                                color: message.isRead 
                                    ? Colors.blue.shade200
                                    : Colors.white.withValues(alpha: 0.8),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isFromCurrentUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextMessage() {
    return Text(
      message.message,
      style: TextStyle(
        fontSize: 15,
        color: isFromCurrentUser ? Colors.white : Colors.black87,
        height: 1.4,
      ),
    );
  }

  Widget _buildImageMessage() {
    // Check if fileUrl is available
    if (message.fileUrl == null || message.fileUrl!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.broken_image_rounded,
              color: Colors.grey.shade400,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () => _showFullScreenImage(),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 200,
                maxHeight: 200,
              ),
              child: Image.network(
                message.fileUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          color: Colors.grey.shade400,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        // File info
        if (message.fileName != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_rounded,
                size: 14,
                color: isFromCurrentUser 
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  message.fileName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isFromCurrentUser 
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (message.formattedFileSize != null) ...[
                const SizedBox(width: 8),
                Text(
                  message.formattedFileSize!,
                  style: TextStyle(
                    fontSize: 11,
                    color: isFromCurrentUser 
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isFromCurrentUser 
            ? AppColors.primaryGreen.withValues(alpha: 0.1)
            : AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isFromCurrentUser 
            ? Icons.person_rounded 
            : Icons.local_hospital_rounded,
        size: 18,
        color: isFromCurrentUser 
            ? AppColors.primaryGreen 
            : AppColors.primaryBlue,
      ),
    );
  }

  void _showFullScreenImage() {
    if (message.fileUrl == null) return;
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  message.fileUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            color: Colors.white,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: Get.back,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}