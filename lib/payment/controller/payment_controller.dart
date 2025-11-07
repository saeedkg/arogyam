import 'package:get/get.dart';
import '../entities/payment_method.dart';
import '../service/payment_service.dart';

class PaymentController extends GetxController {
  final PaymentService service;
  PaymentController({PaymentService? service}) : service = service ?? PaymentService();

  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxnString error = RxnString();
  
  final RxList<PaymentMethod> paymentMethods = <PaymentMethod>[].obs;
  final Rxn<PaymentMethod> selectedPaymentMethod = Rxn<PaymentMethod>();
  final Rxn<PaymentDetails> paymentDetails = Rxn<PaymentDetails>();
  final Rxn<PaymentResponse> paymentResponse = Rxn<PaymentResponse>();

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
  }

  Future<void> loadPaymentMethods() async {
    isLoading.value = true;
    error.value = null;
    try {
      final methods = await service.getPaymentMethods();
      paymentMethods.assignAll(methods);
      if (methods.isNotEmpty) {
        selectedPaymentMethod.value = methods.first;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> calculatePayment(double consultationFee) async {
    isLoading.value = true;
    error.value = null;
    try {
      final details = await service.calculatePaymentDetails(
        consultationFee: consultationFee,
      );
      paymentDetails.value = details;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> processPayment(String appointmentId) async {
    if (selectedPaymentMethod.value == null || paymentDetails.value == null) {
      error.value = 'Please select a payment method';
      return false;
    }

    isProcessing.value = true;
    error.value = null;
    try {
      final response = await service.processPayment(
        paymentMethodId: selectedPaymentMethod.value!.id,
        amount: paymentDetails.value!.totalAmount,
        appointmentId: appointmentId,
      );
      paymentResponse.value = response;
      return response.status == 'success';
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }
}

