import 'package:get/get.dart';
import '../entities/appointment_booking_request.dart';
import '../entities/booking_response.dart';
import '../service/booking_service.dart';

class BookingController extends GetxController {
  final BookingService service;
  BookingController({BookingService? service}) : service = service ?? BookingService();

  final RxBool isBooking = false.obs;
  final RxnString bookingError = RxnString();
  final Rxn<BookingResponse> bookingResult = Rxn<BookingResponse>();

  Future<void> book(AppointmentBookingRequest req) async {
    isBooking.value = true;
    bookingError.value = null;
    bookingResult.value = null;
    try {
      bookingResult.value = await service.bookAppointment(req);
    } catch (e) {
      bookingError.value = e.toString();
    } finally {
      isBooking.value = false;
    }
  }
}
