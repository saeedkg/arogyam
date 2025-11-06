import 'package:dyte_uikit/dyte_uikit.dart';
import 'package:flutter/material.dart';

class DyteService {
  /// Build DyteUIKit widget with auth token
  /// This follows the Dyte SDK documentation for Flutter
  static Widget buildMeetingUI({
    required String authToken,
    Color? brandColor,
    Color? backgroundColor,
  }) {
    // Step 1: Build DyteMeetingInfo object (v2 meeting)
    final meetingInfo = DyteMeetingInfoV2(authToken: authToken);

    // Step 2: Create DyteUIKitInfo with optional design tokens
    final uikitInfo = DyteUIKitInfo(
      meetingInfo,
      designToken: DyteDesignTokens(
        colorToken: DyteColorToken(
          brandColor: brandColor ?? Colors.blue,
          backgroundColor: backgroundColor ?? Colors.black,
          textOnBackground: Colors.white,
          textOnBrand: Colors.white,
        ),
      ),
    );

    // Step 3: Build the UIKit
    final uiKit = DyteUIKitBuilder.build(uiKitInfo: uikitInfo);

    // Step 4: Return the UI widget
    return uiKit.loadUI();
  }
}
