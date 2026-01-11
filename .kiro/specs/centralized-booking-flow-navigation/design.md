# Design Document

## Overview

The Centralized Booking Flow Navigation system provides a callback-based orchestration mechanism for managing the complex multi-screen doctor booking process. The system uses a centralized BookingFlowManager that coordinates navigation between screens through asynchronous callbacks, maintaining flow context and handling navigation stack management automatically.

## Architecture

The system follows a centralized orchestration pattern with the following key components:

```
Dashboard → BookingFlowManager → Screen1 (with callback) → Screen2 (with callback) → ... → PendingConsultation
                ↓
        Centralized Decision Making
                ↓
        Navigation Stack Management
```

### Core Components:

1. **BookingFlowManager**: Central orchestrator managing the entire flow
2. **FlowStep**: Individual screen implementations with callback registration
3. **FlowContext**: Shared data container passed between screens
4. **CallbackRegistry**: Management system for screen callbacks
5. **NavigationController**: Stack management and navigation execution

## Components and Interfaces

### BookingFlowManager

```dart
class BookingFlowManager {
  // Flow initiation
  Future<void> startBookingFlow({
    BookingFlowEntry entry,
    Map<String, dynamic>? initialContext,
  });
  
  // Callback registration
  void registerStepCallback<T>(
    String stepId, 
    Future<FlowResult<T>> Function(FlowContext context) callback
  );
  
  // Flow execution
  Future<void> executeStep(String stepId, FlowContext context);
  
  // Navigation management
  Future<void> navigateToNextStep(FlowResult result);
  void clearNavigationStack();
  
  // Context management
  void updateFlowContext(String key, dynamic value);
  FlowContext getFlowContext();
}
```

### FlowContext

```dart
class FlowContext {
  String? consultationType;
  String? selectedSpecialization;
  String? selectedDoctorId;
  String? selectedTimeSlot;
  String? selectedPatientId;
  double? consultationFee;
  String? appointmentId;
  Map<String, dynamic> additionalData;
  
  void updateContext(String key, dynamic value);
  T? getValue<T>(String key);
}
```

### FlowResult

```dart
class FlowResult<T> {
  final FlowResultType type;
  final T? data;
  final String? nextStep;
  final String? errorMessage;
  
  // Factory constructors
  FlowResult.success(T data, {String? nextStep});
  FlowResult.error(String message);
  FlowResult.cancel();
}

enum FlowResultType { success, error, cancel, back }
```

### FlowStep Interface

```dart
abstract class FlowStep {
  String get stepId;
  Future<void> registerCallbacks(BookingFlowManager manager);
  Future<void> initializeWithContext(FlowContext context);
  Future<void> cleanup();
}
```

## Data Models

### BookingFlowEntry

```dart
enum BookingFlowEntry {
  dashboard,           // Start from consultation type selection
  quickAction,         // Start with pre-selected consultation type
  doctorProfile,       // Start from specific doctor
  specializationFilter // Start from specialization listing
}
```

### FlowStepDefinition

```dart
class FlowStepDefinition {
  final String stepId;
  final String routeName;
  final FlowStepType type;
  final List<String> requiredContextKeys;
  final List<String> nextPossibleSteps;
  
  const FlowStepDefinition({
    required this.stepId,
    required this.routeName,
    required this.type,
    this.requiredContextKeys = const [],
    this.nextPossibleSteps = const [],
  });
}

enum FlowStepType {
  selection,    // User makes a choice
  information,  // Display information
  action,       // Perform an action (payment, booking)
  confirmation  // Final confirmation screen
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Callback Registration and Execution Consistency
*For any* screen that implements FlowStep, registering a callback with the BookingFlowManager should result in the callback being executed when the screen completes its task
**Validates: Requirements 1.2, 2.1, 2.2**

### Property 2: Flow Context Preservation and Updates
*For any* navigation between screens, the FlowContext should maintain all previously set values while allowing new values to be added, and the updated context should be passed to the next screen
**Validates: Requirements 4.1, 4.2, 4.3, 4.4**

### Property 3: Callback Synchronization
*For any* callback execution, the system should await the result before proceeding to the next step, ensuring proper sequential flow execution
**Validates: Requirements 2.3, 1.3**

### Property 4: Multiple Callback Management
*For any* number of registered callbacks, the system should manage them without conflicts and execute them in the correct order
**Validates: Requirements 2.4**

### Property 5: Memory Cleanup Consistency
*For any* screen disposal or flow completion, all registered callbacks, controllers, and workers should be properly cleaned up to prevent memory leaks
**Validates: Requirements 2.5, 5.4**

### Property 6: Navigation Stack Management
*For any* flow interruption or completion, the system should clean up the navigation stack appropriately and use proper navigation methods to prevent back navigation to cleared screens
**Validates: Requirements 5.3, 5.5**

### Property 7: Error Handling and Recovery
*For any* error that occurs during callback execution, screen loading, navigation, or context corruption, the system should handle it gracefully, maintain context integrity, and provide appropriate recovery mechanisms
**Validates: Requirements 4.5, 6.1, 6.2, 6.3, 6.4, 6.5**

### Property 8: Flow Initialization with Callbacks
*For any* booking flow initiation from the dashboard, the BookingFlowManager should start the consultation flow with proper callback registration and async communication mechanisms
**Validates: Requirements 1.1, 1.5**

### Property 9: Entry Point Flow Adaptation
*For any* different entry point into the booking flow, the system should adapt the flow steps while maintaining the callback structure and context management
**Validates: Requirements 7.5**

## Error Handling

### Error Categories

1. **Navigation Errors**: Failed screen transitions, invalid routes
2. **Callback Errors**: Callback execution failures, timeout errors
3. **Context Errors**: Invalid context data, missing required fields
4. **Network Errors**: API failures during flow execution
5. **Memory Errors**: Resource cleanup failures, memory leaks

### Error Recovery Strategies

1. **Graceful Degradation**: Provide alternative navigation paths when primary flow fails
2. **Context Recovery**: Restore flow context from last known good state
3. **User Feedback**: Clear error messages with actionable recovery options
4. **Automatic Retry**: Retry failed operations with exponential backoff
5. **Safe Exit**: Provide safe navigation back to dashboard when critical errors occur

### Error Handling Implementation

```dart
class FlowErrorHandler {
  Future<FlowResult> handleError(FlowError error, FlowContext context) async {
    switch (error.type) {
      case FlowErrorType.navigation:
        return _handleNavigationError(error, context);
      case FlowErrorType.callback:
        return _handleCallbackError(error, context);
      case FlowErrorType.context:
        return _handleContextError(error, context);
      case FlowErrorType.network:
        return _handleNetworkError(error, context);
      default:
        return _handleGenericError(error, context);
    }
  }
}
```

## Testing Strategy

### Unit Testing Approach

Unit tests will focus on:
- Individual component functionality (BookingFlowManager, FlowContext, etc.)
- Callback registration and execution mechanisms
- Error handling for specific scenarios
- Context data management operations
- Navigation stack manipulation methods

### Property-Based Testing Approach

Property-based tests will verify:
- Universal properties that should hold across all flow executions
- Callback consistency across different screen combinations
- Context preservation through various navigation paths
- Error recovery behavior across different failure scenarios
- Memory cleanup effectiveness across different flow terminations

**Testing Framework**: We will use the `test` package for unit testing and `fake_async` for testing asynchronous callback behavior. For property-based testing, we will use the `test` package with custom generators to create random flow scenarios.

**Test Configuration**: Each property-based test will run a minimum of 100 iterations to ensure comprehensive coverage of the random scenario space.

**Test Tagging**: Each property-based test will be tagged with comments explicitly referencing the correctness property from this design document using the format: '**Feature: centralized-booking-flow-navigation, Property {number}: {property_text}**'

### Integration Testing

Integration tests will cover:
- Complete flow execution from dashboard to pending consultation
- Different entry point scenarios and their flow adaptations
- Error scenarios and recovery mechanisms
- Memory management across complete flows
- Navigation stack behavior during various flow outcomes

### Test Data Management

Test scenarios will include:
- Valid flow sequences with different entry points
- Invalid context data scenarios
- Network failure simulations
- Callback timeout scenarios
- Memory pressure situations
- Concurrent flow execution attempts