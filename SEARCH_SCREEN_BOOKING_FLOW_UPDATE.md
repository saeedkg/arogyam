# SearchScreen Booking Flow Update

## Overview
Updated the SearchScreen and Dashboard Quick Actions to use the new simplified BookingFlowManager instead of the old ConsultationFlowManager.

## Changes Made

### 1. SearchScreen (`lib/care_discovery/ui/search_screen.dart`)
**Before:**
```dart
import '../../_shared/consultation/consultation_flow_manager.dart';

// In specialization item onTap
ConsultationFlowManager.instance.navigateFromCareDiscovery(
  speciality: specialization.name,
  preSelectedType: widget.preSelectedAppointmentType,
);
```

**After:**
```dart
import '../../_shared/booking_flow/booking_flow_manager.dart';

// In specialization item onTap
BookingFlowManager.instance.startBookingFlow(
  entry: BookingFlowEntry.specializationFilter,
  selectedSpecialization: specialization.name,
  appointmentType: widget.preSelectedAppointmentType,
);
```

### 2. Dashboard Quick Actions (`lib/landing/ui/components/dashboard_quick_action_view.dart`)
**Before:**
```dart
case QuickActionType.videoConsult:
  ConsultationFlowManager.instance.startScheduledConsultation(
    appointmentType: AppointmentType.video,
  );
  break;
case QuickActionType.hospitalAppointment:
  ConsultationFlowManager.instance.startScheduledConsultation(
    appointmentType: AppointmentType.clinic,
  );
  break;
```

**After:**
```dart
case QuickActionType.videoConsult:
  BookingFlowManager.instance.startBookingFlow(
    entry: BookingFlowEntry.quickAction,
    appointmentType: AppointmentType.video,
  );
  break;
case QuickActionType.hospitalAppointment:
  BookingFlowManager.instance.startBookingFlow(
    entry: BookingFlowEntry.quickAction,
    appointmentType: AppointmentType.clinic,
  );
  break;
```

## Benefits

1. **Consistency**: All booking flows now use the same simplified BookingFlowManager
2. **Simplified Parameters**: Direct parameters instead of complex FlowData objects
3. **Clear Entry Points**: Using appropriate BookingFlowEntry types for different scenarios
4. **Maintainability**: Single source of truth for booking navigation logic

## Entry Points Used

- **SearchScreen Specializations**: `BookingFlowEntry.specializationFilter` - Starts from specialization with optional appointment type
- **Dashboard Quick Actions**: `BookingFlowEntry.quickAction` - Starts with pre-selected appointment type

## Backward Compatibility

- `ConsultationFlowManager` is still available for instant consultations and pending consultation navigation
- Deprecated methods are marked with `@deprecated` but still functional
- No breaking changes to existing functionality

## Testing

- ✅ SearchScreen specialization clicks now use new booking flow
- ✅ Dashboard quick actions (Video Consult, Hospital Appointment) use new booking flow
- ✅ Instant consultation still uses old flow (as intended)
- ✅ No compilation errors
- ✅ All imports updated correctly

The SearchScreen and Dashboard Quick Actions are now fully integrated with the simplified booking flow system!