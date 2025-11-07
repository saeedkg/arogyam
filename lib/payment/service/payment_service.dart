import 'dart:async';
import '../entities/payment_method.dart';

class PaymentService {
  // Mock payment methods
  Future<List<PaymentMethod>> getPaymentMethods() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      PaymentMethod(
        id: 'upi',
        name: 'UPI',
        icon: '💳',
        isAvailable: true,
      ),
      PaymentMethod(
        id: 'card',
        name: 'Credit/Debit Card',
        icon: '💳',
        isAvailable: true,
      ),
      PaymentMethod(
        id: 'netbanking',
        name: 'Net Banking',
        icon: '🏦',
        isAvailable: true,
      ),
      PaymentMethod(
        id: 'wallet',
        name: 'Wallet',
        icon: '👛',
        isAvailable: true,
      ),
    ];
  }

  // Mock payment details calculation
  Future<PaymentDetails> calculatePaymentDetails({
    required double consultationFee,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final platformFee = consultationFee * 0.1; // 10% platform fee
    final subtotal = consultationFee + platformFee;
    final gst = subtotal * 0.18; // 18% GST
    final totalAmount = subtotal + gst;

    return PaymentDetails(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      consultationFee: consultationFee,
      platformFee: platformFee,
      gst: gst,
      totalAmount: totalAmount,
      currency: 'INR',
    );
  }

  // Mock process payment
  Future<PaymentResponse> processPayment({
    required String paymentMethodId,
    required double amount,
    required String appointmentId,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate payment processing
    final success = true; // Mock: always success
    
    if (success) {
      return PaymentResponse(
        transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        status: 'success',
        message: 'Payment successful',
        timestamp: DateTime.now(),
      );
    } else {
      throw Exception('Payment failed. Please try again.');
    }
  }
}

