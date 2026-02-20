# Design Document

## Overview

This design outlines a systematic approach to fix the video call reconnection issue by performing deep comparative analysis between the working doctor app and the broken patient app, identifying the root cause, and implementing the exact working solution with comprehensive logging.

The approach is methodical: analyze → identify → replace → log → test → document.

## Architecture

### Phase 1: Deep Analysis Architecture

```
Doctor App (Working)          Patient App (Broken)
├── Video Call Files          ├── Video Call Files
│   ├── Services             │   ├── Services
│   ├── Controllers          │   ├── Controllers
│   ├── Screens              │   ├── Screens
│   ├── Entities             │   ├── Entities
│   └── Utilities            │   └── Utilities
│
└── Comparison Engine
    ├── File Structure Comparison
    ├── Line-by-Line Code Comparison
    ├── Pattern Analysis
    │   ├── GetX Patterns
    │   ├── Stream Management
    │   ├── SDK Lifecycle
    │   └── Disposal Patterns
    └── Difference Categorization
        ├── Critical Differences
        ├── Important Differences
        └── Minor Differences
```

### Phase 2: Implementation Architecture

```
Patient App (Fixed)
├── Video Call Module
│   ├── Entities (from doctor app)
│   │   ├── VideoCallConfig
│   │   ├── ParticipantEvent
│   │   └── [Other entities]
│   │
│   ├── Service Layer (from doctor app)
│   │   ├── RealtimeKitService
│   │   ├── SDK Initialization
│   │   ├── Stream Management
│   │   └── Callback Handling
│   │
│   ├── Controller Layer (from doctor app)
│   │   ├── RealtimeKitVideoCallController
│   │   ├── Lifecycle Management
│   │   ├── State Management
│   │   └── Cleanup Logic
│   │
│   ├── UI Layer (from doctor app)
│   │   ├── RealtimeKitVideoCallScreen
│   │   ├── Initialization Logic
│   │   └── Navigation Handling
│   │
│   └── Logging Layer (new)
│       ├── SDK Lifecycle Logs
│       ├── Controller Lifecycle Logs
│       ├── Stream Event Logs
│       └── Error Logs
```

## Components and Interfaces

### 1. Analysis Components

#### FileDiscoveryComponent
**Purpose:** Identify all video call related files in both projects

**Interface:**
```dart
class FileDiscoveryComponent {
  List<String> discoverVideoCallFiles(String projectPath);
  Map<String, String> mapCorrespondingFiles(
    List<String> doctorFiles,
    List<String> patientFiles
  );
}
```

**Responsibilities:**
- Scan both project directories
- Identify video call related files by pattern matching
- Map corresponding files between projects
- Handle missing files in either project

#### CodeComparisonComponent
**Purpose:** Perform line-by-line comparison of corresponding files

**Interface:**
```dart
class CodeComparisonComponent {
  ComparisonResult compareFiles(String doctorFile, String patientFile);
  List<Difference> identifyDifferences(ComparisonResult result);
  DifferenceCategory categorizeDifference(Difference diff);
}
```

**Responsibilities:**
- Read and parse both files
- Identify line-by-line differences
- Categorize differences by severity
- Generate comparison reports

#### PatternAnalysisComponent
**Purpose:** Analyze specific patterns that could cause reconnection issues

**Interface:**
```dart
class PatternAnalysisComponent {
  GetXPatternAnalysis analyzeGetXPatterns(String code);
  StreamManagementAnalysis analyzeStreamManagement(String code);
  SDKLifecycleAnalysis analyzeSDKLifecycle(String code);
  DisposalPatternAnalysis analyzeDisposalPatterns(String code);
}
```

**Responsibilities:**
- Detect GetX controller registration patterns
- Identify stream controller creation and disposal
- Track SDK initialization and cleanup calls
- Analyze resource disposal patterns

### 2. Implementation Components

#### CodeReplacementComponent
**Purpose:** Replace patient app code with doctor app code

**Interface:**
```dart
class CodeReplacementComponent {
  void replaceFile(String sourceFile, String targetFile);
  void adjustImports(String file, String projectContext);
  void verifyCompilation(List<String> modifiedFiles);
}
```

**Responsibilities:**
- Copy files from doctor app to patient app
- Adjust import statements for patient app context
- Maintain package structure
- Verify no compilation errors

#### LoggingComponent
**Purpose:** Add comprehensive logging to video call lifecycle

**Interface:**
```dart
class LoggingComponent {
  void logSDKInitialization(Map<String, dynamic> config);
  void logControllerLifecycle(String event, String controllerName);
  void logStreamEvent(String streamName, dynamic data);
  void logError(String context, dynamic error, StackTrace? stackTrace);
}
```

**Responsibilities:**
- Add logging statements at critical points
- Format logs for easy debugging
- Include timestamps and context
- Capture error details

### 3. Testing Components

#### ReconnectionTestComponent
**Purpose:** Verify reconnection works after fix

**Test Scenarios:**
1. First call connection
2. First call disconnection and cleanup
3. Second call connection
4. Multiple sequential calls
5. Log verification

## Data Models

### ComparisonResult
```dart
class ComparisonResult {
  final String doctorFilePath;
  final String patientFilePath;
  final List<Difference> differences;
  final bool areIdentical;
  final DateTime comparedAt;
}
```

### Difference
```dart
class Difference {
  final int lineNumber;
  final String doctorCode;
  final String patientCode;
  final DifferenceCategory category;
  final String description;
  final String potentialImpact;
}
```

### DifferenceCategory
```dart
enum DifferenceCategory {
  critical,    // Likely causing the issue
  important,   // Could contribute to the issue
  minor        // Unlikely to cause the issue
}
```

### AnalysisReport
```dart
class AnalysisReport {
  final List<ComparisonResult> fileComparisons;
  final GetXPatternAnalysis getxAnalysis;
  final StreamManagementAnalysis streamAnalysis;
  final SDKLifecycleAnalysis sdkAnalysis;
  final DisposalPatternAnalysis disposalAnalysis;
  final String rootCauseHypothesis;
  final List<String> criticalDifferences;
}
```

## Critical Areas to Analyze

### 1. GetX Controller Lifecycle

**Doctor App Pattern to Verify:**
- How is the controller registered? (Get.put, Get.lazyPut, Get.find)
- Is it permanent or temporary?
- When is it deleted?
- How is it reused on subsequent calls?

**Patient App Pattern to Compare:**
- Same questions as above
- Identify any differences in registration, deletion, or reuse

**Hypothesis:** If patient app uses permanent controllers without proper cleanup, the controller may retain stale state preventing reconnection.

### 2. SDK Initialization Sequence

**Doctor App Pattern to Verify:**
- When is `initialize()` called? (onInit, onReady, initState, build)
- Is there any check to prevent double initialization?
- Is `dispose()` called before re-initialization?
- How are callbacks registered?

**Patient App Pattern to Compare:**
- Same questions as above
- Check for double initialization
- Check for missing dispose calls

**Hypothesis:** If patient app doesn't properly dispose SDK before re-initialization, the SDK may be in an invalid state.

### 3. Stream Controller Management

**Doctor App Pattern to Verify:**
- Are stream controllers `final` or recreatable?
- When are they created?
- When are they closed?
- How are subscriptions managed?

**Patient App Pattern to Compare:**
- Same questions as above
- Check for stream controller recreation attempts
- Check for unclosed streams

**Hypothesis:** If patient app tries to recreate final stream controllers or doesn't close them properly, streams may not work on second call.

### 4. Service Disposal

**Doctor App Pattern to Verify:**
- When is service `dispose()` called?
- What does `dispose()` do?
- Is service recreated for each call?
- How is service lifecycle tied to controller lifecycle?

**Patient App Pattern to Compare:**
- Same questions as above
- Check for premature disposal
- Check for missing disposal

**Hypothesis:** If patient app disposes service too early or doesn't dispose it properly, SDK may not be ready for reconnection.

### 5. Navigation and Screen Lifecycle

**Doctor App Pattern to Verify:**
- How is video call screen navigated to?
- Is screen popped or replaced?
- What happens to controller when screen is closed?
- Are there any navigation guards?

**Patient App Pattern to Compare:**
- Same questions as above
- Check for navigation differences

**Hypothesis:** If patient app navigation doesn't properly cleanup controllers, stale controllers may interfere with new calls.

## Error Handling

### Analysis Phase Errors

**File Not Found:**
- Log which files are missing
- Continue analysis with available files
- Note missing files in report

**Parse Errors:**
- Log which files couldn't be parsed
- Skip detailed comparison for those files
- Note in report

**Access Errors:**
- Log permission issues
- Provide instructions to resolve
- Halt analysis if critical files inaccessible

### Implementation Phase Errors

**Compilation Errors:**
- Log all compilation errors
- Identify which file caused the error
- Provide fix suggestions
- Don't proceed until resolved

**Import Errors:**
- Automatically adjust import paths
- Log any manual adjustments needed
- Verify imports resolve correctly

**Runtime Errors:**
- Capture full stack trace
- Log context of operation
- Compare with doctor app behavior
- Provide diagnostic information

## Testing Strategy

### Unit Testing
- Not applicable for this fix (comparative analysis and code replacement)

### Integration Testing

**Test 1: First Call Connection**
- Start app
- Navigate to video call
- Verify SDK initializes
- Verify connection established
- Verify video/audio streams work
- Check logs for proper initialization sequence

**Test 2: First Call Cleanup**
- End the call
- Verify SDK disposed
- Verify controller cleaned up
- Verify streams closed
- Check logs for proper cleanup sequence

**Test 3: Second Call Connection**
- Navigate to video call again (same meeting)
- Verify SDK re-initializes
- Verify connection established
- Verify video/audio streams work
- Check logs for proper re-initialization sequence

**Test 4: Multiple Sequential Calls**
- Repeat call → end → call cycle 5 times
- Verify each call connects successfully
- Check logs for consistent patterns
- Verify no memory leaks

**Test 5: Log Analysis**
- Review all logs
- Verify no errors or warnings
- Compare log patterns with doctor app
- Identify any anomalies

### Comparison Testing

**Side-by-Side Test:**
- Run same test scenario on doctor app
- Run same test scenario on patient app (after fix)
- Compare logs
- Compare behavior
- Verify they match

## Implementation Phases

### Phase 1: Discovery and Analysis (Tasks 1-3)
- Discover all video call files in both projects
- Perform line-by-line comparison
- Analyze critical patterns
- Generate comprehensive analysis report
- Identify root cause hypothesis

### Phase 2: Code Replacement (Tasks 4-6)
- Replace entity files
- Replace service implementation
- Replace controller implementation
- Replace screen implementation
- Adjust imports and paths
- Verify compilation

### Phase 3: Logging Enhancement (Task 7)
- Add SDK lifecycle logging
- Add controller lifecycle logging
- Add stream event logging
- Add error logging
- Verify logs are comprehensive

### Phase 4: Testing and Verification (Task 8)
- Test first call
- Test cleanup
- Test reconnection
- Test multiple calls
- Analyze logs
- Compare with doctor app

### Phase 5: Documentation (Task 9)
- Document root cause
- Document changes made
- Document why changes work
- Create troubleshooting guide
- Document best practices

## Success Criteria

1. **Analysis Complete:** Comprehensive comparison report generated with root cause identified
2. **Code Replaced:** All video call code matches doctor app implementation
3. **No Compilation Errors:** Patient app compiles successfully
4. **Reconnection Works:** Can join same meeting multiple times successfully
5. **Logs Comprehensive:** Every critical step is logged with context
6. **Documentation Complete:** Clear explanation of what was fixed and why

## Risk Mitigation

**Risk:** Doctor app code may have dependencies not present in patient app
**Mitigation:** Identify all dependencies during analysis, add missing dependencies before replacement

**Risk:** Patient app may have different navigation patterns that break with doctor app code
**Mitigation:** Preserve patient app navigation patterns, only replace video call logic

**Risk:** Fix may work in testing but fail in production
**Mitigation:** Add comprehensive logging to diagnose production issues, test thoroughly before deployment

**Risk:** Root cause may not be in the files being compared
**Mitigation:** Expand analysis to include dependency injection setup, app initialization, and other global configurations
