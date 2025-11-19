# Implementation Plan

- [x] 1. Add realtimekit_core dependency and configure permissions



  - Add `realtimekit_core: ^0.1.3` to pubspec.yaml dependencies
  - Configure Android permissions in AndroidManifest.xml (CAMERA, RECORD_AUDIO, INTERNET)
  - Configure iOS permissions in Info.plist (NSCameraUsageDescription, NSMicrophoneUsageDescription)
  - Run `flutter pub get` to install dependencies





  - _Requirements: 1.1, 1.2, 1.3_



- [ ] 2. Create data models and enums
  - [ ] 2.1 Create ConnectionState enum
    - Define enum with states: disconnected, connecting, connected, reconnecting, failed

    - _Requirements: 3.3, 3.4_

  




  - [ ] 2.2 Create VideoCallConfig model
    - Create model class with authToken, roomName, participantId, doctor info fields
    - Add constructor and validation
    - _Requirements: 3.2_


  
  - [ ] 2.3 Create VideoCallError model
    - Create error model with type, message, technicalDetails, isRecoverable fields
    - Add getUserMessage() method for user-friendly error messages
    - Create VideoCallErrorType enum


    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 3. Implement RealtimeKitService
  - [x] 3.1 Create service class structure

    - Create `lib/consultation/service/realtimekit_service.dart`

    - Define class with private RealtimeKit client instance
    - Add state properties (isAudioEnabled, isVideoEnabled, connectionState)
    - _Requirements: 3.2, 3.3_


  
  - [ ] 3.2 Implement meeting initialization
    - Create initializeMeeting() method that accepts authToken, roomName, participantId
    - Initialize RtkMeetingInfo with credentials
    - Create and initialize RealtimeKit client

    - Handle initialization errors

    - _Requirements: 3.2, 5.1_
  
  - [x] 3.3 Implement join and leave meeting methods




    - Create joinMeeting() method to join the room
    - Create leaveMeeting() method to disconnect and cleanup
    - Handle connection errors
    - _Requirements: 3.3, 3.4, 6.4_
  


  - [ ] 3.4 Implement audio and video controls
    - Create toggleAudio() method to enable/disable microphone
    - Create toggleVideo() method to enable/disable camera
    - Update state properties when toggled
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  
  - [x] 3.5 Add event listeners and streams


    - Set up meeting room event listeners
    - Create connectionStateStream for connection state changes
    - Create participantEventStream for participant events
    - Handle participant joined/left events
    - _Requirements: 3.3, 5.3_

  

  - [ ] 3.6 Implement resource cleanup
    - Create dispose() method to release all resources
    - Remove event listeners
    - Disconnect from meeting


    - Clean up media streams
    - _Requirements: 6.1, 6.4_

- [x] 4. Implement RealtimeKitVideoCallController

  - [-] 4.1 Create controller class structure

    - Create `lib/consultation/controller/realtimekit_video_call_controller.dart`
    - Extend GetxController




    - Define observable state properties (isLoading, isConnected, isAudioEnabled, isVideoEnabled, error)
    - Add doctor info and meeting credential properties
    - _Requirements: 3.2, 4.1, 4.3_
  
  - [x] 4.2 Implement initialization logic


    - Create initialize() method
    - Initialize RealtimeKitService
    - Call service.initializeMeeting() with credentials
    - Call service.joinMeeting()
    - Update loading and connection states


    - Handle errors and update error state
    - _Requirements: 3.2, 3.3, 5.1_
  
  - [ ] 4.3 Implement audio and video toggle methods
    - Create toggleAudio() method that calls service.toggleAudio()


    - Update isAudioEnabled observable
    - Create toggleVideo() method that calls service.toggleVideo()
    - Update isVideoEnabled observable
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  
  - [x] 4.4 Implement end call logic

    - Create endCall() method

    - Call service.leaveMeeting()
    - Navigate back to previous screen
    - Handle errors during disconnect


    - _Requirements: 4.5, 4.6, 6.5_
  
  - [ ] 4.5 Add error handling
    - Create handleError() method to process errors
    - Update error observable with user-friendly messages

    - Log technical details for debugging

    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  
  - [ ] 4.6 Implement lifecycle management
    - Override onInit() to set up listeners



    - Override onClose() to dispose service and cleanup
    - Handle app lifecycle changes (background/foreground)
    - _Requirements: 6.1, 6.2, 6.3, 6.4_



- [ ] 5. Create RealtimeKitVideoCallScreen UI
  - [ ] 5.1 Create screen structure and layout
    - Create `lib/consultation/ui/realtimekit_video_call_screen.dart`
    - Set up Scaffold with black background


    - Create Stack-based layout for video and controls
    - Initialize controller with Get.put()
    - _Requirements: 2.1, 2.6_
  


  - [ ] 5.2 Implement video rendering
    - Add RealtimeKitVideoView for remote video (full screen)
    - Add RealtimeKitVideoView for local video (PiP overlay, top-right)




    - Position local video with Positioned widget
    - Add placeholder when video is disabled
    - _Requirements: 2.1, 2.2, 4.4_


  
  - [ ] 5.3 Create top bar with doctor info
    - Add semi-transparent overlay container at top
    - Display doctor name and specialization

    - Add call duration timer

    - Add network quality indicator
    - _Requirements: 2.6_
  


  - [ ] 5.4 Create bottom control bar
    - Add semi-transparent overlay container at bottom
    - Create microphone toggle button with icon
    - Create camera toggle button with icon


    - Create end call button (red, prominent)
    - Add visual indicators for muted/disabled states
    - _Requirements: 2.3, 2.4, 2.5_
  


  - [-] 5.5 Implement loading state UI

    - Create loading widget with CircularProgressIndicator
    - Display "Connecting..." message
    - Show doctor info during connection
    - _Requirements: 3.3_
  
  - [ ] 5.6 Implement error state UI
    - Create error widget with error icon
    - Display user-friendly error message
    - Add retry button
    - Add go back button
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  
  - [ ] 5.7 Wire up control button actions
    - Connect mic button to controller.toggleAudio()
    - Connect camera button to controller.toggleVideo()
    - Connect end call button to show confirmation dialog
    - Update button states based on controller observables
    - _Requirements: 4.1, 4.2, 4.3, 4.5_
  
  - [ ] 5.8 Add end call confirmation dialog
    - Create confirmation dialog when end call button is tapped
    - Show "Are you sure you want to end the call?" message
    - Add Cancel and End Call buttons
    - Call controller.endCall() on confirmation
    - _Requirements: 4.5, 4.6_
  
  - [ ] 5.9 Apply app design system styling
    - Use AppColors for all color values
    - Apply consistent border radius and spacing
    - Use app fonts and text styles
    - Ensure buttons follow app button styles
    - _Requirements: 2.7_

- [ ] 6. Update PendingConsultationScreen navigation
  - Update _joinConsultation() method to navigate to RealtimeKitVideoCallScreen
  - Pass VideoCallConfig with all required parameters (authToken, roomName, participantId, doctor info)
  - Remove old VideoCallScreen navigation
  - _Requirements: 3.1_

- [ ] 7. Add route configuration
  - Add route for RealtimeKitVideoCallScreen in app_routes.dart
  - Configure route with proper parameters
  - _Requirements: 3.1_

- [ ] 8. Handle edge cases and cleanup
  - [ ] 8.1 Add navigation guard for active calls
    - Override WillPopScope in video call screen
    - Show confirmation dialog when user tries to navigate back during active call
    - _Requirements: 6.5_
  
  - [ ] 8.2 Handle missing credentials
    - Validate authToken, roomName, participantId before initialization
    - Show error screen if any credential is missing
    - Prevent joining with invalid credentials
    - _Requirements: 5.1_
  
  - [ ] 8.3 Add connection state indicators
    - Show reconnecting indicator when connection is lost
    - Display connection quality indicator
    - Handle doctor disconnect notification
    - _Requirements: 5.2, 5.3_
  
  - [ ] 8.4 Implement proper resource cleanup
    - Ensure dispose is called on controller
    - Verify all listeners are removed
    - Confirm media resources are released
    - Test memory leaks with multiple join/leave cycles
    - _Requirements: 6.1, 6.4_

- [ ] 9. Update existing video call files
  - Remove or deprecate old VideoCallScreen implementation
  - Remove or deprecate DyteService
  - Update imports in any files referencing old implementation
  - _Requirements: 3.1_

- [ ] 10. Integration and end-to-end verification
  - Test complete flow from PendingConsultationScreen to video call
  - Verify audio and video controls work correctly
  - Test end call flow and navigation back
  - Verify error handling for various scenarios
  - Test with different network conditions
  - Verify UI responsiveness and performance
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 5.1, 5.2, 5.3, 5.4, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5, 7.1, 7.2, 7.3, 7.4, 7.5_
