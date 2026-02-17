import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../entities/follow_up_chat.dart';
import '../service/follow_up_chat_service.dart';

class FollowUpChatController extends GetxController {
  final FollowUpChatService _service = FollowUpChatService();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Observables
  final Rx<FollowUpChat?> chat = Rx<FollowUpChat?>(null);
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSendingMessage = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Text controller for message input
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // Auto-scroll to bottom when new messages arrive
    ever(messages, (_) => _scrollToBottom());
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Load follow-up chat for appointment
  Future<void> loadChat(String appointmentId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final chatData = await _service.getFollowUpChat(appointmentId);
      
      chat.value = chatData;
      messages.value = chatData.messages;
      
      // Mark messages as read only if chat has an ID (exists on server)
      if (chatData.id > 0) {
        await _service.markMessagesAsRead(chatData.id);
      }
      
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load chat: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Send text message
  Future<void> sendTextMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    if (chat.value == null) {
      Get.snackbar(
        'Info',
        'Chat session not initialized. Please try again.',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isSendingMessage.value = true;
      
      // Clear input immediately for better UX
      messageController.clear();
      
      // If chat doesn't exist on server yet (id = 0), the API will create it
      // The API should handle creating the chat on first message
      final newMessage = await _service.sendTextMessage(
        chat.value!.id > 0 ? chat.value!.id : chat.value!.appointmentId,
        messageText,
      );
      
      // Add to local messages list
      messages.add(newMessage);
      
      // Refresh chat to get latest messages from server
      await refreshChat();
      
    } catch (e) {
      // Restore message text on error
      messageController.text = messageText;
      
      Get.snackbar(
        'Error',
        'Failed to send message: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  /// Send image message
  Future<void> sendImageMessage() async {
    if (chat.value == null) return;

    try {
      // Show image source selection
      final ImageSource? source = await Get.bottomSheet<ImageSource>(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Camera'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Gallery'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      );

      if (source == null) return;

      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      isSendingMessage.value = true;

      // Send image
      final newMessage = await _service.sendImageMessage(
        chat.value!.id,
        File(pickedFile.path),
      );

      // Add to local messages list
      messages.add(newMessage);
      
      // Refresh chat to get latest messages from server
      await refreshChat();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send image: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  /// Refresh chat data
  Future<void> refreshChat() async {
    if (chat.value == null) return;
    await loadChat(chat.value!.appointmentId.toString());
  }

  /// Scroll to bottom of chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Check if chat is expired
  bool get isChatExpired {
    if (chat.value == null) return false;
    return DateTime.now().isAfter(chat.value!.expiresAt);
  }

  /// Get formatted expiry time
  String get formattedExpiryTime {
    if (chat.value == null) return '';
    final now = DateTime.now();
    final expiry = chat.value!.expiresAt;
    
    if (now.isAfter(expiry)) {
      return 'Expired';
    }
    
    final difference = expiry.difference(now);
    if (difference.inDays > 0) {
      return '${difference.inDays} days left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours left';
    } else {
      return '${difference.inMinutes} minutes left';
    }
  }
}