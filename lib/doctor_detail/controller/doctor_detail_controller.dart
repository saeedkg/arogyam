import 'package:get/get.dart';
import '../entities/doctor_detail_data.dart';
import '../service/doctor_detail_service.dart';

class DoctorDetailPageController extends GetxController {
  final DoctorDetailService service;
  DoctorDetailPageController({DoctorDetailService? service}) : service = service ?? DoctorDetailService();

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final Rxn<DoctorDetailData> doctor = Rxn<DoctorDetailData>();

  Future<void> load(String doctorId) async {
    isLoading.value = true;
    error.value = null;
    try {
      doctor.value = await service.getDoctorDetail(doctorId);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

