import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/dyte_service.dart';
import '../../_shared/ui/app_colors.dart';

class VideoCallScreen extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final String hospital;
  final String doctorImageUrl;
  final String? authToken;
  final String? roomName;
  final String? participantId;

  const VideoCallScreen({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.hospital,
    required this.doctorImageUrl,
    this.authToken,
    this.roomName,
    this.participantId,
  });

  @override
  Widget build(BuildContext context) {
    // Validate auth token
    if (authToken == null || authToken!.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        appBar: AppBar(
          title: const Text('Video Consultation'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.errorRed,
                  size: 64,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Unable to Join',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Missing authentication token. Please try again.',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }


    return Scaffold(
      body: DyteService.buildMeetingUI(
        authToken: authToken!,
      //  authToken: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJvcmdJZCI6ImE1MDI5ODdlLTc5ZTUtNDY2NS1iYWFkLWI0NjY1YjliM2VmYyIsIm1lZXRpbmdJZCI6ImJiYmRlMzgwLTlmMmEtNDU0Yy04Y2I2LWRhODI5NDcxOTQ0NiIsInBhcnRpY2lwYW50SWQiOiJhYWEyZTFmZS03MGZmLTQ4MmUtOWIxNi1hYWM0OGE1NmM5ODkiLCJwcmVzZXRJZCI6IjI1NmUxOGJhLWJmZDItNDVkYS1iZjA5LWIyZjVmMTJlY2E1MCIsImlhdCI6MTc2MjQyNjM5NSwiZXhwIjoxNzcxMDY2Mzk1fQ.aTya8u8IL_MCVLlpY1bml3p_gledFWoHZooSYBxu3X1PI1jUsQ3aERNmXBUDp1UE1-8ub3-7v-QVwBezfnyhavWannQK7pR8_Q5Su5iKarQmPcC4eGoLhEyA59qHKLIwqyh8h6w_xTBN-hkk81dOoQ0sBrBu81FI4JY1duCHYFHTajD0nw6j-qFVkGccIbQciN64rz-hInLLq86zenPwLv-_eT8nVy-h6gto7k9KwJwgED3XrBQeR0bcwO-oePaBiTqmSIB48jTz4s1Ga_KUR93NFcktYbYLgmhJwkWpjoZPGJwVeoWyhCEsBkZMipYShnLl47GtZgFw0FJGIZdcFA",
        brandColor: AppColors.primaryBlue,
        backgroundColor: AppColors.backgroundBlack,
      ),
    );

    //   return Scaffold(
    //       body: Center(
    //         child: Container(
    //           child:MaterialButton(
    //             color: Colors.black,
    //             onPressed: () {
    //               Navigator.push(
    //                 context,
    //                 MaterialPageRoute(builder: (context) {
    //
    //                   Widget  uiKit= DyteService.buildMeetingUI(
    //                     authToken: authToken!,
    //                     brandColor: AppColors.primaryBlue,
    //                     backgroundColor: AppColors.backgroundBlack,
    //                   );
    //
    //                   return DyteMeetingPage(uiKit);
    //                 }),
    //               );
    //               // DyteUIKit.loadUI();
    //             },
    //             child: const Text(
    //               "Load UIKit",
    //               style: TextStyle(color: Colors.white),
    //             ),
    //           ),
    //         ),
    //       ));
    // }
  }
}