import 'package:flutter/material.dart';

class DyteService {
  /// Build DyteUIKit widget with auth token
  /// This follows the Dyte SDK documentation for Flutter
  // static Widget buildMeetingUI({
  //   required String authToken,
  //   Color? brandColor,
  //   Color? backgroundColor,
  // }) {
  //
  //   // Step 1: Build DyteMeetingInfo object (v2 meeting)
  //   final meetingInfo = RtkMeetingInfo(authToken: authToken);
  //
  //   // Step 2: Create DyteUIKitInfo with optional design tokens
  //   final uikitInfo = RealtimeKitUIInfo(
  //     meetingInfo,
  //     designToken: RtkDesignTokens(
  //       colorToken: RtkColorToken(
  //         brandColor: Colors.purple,
  //         backgroundColor: Colors.black,
  //         textOnBackground: Colors.white,
  //         textOnBrand: Colors.white,
  //       ),
  //     ),
  //   );
  //
  //   // Step 3: Build the UIKit
  //   final realtimeKitUI = RealtimeKitUIBuilder.build(uiKitInfo: uikitInfo);
  //
  //   // Step 4: Return the UI widget
  //   return realtimeKitUI;
  // }
}
