# Implementation Plan

- [x] 1. Update dependencies and add logging framework




  - [x] 1.1 Update pubspec.yaml dependencies





    - Change `realtimekit_core: ^0.1.3` to `realtimekit_core: ^0.1.5` for latest stable version
    - Add `logger: ^2.0.0` package for structured logging
    - Note: Keep the iOS fake plugin override - you'll remove it when building for iOS
    - _Requirements: 6.1, 6.2, 3.2_
  
  - [x] 1.2 Run flutter pub get



    - Execute `flutter pub get` to install updated dependencies
    - Verify realtimekit_core resolves to 0.1.5+1 or higher
    - _Requirements: 6.2_

- [x] 2. Create logging utility



  - [x] 2.1 Create `lib/consultation/utils/video_call_logger.dart`



    - Implement VideoCallLogger class with logger package
    - Add log level methods: debug(), info(), warning(), error()
    - Add specialized logging methods: logMeetingInit(), logMeetingJoin(), logConnectionState(), etc.
    - Add token sanitization for security
    - _Requirements: 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

- [x] 3. Fix RealtimeKitService initialization and cleanup



  - [x] 3.1 Add state verification in initializeMeeting()



    - Check if _client already exists before initialization
    - Call dispose() if client exists to clean up previous instance
    - Reset _isDisposed flag and state variables
    - Add logging for state verification steps
    - _Requirements: 2.6, 2.7, 5.6, 5.7_
  
  - [x] 3.2 Remove workarounds from initializeMeeting()

    - Remove manual joinMeeting() call after init()
    - Remove Future.delayed() workaround
    - Remove manual _updateConnectionState(connected) forcing
    - Let SDK callbacks handle state transitions naturally
    - _Requirements: 4.4, 4.6, 1.6_
  
  - [x] 3.3 Implement proper callback-based flow

    - Ensure event listeners are added before init()
    - Let onMeetingInitCompleted() trigger joinRoom()
    - Let onMeetingRoomJoinCompleted() update connection state
    - Add logging in each callback
    - _Requirements: 4.3, 4.5, 4.7_
  
  - [x] 3.4 Implement complete _waitForDisconnection() helper method

    - Create completer-based async wait for disconnection state
    - Listen to connectionStateStream for disconnected state
    - Add 5-second timeout to prevent hanging
    - Cancel subscription and timer properly on completion or timeout
    - Add logging for wait start, completion, and timeout
    - _Requirements: 5.2, 2.10_
  
  - [x] 3.5 Enhance dispose() method with complete cleanup

    - Add _isDisposed and _isLeaving flags to prevent double disposal
    - Check if client exists and is connected before leaving
    - Call leaveMeeting() if currently connected
    - Wait for disconnection using _waitForDisconnection() with timeout
    - Remove event listeners (removeMeetingRoomEventListener, removeParticipantsEventListener)
    - Call cleanAllNativeListeners() to clear native SDK state (CRITICAL for Cloudflare dashboard)
    - Close stream controllers (_connectionStateController, _participantEventController)
    - Set _client to null (CRITICAL - prevents cached state)
    - Reset all state variables (_isAudioEnabled, _isVideoEnabled, _connectionState)
    - Wrap in try-catch and force cleanup even on error
    - Add detailed logging for each cleanup step
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.9, 2.10, 5.1, 5.3, 5.4, 5.5_
  
  - [x] 3.6 Add delay after disposal in initializeMeeting()

    - After calling dispose() in initializeMeeting(), add 500ms delay
    - This gives native SDK time to fully release resources
    - Add logging explaining the delay
    - _Requirements: 2.8, 2.9_

- [x] 4. Replace all print statements with structured logging


  - [x] 4.1 Replace print statements in RealtimeKitService

    - Replace initialization logs with VideoCallLogger.logMeetingInit()
    - Replace callback logs with VideoCallLogger.info() or debug()
    - Replace error logs with VideoCallLogger.error()
    - Replace cleanup logs with VideoCallLogger.logCleanup()
    - Remove all emoji prefixes (🔴, ✅, ❌, ⚠️) from log messages
    - _Requirements: 3.1, 3.3, 3.4, 3.5, 3.6, 3.7_
  
  - [x] 4.2 Replace print statements in RealtimeKitVideoCallController


    - Replace initialization logs with VideoCallLogger
    - Replace error logs with VideoCallLogger.error()
    - Replace participant event logs with VideoCallLogger.logParticipantEvent()
    - Remove all emoji prefixes from log messages
    - _Requirements: 3.1, 3.3, 3.5_

- [ ] 5. Add error handling improvements
  - [ ] 5.1 Create error handler utility
    - Create `lib/consultation/utils/error_handler.dart`
    - Implement handleSDKError() method to categorize MeetingError types
    - Map SDK error codes to VideoCallError types
    - Add logging for each error type
    - _Requirements: 1.3, 1.4, 1.5_
  
  - [ ] 5.2 Integrate error handler in service
    - Wrap SDK calls with try-catch using error handler
    - Use error handler in onMeetingInitFailed() callback
    - Use error handler in onMeetingRoomJoinFailed() callback
    - Provide clear error messages to controller
    - _Requirements: 1.3, 1.4, 1.5_

- [x] 6. Update controller to handle new service behavior


  - [x] 6.1 Update initialize() method

    - Remove manual isLoading.value = false after initializeMeeting()
    - Let connection state callbacks control loading state
    - Add better error handling with specific error types
    - _Requirements: 1.1, 1.2_
  
  - [x] 6.2 Enhance _setupConnectionStateListener()

    - Update isLoading based on connection state (false when connected or failed)
    - Add logging for state transitions
    - _Requirements: 1.1, 1.2_

- [ ] 7. Test and verify fixes
  - [ ] 7.1 Test single call connection and Cloudflare dashboard
    - Join a consultation from the app
    - Open Cloudflare dashboard (https://dash.cloudflare.com/)
    - Navigate to Calls section and verify session appears
    - Verify session shows correct participant count
    - Verify video and audio work correctly in the app
    - Verify all SDK callbacks fire properly (check logs)
    - End the call and verify session closes in dashboard
    - _Requirements: 1.1, 1.2, 1.3, 1.8_
  
  - [ ] 7.2 Test multiple calls without restart (CRITICAL TEST)
    - Join a consultation and verify it appears in Cloudflare dashboard
    - End the call properly using end call button
    - Wait 2-3 seconds for cleanup to complete
    - Join a SECOND consultation (same or different room)
    - Verify second session appears in Cloudflare dashboard (this is the key test!)
    - Verify second call connects without force closing app
    - Check logs for proper cleanup between calls
    - Verify no "client already exists" warnings
    - Repeat 2-3 times to ensure consistency
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10, 1.2_
  
  - [ ] 7.3 Test error scenarios
    - Test with invalid auth token
    - Test with network disconnection
    - Test with permission denial
    - Verify error messages are clear and actionable
    - _Requirements: 1.3, 1.4, 1.5_
  
  - [ ] 7.4 Test on iOS device
    - Remove fake plugin override from pubspec.yaml
    - Build and run on iOS device or simulator
    - Verify camera and microphone permissions work
    - Test single call connection on iOS
    - Test multiple calls without restart on iOS
    - Verify background audio works (if implemented)
    - _Requirements: 1.1, 2.1, 2.2_

- [ ] 8. iOS-specific configuration and verification
  - [ ] 8.1 Verify iOS permissions in Info.plist
    - Confirm NSCameraUsageDescription is present
    - Confirm NSMicrophoneUsageDescription is present
    - Verify permission descriptions are user-friendly
    - _Requirements: 1.1_
  
  - [ ] 8.2 Add iOS background audio support (optional)
    - Add UIBackgroundModes to Info.plist with 'audio' and 'voip'
    - This allows audio to continue when app is backgrounded
    - Test backgrounding app during call
    - _Requirements: 1.1_
  
  - [ ] 8.3 Verify iOS build configuration
    - Check Podfile has platform :ios, '15.0' or higher
    - Verify use_frameworks! is present
    - Confirm Swift version is 5.0+
    - Run `cd ios && pod install` to update pods
    - _Requirements: 6.1, 6.2_

- [ ] 9. Android-specific verification
  - [ ] 9.1 Verify Android permissions in AndroidManifest.xml
    - Confirm CAMERA permission is present
    - Confirm RECORD_AUDIO permission is present
    - Confirm INTERNET permission is present
    - Check for MODIFY_AUDIO_SETTINGS permission
    - Check for ACCESS_NETWORK_STATE permission
    - _Requirements: 1.1_
  
  - [ ] 9.2 Test on Android device
    - Build and run on Android device or emulator
    - Test single call connection
    - Test multiple calls without restart
    - Verify permissions are requested properly
    - _Requirements: 1.1, 2.1, 2.2_

- [ ] 10. Documentation and cleanup
  - [ ] 10.1 Update documentation files
    - Update REALTIMEKIT_SDK_INTEGRATED.md with new patterns
    - Remove workaround mentions from documentation
    - Add logging best practices
    - Document the proper initialization flow
    - Add iOS-specific setup instructions
    - Document fake plugin override removal for iOS builds
    - _Requirements: 4.1, 4.2_
  
  - [ ] 10.2 Remove obsolete documentation
    - Archive or remove HOW_TO_INTEGRATE_REALTIMEKIT_SDK.md (outdated)
    - Clean up redundant documentation files
    - _Requirements: 4.1_
  
  - [ ] 10.3 Create platform-specific build notes
    - Document when to enable/disable iOS fake plugin override
    - Add iOS build instructions (pod install, etc.)
    - Add Android build verification steps
    - _Requirements: 4.1_
