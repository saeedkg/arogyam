# Doctor Booking - Centralized Callback Navigation Implementation

## Overview
Implemented a centralized callback-based navigation system where each screen in the booking process can register cleanup callbacks, and a central place (ConsultationFlowManager) decides to clear all screens and navigate to dashboard when payment is successful.

## Architecture Pattern

### Centralized Decision Making
Instead of each screen handling its own navigation after payment success, we now have:

1. **Registration Phase**: Each screen registers a callback for cleanup
2. **Centralized Handling**: ConsultationFlowManager makes navigation decisions
3. **Cleanup Execution**: Registered callbacks handle screen-specific cleanup
4. **Navigation**: Central manager clears all screens and navigates to target

## Implementation Details

### 1. ConsultationFlowManager (Central Controller)
**File:** `lib/_shared/consultation/consultation_flow_manager.dart`

#### New Features Added:
```dart
// Callback storage for payment success
VoidCallback? _onPaymentSuccessCallback;

/// Register a callback to be executed when payment is successful
void registerPaymentSuccessCallback(VoidCallback callback) {
  _onPaymentSuccessCallback = callback;
}

/// Clear the registered callback
void clearPaymentSuccessCallback() {
  _onPaymentSuccessCallback = null;
}

/// Handle payment success with centralized navigation logic
void handlePaymentSuccess(String appointmentId) {
  // Execute registered callback first (for cleanup)
  _onPaymentSuccessCallback?.call();
  
  // Clear the callback
  clearPaymentSuccessCallback();
  
  // Centralized decision: Clear all screens and go to pending consultation
  Get.offAll(() => PendingConsultationScreen(appointmentId: appointmentId));
}

/// Navigate to dashboard, clearing all previous screens
void navigateToDashboard() {
  Get.offAllNamed('/landing');
}
```

### 2. DoctorBookingScreen (Callback Registration)
**File:** `lib/booking/ui/doctor_booking_screen.dart`

#### Changes Made:
```dart
@override
void initState() {
  super.initState();
  // ... existing code ...
  
  // Register callback for payment success - centralized navigation handling
  ConsultationFlowManager.instance.registerPaymentSuccessCallback(() {
    // Cleanup logic for this screen
    try {
      // Clean up controllers and workers
      _appointmentIdWorker.dispose();
      _bookingErrorWorker.dispose();
      bookingController.appointmentId.value = null; // Reset
    } catch (e) {
      print('Error in payment success cleanup: $e');
    }
  });
  
  // Listen to appointment ID changes (payment success)
  _appointmentIdWorker = ever(bookingController.appointmentId, (String? appointmentId) {
    if (appointmentId != null && appointmentId.isNotEmpty && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          try {
            // Use centralized payment success handling
            ConsultationFlowManager.instance.handlePaymentSuccess(appointmentId);
          } catch (e) {
            print('Error in appointment success navigation: $e');
          }
        }
      });
    }
  });
}

@override
void dispose() {
  try {
    // Clear the payment success callback when disposing
    ConsultationFlowManager.instance.clearPaymentSuccessCallback();
    
    // ... existing cleanup code ...
  } catch (e) {
    print('Error in dispose: $e');
  }
  super.dispose();
}
```

### 3. PendingConsultationScreen (Back Navigation)
**File:** `lib/consultation_pending/ui/pending_consultation_screen.dart`

#### Changes Made:
```dart
// Added import
import '../../_shared/consultation/consultation_flow_manager.dart';

// Updated build method with PopScope
@override
Widget build(BuildContext context) {
  return PopScope(
    canPop: false, // Prevent default back behavior
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) {
        // Use centralized navigation to dashboard
        ConsultationFlowManager.instance.navigateToDashboard();
      }
    },
    child: Scaffold(
      // ... existing scaffold content ...
      appBar: AppBar(
        // ... existing appbar content ...
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () {
            // Use centralized navigation to dashboard
            ConsultationFlowManager.instance.navigateToDashboard();
          },
        ),
      ),
      // ... rest of scaffold ...
    ),
  );
}
```

## Flow Diagram

### Before (Decentralized):
```
DoctorBookingScreen
    ↓ (payment success)
    ├─ Get.back()
    └─ ConsultationFlowManager.navigateToPendingConsultation()
        ↓
        PendingConsultationScreen
            ↓ (back button)
            Get.back() → Returns to DoctorBookingScreen
```

### After (Centralized Callback):
```
DoctorBookingScreen
    ├─ registerPaymentSuccessCallback() → Registers cleanup logic
    ↓ (payment success)
    ConsultationFlowManager.handlePaymentSuccess()
        ├─ Execute registered callback (cleanup)
        ├─ Clear callback
        └─ Get.offAll() → PendingConsultationScreen (clears stack)
            ↓ (back button)
            ConsultationFlowManager.navigateToDashboard()
                └─ Get.offAllNamed('/landing') → Dashboard
```

## Key Benefits

### 1. **Centralized Control**
- Single place to make navigation decisions
- Consistent behavior across all booking flows
- Easy to modify navigation logic globally

### 2. **Clean Separation of Concerns**
- Screens handle their own cleanup logic
- Central manager handles navigation decisions
- Clear responsibility boundaries

### 3. **Extensible Architecture**
- Easy to add more screens to the booking flow
- Each screen can register its own cleanup callback
- Central manager can evolve navigation logic independently

### 4. **Memory Management**
- Proper cleanup of controllers and workers
- Prevents memory leaks from orphaned screens
- Clear navigation stack management

### 5. **User Experience**
- No orphaned screens in navigation stack
- Direct path back to main functionality
- Consistent back button behavior

## Usage Pattern for New Screens

To add a new screen to the booking flow:

```dart
class NewBookingScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    
    // Register cleanup callback
    ConsultationFlowManager.instance.registerPaymentSuccessCallback(() {
      // Screen-specific cleanup logic
      // Dispose controllers, reset state, etc.
    });
    
    // Listen for payment success
    someController.paymentSuccess.listen((appointmentId) {
      if (appointmentId != null) {
        // Use centralized handling
        ConsultationFlowManager.instance.handlePaymentSuccess(appointmentId);
      }
    });
  }
  
  @override
  void dispose() {
    // Clear callback on dispose
    ConsultationFlowManager.instance.clearPaymentSuccessCallback();
    super.dispose();
  }
}
```

## Error Handling

### Callback Safety
- Null-safe callback execution with `?.call()`
- Try-catch blocks around cleanup operations
- Graceful handling of disposal errors

### Navigation Safety
- Checks for mounted state before navigation
- PostFrameCallback for UI operations
- Fallback error logging

## Testing Considerations

### Unit Tests
- Test callback registration and execution
- Test centralized navigation logic
- Test cleanup operations

### Integration Tests
- Test complete payment success flow
- Test back button navigation
- Test memory cleanup

### Edge Cases
- Multiple rapid payment success events
- Screen disposal during callback execution
- Navigation during app state changes

## Future Enhancements

### Possible Extensions
1. **Multiple Callback Types**: Support different callback types (success, failure, cancel)
2. **Priority Callbacks**: Execute callbacks in specific order
3. **Conditional Navigation**: Different navigation based on booking type
4. **Analytics Integration**: Track navigation patterns centrally
5. **State Persistence**: Save/restore navigation state

### Migration Path
- Current implementation is backward compatible
- Old `handlePaymentSuccessOld()` method marked as deprecated
- Gradual migration of other booking flows

## Files Modified

1. **lib/_shared/consultation/consultation_flow_manager.dart**
   - Added callback registration system
   - Added centralized payment success handling
   - Added dashboard navigation method

2. **lib/booking/ui/doctor_booking_screen.dart**
   - Registered payment success callback
   - Updated payment success handling to use centralized approach
   - Added callback cleanup in dispose

3. **lib/consultation_pending/ui/pending_consultation_screen.dart**
   - Added ConsultationFlowManager import
   - Updated back button to use centralized navigation
   - Added PopScope for system back button handling

## Conclusion

This centralized callback approach provides a clean, maintainable, and extensible solution for managing navigation in complex booking flows. Each screen maintains responsibility for its own cleanup while delegating navigation decisions to a central authority, resulting in better separation of concerns and more predictable user experience.