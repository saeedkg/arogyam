# Doctor Detail Button Priority Implementation

## Summary
Implemented dynamic button priority in DoctorDetailInfoScreen based on the consultation type context (video vs physical appointment).

## Changes Made

### 1. DoctorDetailInfoScreen (`lib/find_doctor/ui/doctor_detail_info_screen.dart`)

#### Added Parameter
- Added `isFromPhysicalAppointment` boolean parameter (default: false)
- This tracks whether the user came from physical appointment filter

#### Button Logic Updates
When both consultation types are available (video + physical):

**From Physical Appointment (`isFromPhysicalAppointment = true`):**
1. **Primary Button (Green Gradient)**: "Call Clinic for Physical Appointment"
   - Phone icon
   - Triggers phone call action
2. **Secondary Button (Blue Outlined)**: "Book Video Consultation - ₹{price}"
   - Video icon
   - Navigates to booking screen

**From Video Consultation (`isFromPhysicalAppointment = false`):**
1. **Primary Button (Green Gradient)**: "Book Video Consultation - ₹{price}"
   - Video icon
   - Navigates to booking screen
2. **Secondary Button (Green Outlined)**: "Call Clinic for Physical Appointment"
   - Phone icon
   - Triggers phone call action

**Single Consultation Type:**
- Shows only the relevant button with green gradient (primary style)

### 2. DoctorCard (`lib/find_doctor/ui/components/doctor_card.dart`)

#### Navigation Update
- Updated navigation to pass `isFromPhysicalAppointment` parameter
- Value determined by checking if `appointmentType == AppointmentFilterType.physical`

```dart
Get.to(() => DoctorDetailInfoScreen(
  doctorId: doctor.id,
  isFromPhysicalAppointment: appointmentType == AppointmentFilterType.physical,
));
```

## User Experience

### Scenario 1: User Selects "Physical Appointment" Filter
1. User filters doctors by "Physical Appointment"
2. Clicks on a doctor card
3. Doctor detail screen opens with:
   - **Primary**: "Call Clinic" button (green, prominent)
   - **Secondary**: "Book Video Consultation" button (blue outline)
4. User's intent (physical visit) is prioritized

### Scenario 2: User Selects "Video Consult" Filter
1. User filters doctors by "Video Consult"
2. Clicks on a doctor card
3. Doctor detail screen opens with:
   - **Primary**: "Book Video Consultation" button (green, prominent)
   - **Secondary**: "Call Clinic" button (green outline)
4. User's intent (video consultation) is prioritized

### Scenario 3: Direct Navigation (No Filter Context)
1. User navigates from other screens without filter context
2. Doctor detail screen opens with:
   - **Primary**: "Book Video Consultation" button (default)
   - **Secondary**: "Call Clinic" button

## Design Decisions

1. **Visual Hierarchy**: Primary button uses gradient, secondary uses outline
2. **Color Coding**: 
   - Video consultation: Blue accent for secondary
   - Physical appointment: Green for both (primary gradient, secondary outline)
3. **Button Order**: Primary button always appears first (top position)
4. **Context Awareness**: Button priority adapts to user's journey

## Technical Implementation

- Uses conditional rendering with Dart's spread operator (`...`)
- Maintains clean separation of concerns
- No breaking changes to existing code
- Backward compatible (default behavior when parameter not provided)

## Next Steps

1. Add actual clinic phone number field to doctor data model
2. Update `_makePhoneCall` to use real clinic phone from API
3. Test phone call functionality on physical devices
4. Consider adding analytics to track which button users prefer

## Files Modified

1. `lib/find_doctor/ui/doctor_detail_info_screen.dart`
2. `lib/find_doctor/ui/components/doctor_card.dart`
