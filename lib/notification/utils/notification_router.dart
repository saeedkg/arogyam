import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

/// Router for handling notification navigation
class NotificationRouter {
  /// Handle notification tap and navigate to appropriate screen
  static void handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final notificationType = data['notification_type'] as String?;

    if (notificationType == null) {
      print('⚠️ No notification type found, navigating to home');
      Get.offAllNamed('/landing');
      return;
    }

    print('📱 Routing notification type: $notificationType');

    switch (notificationType) {
      case 'appointment_reminder':
      case 'appointment_confirmed':
      case 'appointment_cancelled':
        _navigateToAppointmentDetails(data);
        break;

      case 'chat_message':
        _navigateToChatScreen(data);
        break;

      case 'doctor_assigned':
      case 'consultation_started':
        _navigateToConsultationScreen(data);
        break;

      case 'consultation_ended':
        _navigateToConsultationSummary(data);
        break;

      case 'prescription_ready':
        _navigateToPrescriptionScreen(data);
        break;

      case 'payment_success':
      case 'payment_failed':
        _navigateToPaymentScreen(data);
        break;

      case 'follow_up_available':
        _navigateToFollowUpScreen(data);
        break;

      case 'review_request':
        _navigateToReviewScreen(data);
        break;

      case 'promotional':
        _navigateToPromotionalScreen(data);
        break;

      default:
        print('⚠️ Unknown notification type: $notificationType');
        Get.offAllNamed('/landing');
    }
  }

  // ==================== Navigation Methods ====================

  static void _navigateToAppointmentDetails(Map<String, dynamic> data) {
    final appointmentId = data['appointment_id'];
    
    if (appointmentId != null) {
      Get.offAllNamed('/landing');
      Get.toNamed('/appointment-details', arguments: {'id': appointmentId});
    } else {
      Get.offAllNamed('/landing');
    }
  }

  static void _navigateToChatScreen(Map<String, dynamic> data) {
    final chatId = data['chat_id'];
    final consultationId = data['consultation_id'];
    
    if (chatId != null || consultationId != null) {
      Get.offAllNamed('/landing');
      Get.toNamed('/chat', arguments: {
        'chat_id': chatId,
        'consultation_id': consultationId,
      });
    } else {
      Get.offAllNamed('/landing');
    }
  }

  static void _navigateToConsultationScreen(Map<String, dynamic> data) {
    final consultationId = data['consultation_id'];
    
    if (consultationId != null) {
      Get.offAllNamed('/landing');
      Get.toNamed('/consultation', arguments: {'id': consultationId});
    } else {
      Get.offAllNamed('/landing');
    }
  }

  static void _navigateToConsultationSummary(Map<String, dynamic> data) {
    final consultationId = data['consultation_id'];
    
    if (consultationId != null) {
      Get.offAllNamed('/landing');
      Get.toNamed('/consultation-summary', arguments: {'id': consultationId});
    } else {
      Get.offAllNamed('/landing');
    }
  }

  static void _navigateToPrescriptionScreen(Map<String, dynamic> data) {
    final prescriptionId = data['prescription_id'];
    final consultationId = data['consultation_id'];
    
    if (prescriptionId != null) {
      Get.offAllNamed('/landing');
      Get.toNamed('/prescription', arguments: {
        'prescription_id': prescriptionId,
        'consultation_id': consultationId,
      });
    } else {
      Get.offAllNamed('/landing');
    }
  }

  static void _navigateToPaymentScreen(Map<String, dynamic> data) {
    final paymentId = data['payment_id'];
    final appointmentId = data['appointment_id'];
    
    if (paymentId != null) {
      Get.offAllNamed('/landing');
      Get.toNamed('/payment-status', arguments: {
        'payment_id': paymentId,
        'appointment_id': appointmentId,
      });
    } else {
      Get.offAllNamed('/landing');
    }
  }

  static void _navigateToFollowUpScreen(Map<String, dynamic> data) {
    final consultationId = data['consultation_id'];
    final doctorId = data['doctor_id'];
    
    if (consultationId != null) {
      Get.offAllNamed('/landing');
      Get.toNamed('/follow-up', arguments: {
        'consultation_id': consultationId,
        'doctor_id': doctorId,
      });
    } else {
      Get.offAllNamed('/landing');
    }
  }

  static void _navigateToReviewScreen(Map<String, dynamic> data) {
    final doctorId = data['doctor_id'];
    final consultationId = data['consultation_id'];
    
    if (doctorId != null) {
      Get.offAllNamed('/landing');
      Get.toNamed('/review-doctor', arguments: {
        'doctor_id': doctorId,
        'consultation_id': consultationId,
      });
    } else {
      Get.offAllNamed('/landing');
    }
  }

  static void _navigateToPromotionalScreen(Map<String, dynamic> data) {
    final screenName = data['screen'];
    final params = data['params'];
    
    if (screenName != null) {
      Get.offAllNamed('/landing');
      Get.toNamed(screenName, arguments: params);
    } else {
      Get.offAllNamed('/landing');
    }
  }
}
