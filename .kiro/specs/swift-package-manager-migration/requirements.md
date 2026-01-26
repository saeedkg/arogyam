# Requirements Document

## Introduction

This document specifies the requirements for migrating a Flutter iOS project from CocoaPods-only dependency management to hybrid mode, where Swift Package Manager (SPM) and CocoaPods coexist. The migration enables the use of SPM-only packages (realtimekit_core) while maintaining CocoaPods-only dependencies (razorpay_flutter).

## Glossary

- **SPM**: Swift Package Manager - Apple's native dependency management system
- **CocoaPods**: Ruby-based dependency management system for iOS projects
- **Hybrid_Mode**: Configuration where both SPM and CocoaPods manage dependencies simultaneously
- **Flutter_Plugin**: A Flutter package that contains platform-specific code for iOS/Android
- **Migration_System**: The automated Flutter tooling that converts compatible plugins from CocoaPods to SPM
- **FlutterGeneratedPluginSwiftPackage**: The Xcode package automatically created by Flutter to manage SPM dependencies
- **Podfile**: Configuration file that specifies CocoaPods dependencies
- **Deployment_Target**: The minimum iOS version required to run the application (15.0)

## Requirements

### Requirement 1: Flutter SDK Upgrade

**User Story:** As a developer, I want to upgrade the Flutter SDK to version 3.24 or higher, so that I can use Swift Package Manager support.

#### Acceptance Criteria

1. WHEN the Flutter SDK version is checked, THE Migration_System SHALL verify the version is 3.24.0 or higher
2. IF the Flutter SDK version is below 3.24.0, THEN THE Migration_System SHALL report an error indicating upgrade is required
3. WHEN the Flutter SDK is upgraded, THE Migration_System SHALL preserve all existing project configurations

### Requirement 2: SPM Configuration Enablement

**User Story:** As a developer, I want to enable Swift Package Manager in my Flutter project, so that I can use SPM-only dependencies.

#### Acceptance Criteria

1. WHEN the developer runs `flutter config --enable-swift-package-manager`, THE Migration_System SHALL enable SPM globally
2. WHEN the pubspec.yaml is updated with `enable-swift-package-manager: true`, THE Migration_System SHALL enable SPM for the project
3. WHEN SPM is enabled, THE Migration_System SHALL maintain backward compatibility with existing CocoaPods dependencies
4. THE Migration_System SHALL verify both configuration changes are applied before proceeding

### Requirement 3: Automatic Plugin Migration

**User Story:** As a developer, I want Flutter to automatically migrate SPM-compatible plugins from CocoaPods to SPM, so that I don't have to manually configure each dependency.

#### Acceptance Criteria

1. WHEN `flutter run` is executed after enabling SPM, THE Migration_System SHALL analyze all Flutter plugins for SPM compatibility
2. WHEN a plugin supports SPM, THE Migration_System SHALL migrate it from CocoaPods to SPM automatically
3. WHEN a plugin does not support SPM, THE Migration_System SHALL keep it managed by CocoaPods
4. WHEN migration completes, THE Migration_System SHALL generate FlutterGeneratedPluginSwiftPackage in the Xcode project
5. THE Migration_System SHALL add the "Run Prepare Flutter Framework Script" pre-action to the Xcode scheme

### Requirement 4: CocoaPods-Only Dependency Preservation

**User Story:** As a developer, I want razorpay_flutter and its dependencies to remain on CocoaPods, so that payment functionality continues working without modification.

#### Acceptance Criteria

1. WHEN migration occurs, THE Migration_System SHALL keep razorpay_flutter managed by CocoaPods
2. WHEN migration occurs, THE Migration_System SHALL keep razorpay-pod managed by CocoaPods
3. WHEN migration occurs, THE Migration_System SHALL keep razorpay-core-pod managed by CocoaPods
4. WHEN migration occurs, THE Migration_System SHALL keep file_picker dependencies (DKImagePickerController, DKPhotoGallery, SDWebImage, SwiftyGif) managed by CocoaPods
5. THE Migration_System SHALL verify these dependencies remain in Podfile after migration

### Requirement 5: SPM-Only Dependency Addition

**User Story:** As a developer, I want to add realtimekit_core as an SPM dependency, so that I can use its real-time communication features.

#### Acceptance Criteria

1. WHEN realtimekit_core: ^0.1.3 is added to pubspec.yaml, THE Migration_System SHALL resolve it via SPM
2. WHEN realtimekit_core is resolved, THE Migration_System SHALL add it to FlutterGeneratedPluginSwiftPackage
3. IF realtimekit_core cannot be resolved via SPM, THEN THE Migration_System SHALL report a clear error message
4. THE Migration_System SHALL verify realtimekit_core is accessible to the iOS application code

### Requirement 6: Deployment Target Consistency

**User Story:** As a developer, I want the iOS deployment target to remain 15.0 across all configurations, so that the app maintains its minimum OS version requirement.

#### Acceptance Criteria

1. WHEN migration occurs, THE Migration_System SHALL preserve iOS deployment target 15.0 in project.pbxproj
2. WHEN migration occurs, THE Migration_System SHALL set iOS deployment target 15.0 in Podfile
3. WHEN migration occurs, THE Migration_System SHALL verify FlutterGeneratedPluginSwiftPackage uses iOS deployment target 15.0
4. THE Migration_System SHALL validate all three configurations match before completing migration

### Requirement 7: Podfile Hybrid Mode Configuration

**User Story:** As a developer, I want the Podfile to work correctly in hybrid mode, so that CocoaPods dependencies coexist with SPM dependencies.

#### Acceptance Criteria

1. WHEN hybrid mode is active, THE Podfile SHALL include all CocoaPods-managed plugins
2. WHEN hybrid mode is active, THE Podfile SHALL exclude SPM-migrated plugins
3. WHEN hybrid mode is active, THE Podfile SHALL set the correct deployment target
4. THE Podfile SHALL maintain compatibility with Flutter's generated plugin registration

### Requirement 8: Dependency Resolution and Cleanup

**User Story:** As a developer, I want to clean and rebuild dependencies properly, so that no conflicts exist between old and new dependency configurations.

#### Acceptance Criteria

1. WHEN migration begins, THE Migration_System SHALL remove the Pods directory
2. WHEN migration begins, THE Migration_System SHALL remove Podfile.lock
3. WHEN migration begins, THE Migration_System SHALL remove .symlinks directory
4. WHEN migration begins, THE Migration_System SHALL clean Flutter build artifacts
5. WHEN cleanup completes, THE Migration_System SHALL run `pod install` to regenerate CocoaPods dependencies
6. WHEN cleanup completes, THE Migration_System SHALL run `flutter pub get` to resolve all dependencies

### Requirement 9: Xcode Project Integration Verification

**User Story:** As a developer, I want to verify the Xcode project is correctly configured for hybrid mode, so that builds succeed in both Xcode and command line.

#### Acceptance Criteria

1. WHEN migration completes, THE Migration_System SHALL verify FlutterGeneratedPluginSwiftPackage exists in Package Dependencies
2. WHEN migration completes, THE Migration_System SHALL verify "Run Prepare Flutter Framework Script" pre-action exists in the Run scheme
3. WHEN migration completes, THE Migration_System SHALL verify the Runner target links both CocoaPods frameworks and SPM packages
4. THE Migration_System SHALL verify the project builds successfully in Xcode

### Requirement 10: Dependency Functionality Validation

**User Story:** As a developer, I want to verify both CocoaPods and SPM dependencies work correctly, so that all features function as expected after migration.

#### Acceptance Criteria

1. WHEN the application runs, THE Migration_System SHALL verify razorpay_flutter functionality is accessible
2. WHEN the application runs, THE Migration_System SHALL verify realtimekit_core functionality is accessible
3. WHEN the application runs, THE Migration_System SHALL verify all other migrated plugins function correctly
4. IF any dependency fails to load, THEN THE Migration_System SHALL report which dependency failed and why

### Requirement 11: Rollback Capability

**User Story:** As a developer, I want the ability to rollback to CocoaPods-only mode, so that I can recover if migration causes issues.

#### Acceptance Criteria

1. WHEN rollback is requested, THE Migration_System SHALL set `enable-swift-package-manager: false` in pubspec.yaml
2. WHEN rollback is requested, THE Migration_System SHALL run `flutter config --no-enable-swift-package-manager`
3. WHEN rollback is requested, THE Migration_System SHALL remove FlutterGeneratedPluginSwiftPackage from Xcode project
4. WHEN rollback is requested, THE Migration_System SHALL restore all plugins to CocoaPods management
5. WHEN rollback completes, THE Migration_System SHALL verify the project builds successfully with CocoaPods only
