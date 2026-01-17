# Appointment Status - Expired & In Progress Implementation

## Overview
Added two new appointment statuses: "expired" (not joined case) and "in_progress" (able to rejoin call) with proper handling across all appointment-related screens.

## Changes Made

### 1. AppointmentStatus Enum (`lib/appointment/entities/appointment_status.dart`)

#### Added New Statuses
- **`expired`**: For appointments that have expired and cannot be joined
- **`inProgress`**: For appointments currently in progress that can be rejoined

#### Updated fromString Method
```dart
case 'expired':
  return AppointmentStatus.expired;
case 'in_progress':
case 'inprogress':
case 'in-progress':
  return AppointmentStatus.inProgress;
```

#### Updated displayName Method
```dart
case AppointmentStatus.expired:
  return 'Expired';
case AppointmentStatus.inProgress:
  return 'In Progress';
```

### 2. Appointment Card (`lib/appointment/components/appontment_card.dart`)

#### Status Colors
- **Expired**: Gray 600 (muted, inactive)
- **In Progress**: Success Green (active, ongoing)

#### Action Button Logic
- **Expired**: 
  - Button text: "Expired"
  - Color: Gray 600 (disabled appearance)
- **In Progress**: 
  - Button text: "Rejoin"
  - Color: Success Green (prominent, actionable)

### 3. Appointments Screen (`lib/appointment/appointments_screen.dart`)

#### Navigation Logic
```dart
if (appointment.status == AppointmentStatus.confirmed ||
    appointment.status == AppointmentStatus.pending ||
    appointment.status == AppointmentStatus.inProgress) {
  // Go to pending consultation screen for active appointments
  Get.to(() => PendingConsultationScreen(appointmentId: appointment.id.toString()));
} else if (appointment.status == AppointmentStatus.expired) {
  // Show expired message
  Get.snackbar('Appointment Expired', 'This appointment has expired and cannot be joined.');
  AppNavigation.toAppointmentDetail(appointment.id.toString());
} else {
  // Go to appointment detail screen
  AppNavigation.toAppointmentDetail(appointment.id.toString());
}
```

#### Behavior by Status
- **Confirmed/Pending/In Progress**: → PendingConsultationScreen (can join/rejoin)
- **Expired**: → Shows snackbar message + AppointmentDetailScreen
- **Completed/Cancelled**: → AppointmentDetailScreen

### 4. Pending Consultation Screen (`lib/consultation_pending/ui/pending_consultation_screen.dart`)

#### Dynamic Button Text
- **Confirmed/Pending**: "Join Consultation"
- **In Progress**: "Rejoin Consultation"

#### Dynamic Dialog Content
- **Join Dialog Title**: 
  - Normal: "Join Consultation"
  - In Progress: "Rejoin Consultation"
  
- **Dialog Content**:
  - Normal: "Make sure you have a stable internet connection."
  - In Progress: "The consultation is already in progress. You can rejoin the ongoing session."
  
- **Dialog Button**:
  - Normal: "Join"
  - In Progress: "Rejoin"

#### Helper Methods Added
```dart
String _getJoinButtonText(AppointmentDetails cons)
String _getJoinDialogTitle(AppointmentDetails cons)
String _getJoinDialogContent(AppointmentDetails cons)
String _getJoinDialogButtonText(AppointmentDetails cons)
```

### 5. Appointment Detail Screen (`lib/appointment/appointment_detail_screen.dart`)

#### Status Colors
- **Expired**: Gray 600
- **In Progress**: Success Green
- **Cancelled**: Error Red (also added)

#### Status Icons
- **Expired**: `Icons.schedule_rounded` (clock icon)
- **In Progress**: `Icons.videocam_rounded` (video camera icon)
- **Cancelled**: `Icons.cancel_rounded` (cancel icon)

## Status Behavior Summary

| Status | Card Button | Card Color | Navigation | Join Screen | Detail Screen |
|--------|-------------|------------|------------|-------------|---------------|
| **pending** | "View" | Orange | → PendingConsultation | "Join Consultation" | Orange badge |
| **confirmed** | "Join" | Blue | → PendingConsultation | "Join Consultation" | Green badge |
| **in_progress** | "Rejoin" | Success Green | → PendingConsultation | "Rejoin Consultation" | Green badge |
| **expired** | "Expired" | Gray | → Snackbar + Detail | N/A | Gray badge |
| **completed** | "Details" | Green | → Detail | N/A | Blue badge |
| **cancelled** | "View" | Gray | → Detail | N/A | Red badge |

## User Experience Flow

### Expired Appointments
1. **Card**: Shows "Expired" button (gray, disabled appearance)
2. **Tap**: Shows snackbar "Appointment has expired and cannot be joined"
3. **Navigation**: Goes to AppointmentDetailScreen for viewing details
4. **Detail Screen**: Shows gray "Expired" badge with clock icon

### In Progress Appointments
1. **Card**: Shows "Rejoin" button (success green, prominent)
2. **Tap**: Goes to PendingConsultationScreen
3. **Join Screen**: Shows "Rejoin Consultation" button
4. **Dialog**: "The consultation is already in progress. You can rejoin the ongoing session."
5. **Action**: "Rejoin" button launches video call
6. **Detail Screen**: Shows green "In Progress" badge with video camera icon

## API Integration

### Expected API Status Values
The system handles these status string variations:
- `"expired"` → AppointmentStatus.expired
- `"in_progress"`, `"inprogress"`, `"in-progress"` → AppointmentStatus.inProgress

### Backward Compatibility
- All existing statuses continue to work
- Unknown statuses default to `AppointmentStatus.unknown`
- Graceful handling of case variations

## Visual Design

### Status Badge Colors
- **Expired**: Muted gray (indicates inactive/unavailable)
- **In Progress**: Bright success green (indicates active/available)

### Button Styling
- **Expired**: Gray background (disabled appearance, non-actionable)
- **In Progress**: Success green background (prominent, actionable)

### Icons
- **Expired**: Clock icon (time-related, indicates time has passed)
- **In Progress**: Video camera icon (indicates active video consultation)

## Error Handling

### Expired Appointments
- Clear messaging: "This appointment has expired and cannot be joined"
- User can still view appointment details
- No attempt to join video call

### In Progress Appointments
- Allows rejoining ongoing consultations
- Same video call credentials used
- Seamless rejoin experience

## Files Modified
- ✅ `lib/appointment/entities/appointment_status.dart`
- ✅ `lib/appointment/components/appontment_card.dart`
- ✅ `lib/appointment/appointments_screen.dart`
- ✅ `lib/consultation_pending/ui/pending_consultation_screen.dart`
- ✅ `lib/appointment/appointment_detail_screen.dart`

## Status
✅ New statuses added to enum
✅ Status parsing updated (multiple variations)
✅ Display names added
✅ Card styling updated
✅ Navigation logic updated
✅ Pending consultation screen updated
✅ Appointment detail screen updated
✅ No compilation errors
✅ Ready for testing

## Testing Recommendations

### Expired Status Testing
1. **Card Display**: Verify "Expired" button shows in gray
2. **Navigation**: Tap should show snackbar + go to detail screen
3. **Detail Screen**: Should show gray "Expired" badge with clock icon
4. **No Join**: Should not allow joining video call

### In Progress Status Testing
1. **Card Display**: Verify "Rejoin" button shows in success green
2. **Navigation**: Tap should go to pending consultation screen
3. **Join Screen**: Should show "Rejoin Consultation" button
4. **Dialog**: Should show in-progress specific message
5. **Video Call**: Should allow rejoining with same credentials

### API Integration Testing
1. **Status Parsing**: Test various API status formats
2. **Case Sensitivity**: Test lowercase/uppercase variations
3. **Hyphen Variations**: Test "in_progress", "in-progress", "inprogress"
4. **Unknown Status**: Test graceful handling of unknown statuses

### UI/UX Testing
1. **Visual Consistency**: Check colors match design system
2. **Icon Appropriateness**: Verify icons make sense for each status
3. **Button States**: Ensure disabled/enabled states are clear
4. **Message Clarity**: Verify all user messages are clear and helpful

## Future Enhancements

1. **Auto-refresh**: Automatically refresh status for in-progress appointments
2. **Notifications**: Push notifications for status changes
3. **Time Tracking**: Show remaining time for in-progress consultations
4. **Reconnection**: Automatic reconnection for dropped in-progress calls