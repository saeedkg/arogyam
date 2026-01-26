# Implementation Plan: Swift Package Manager Migration

## Overview

This plan outlines the step-by-step migration from CocoaPods-only to hybrid mode (SPM + CocoaPods) for a Flutter iOS project. The migration is primarily configuration-based, leveraging Flutter's automatic migration tooling. Each task builds incrementally, with checkpoints to validate progress.

## Tasks

- [x] 1. Pre-migration validation and backup
  - Verify Flutter SDK version is 3.24.0 or higher
  - Document current CocoaPods dependencies in Podfile.lock
  - Create backup of ios/ directory
  - Verify project builds successfully with current CocoaPods setup
  - _Requirements: 1.1, 1.2_

- [x] 2. Enable Swift Package Manager
  - [x] 2.1 Enable SPM globally via Flutter CLI
    - Run `flutter config --enable-swift-package-manager`
    - Verify global configuration in ~/.flutter_settings
    - _Requirements: 2.1_
  
  - [x] 2.2 Enable SPM in project configuration
    - Update pubspec.yaml with `enable-swift-package-manager: true` under flutter section
    - Verify both global and project configurations are set
    - _Requirements: 2.2, 2.4_

- [x] 3. Clean existing dependency artifacts
  - Remove ios/Pods directory
  - Remove ios/Podfile.lock
  - Remove ios/.symlinks directory
  - Run `flutter clean` to remove build artifacts
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 4. Add SPM-only dependency
  - Add `realtimekit_core: ^0.1.3` to pubspec.yaml dependencies
  - Run `flutter pub get` to resolve dependencies
  - Verify dependency is resolved (check pubspec.lock)
  - _Requirements: 5.1_

- [x] 5. Trigger automatic plugin migration
  - Run `flutter run` to trigger SPM migration analysis
  - Monitor console output for migration messages
  - Verify FlutterGeneratedPluginSwiftPackage is created in ios/Flutter/ephemeral/Packages/
  - Verify "Run Prepare Flutter Framework Script" pre-action is added to Xcode scheme
  - _Requirements: 3.1, 3.4, 3.5_

- [x] 6. Verify plugin migration results
  - Open ios/Runner.xcodeproj in Xcode
  - Check Package Dependencies section for FlutterGeneratedPluginSwiftPackage
  - Verify SPM-compatible plugins are listed in Package.swift
  - Verify razorpay_flutter and file_picker dependencies remain in Podfile
  - _Requirements: 3.2, 3.3, 4.1, 4.4, 4.5_

- [x] 7. Configure Podfile for hybrid mode
  - Update Podfile platform to `platform :ios, '15.0'`
  - Add post_install hook to set IPHONEOS_DEPLOYMENT_TARGET to '15.0'
  - Verify Podfile uses `flutter_install_all_ios_pods` (automatically excludes SPM plugins)
  - Run `pod install` to regenerate CocoaPods dependencies
  - _Requirements: 6.2, 7.1, 7.2, 8.5_

- [x] 8. Verify deployment target consistency
  - Check project.pbxproj for IPHONEOS_DEPLOYMENT_TARGET = 15.0
  - Check Podfile for platform :ios, '15.0'
  - Check FlutterGeneratedPluginSwiftPackage/Package.swift for .iOS("15.0")
  - Verify all three match
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ]* 8.1 Write property test for deployment target consistency
  - **Property 3: Deployment Target Consistency**
  - **Validates: Requirements 6.4**

- [ ] 9. Verify Xcode project integration
  - Open ios/Runner.xcodeproj in Xcode
  - Verify Runner target links FlutterGeneratedPluginSwiftPackage
  - Verify Runner target links CocoaPods frameworks (Pods_Runner.framework)
  - Check Run scheme for "Run Prepare Flutter Framework Script" pre-action
  - _Requirements: 9.1, 9.2, 9.3_

- [x] 10. Build and validate
  - Run `flutter build ios --debug` from command line
  - Verify build succeeds without errors
  - Open project in Xcode and build from IDE
  - Verify both SPM and CocoaPods dependencies link correctly
  - _Requirements: 9.4_

- [ ] 11. Checkpoint - Ensure build succeeds
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 12. Create test application code for dependency validation
  - Create a test file that imports razorpay_flutter
  - Create a test file that imports realtimekit_core
  - Create test files for other migrated plugins (connectivity_plus, device_info_plus, etc.)
  - Verify all imports compile without errors
  - _Requirements: 5.4, 10.1, 10.2, 10.3_

- [ ]* 12.1 Write property test for plugin migration correctness
  - **Property 1: Plugin Migration Correctness**
  - **Validates: Requirements 2.3, 3.2, 3.3**

- [ ]* 12.2 Write property test for Podfile hybrid mode correctness
  - **Property 2: Podfile Hybrid Mode Correctness**
  - **Validates: Requirements 7.1, 7.2**

- [ ]* 12.3 Write property test for plugin functionality
  - **Property 4: Plugin Functionality After Migration**
  - **Validates: Requirements 10.3**

- [ ] 13. Create rollback script
  - [ ] 13.1 Write rollback script that performs the following:
    - Set `enable-swift-package-manager: false` in pubspec.yaml
    - Run `flutter config --no-enable-swift-package-manager`
    - Remove FlutterGeneratedPluginSwiftPackage from Xcode project
    - Run `flutter clean`
    - Run `pod install`
    - Run `flutter pub get`
    - _Requirements: 11.1, 11.2, 11.3_
  
  - [ ]* 13.2 Test rollback script
    - Execute rollback script
    - Verify all plugins are back on CocoaPods
    - Verify project builds successfully
    - Re-run migration to restore hybrid mode
    - _Requirements: 11.4, 11.5_
  
  - [ ]* 13.3 Write property test for rollback completeness
    - **Property 5: Rollback Completeness**
    - **Validates: Requirements 11.4**

- [ ] 14. Create migration documentation
  - Document the migration steps performed
  - Document the current hybrid mode configuration
  - Document which plugins are on SPM vs CocoaPods
  - Document rollback procedure
  - Document troubleshooting steps for common issues
  - _Requirements: All_

- [ ] 15. Final checkpoint - Verify complete migration
  - Ensure all tests pass, ask the user if questions arise.
  - Verify both SPM and CocoaPods dependencies work correctly
  - Verify deployment target is consistent across all configurations
  - Verify rollback procedure is documented and tested

## Notes

- Tasks marked with `*` are optional and can be skipped for faster migration completion
- This is a configuration migration, not a code implementation - most tasks involve file modifications and command execution
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation of the migration process
- Property tests validate universal correctness properties about the migration
- The rollback script provides a safety net if issues arise
