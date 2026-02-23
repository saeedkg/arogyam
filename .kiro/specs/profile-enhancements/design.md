# Design Document

## Overview

This design document outlines the technical approach for implementing profile enhancements including family member management and profile editing capabilities. The implementation will leverage existing family member infrastructure and add new screens with modern, professional UI following Material Design 3 principles.

## Architecture

### Component Structure

```
lib/
├── profile/
│   ├── profile_screen.dart (existing - update menu)
│   ├── ui/
│   │   ├── edit_profile_screen.dart (new)
│   │   └── family_members_list_screen.dart (new)
│   ├── service/
│   │   └── profile_service.dart (new)
│   └── entities/
│       └── user_profile.dart (new)
├── family_member/ (existing)
│   ├── service/
│   │   └── FamilyMember_service.dart (update - add delete method)
│   └── ui/
│       └── family_member_screen.dart (existing - reference for design)
```

### Data Flow

1. **Profile Menu** → Navigate to Edit Profile or Family Members
2. **Edit Profile Screen** → ProfileService → API → Update local user data
3. **Family Members List** → FamilyMemberService → API → Update list

## Components and Interfaces

### 1. Profile Service

**Purpose:** Handle profile update operations

```dart
class ProfileService {
  final NetworkAdapter _networkAdapter;
  
  Future<UserProfile> updateProfile({
    required String name,
    required String email,
    required String dateOfBirth,
    required String gender,
  });
}
```

**API Integration:**
- Endpoint: `PUT /patient/profile`
- Request Body:
```json
{
  "name": "string",
  "email": "string",
  "date_of_birth": "YYYY-MM-DD",
  "gender": "male|female|other"
}
```

### 2. Family Member Service (Update)

**Purpose:** Add delete functionality to existing service

```dart
class FamilyMemberService {
  // Existing methods...
  Future<List<FamilyMember>> getFamilyMembers();
  Future<FamilyMember> addFamilyMember(FamilyMember member);
  
  // New method
  Future<void> deleteFamilyMember(String familyMemberId);
}
```

**API Integration:**
- Endpoint: `DELETE /patient/family-members/{family_member_id}`
- Response: Success message

### 3. Edit Profile Screen

**UI Components:**
- Gradient AppBar (matching app design)
- Form with text fields:
  - Name (TextFormField)
  - Email (TextFormField with email validation)
  - Date of Birth (DatePicker)
  - Gender (Dropdown/Radio buttons)
- Save button (primary color)
- Cancel button (text button)
- Loading indicator during save
- Validation error messages

**State Management:**
- Form validation state
- Loading state
- Error state
- Success state

**User Flow:**
1. Load current user data
2. Pre-fill form fields
3. User edits fields
4. Real-time validation
5. Submit → Show loading
6. Success → Navigate back with refresh
7. Error → Show error message

### 4. Family Members List Screen

**UI Components:**
- Gradient AppBar with title "Family Members"
- Pull-to-refresh
- List of family member cards:
  - Avatar/Icon
  - Name (large, bold)
  - Relationship badge
  - Age/DOB
  - Gender icon
  - Delete icon button (red)
- Empty state with illustration
- Add button (FAB or in empty state)
- Loading shimmer
- Delete confirmation dialog

**State Management:**
- Family members list
- Loading state
- Empty state
- Delete in progress state

**User Flow:**
1. Load family members
2. Display in cards
3. User taps delete → Show confirmation
4. Confirm → API call → Remove from list
5. Success message
6. Refresh list

## Data Models

### UserProfile Entity

```dart
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String dateOfBirth; // YYYY-MM-DD
  final String gender;
  final String? phone;
  final String? profileImage;
  
  factory UserProfile.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toUpdatePayload();
}
```

### FamilyMember Entity (Existing)

```dart
class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final String dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String? profileImage;
  final bool? isPrimary;
}
```

## UI/UX Design Specifications

### Color Scheme
- **Primary Gradient:** `AppColors.teal` → `AppColors.teal.withOpacity(0.9)` → `AppColors.primaryGreen`
- **Card Background:** White with shadow
- **Delete Button:** Red (`Colors.red`)
- **Save Button:** `AppColors.primaryGreen`
- **Text:** Dark gray for body, white for headers

### Typography
- **Screen Title:** 24px, Bold, White
- **Card Title:** 18px, Bold, Dark
- **Body Text:** 14px, Regular, Gray
- **Labels:** 12px, Medium, Gray

### Spacing
- **Screen Padding:** 16px
- **Card Padding:** 16px
- **Card Margin:** 12px vertical
- **Element Spacing:** 8-16px

### Card Design
```
┌─────────────────────────────────────┐
│  👤  John Doe                    🗑️ │
│      Son • 25 years • Male          │
│      Blood: O+                      │
└─────────────────────────────────────┘
```

### Form Design
- Material Design 3 outlined text fields
- Floating labels
- Helper text below fields
- Error text in red
- Date picker with calendar icon
- Gender dropdown with icons

## Error Handling

### Network Errors
- Show snackbar with retry option
- "No internet connection" message
- Offline indicator

### Validation Errors
- Inline field errors
- Red border on invalid fields
- Clear error messages

### API Errors
- Parse server error messages
- Show user-friendly messages
- Log technical details

### Delete Confirmation
```
┌─────────────────────────────────┐
│  Delete Family Member?          │
│                                 │
│  Are you sure you want to       │
│  remove [Name] from your        │
│  family members?                │
│                                 │
│  [Cancel]  [Delete]             │
└─────────────────────────────────┘
```

## Testing Strategy

### Unit Tests
- ProfileService API calls
- FamilyMemberService delete method
- Form validation logic
- Data model serialization

### Widget Tests
- Edit Profile form rendering
- Family Members list rendering
- Delete confirmation dialog
- Empty state display

### Integration Tests
- Complete edit profile flow
- Complete delete family member flow
- Navigation between screens
- Error handling scenarios

## Navigation Integration

### Profile Screen Updates

Add menu items:
```dart
_buildActionTile(context, 'Edit Profile', Icons.edit_rounded, AppColors.primaryBlue),
_buildDivider(),
_buildActionTile(context, 'Family Members', Icons.family_restroom_rounded, AppColors.teal),
```

### Route Configuration

Add to `app_routes.dart`:
```dart
static const String editProfile = '/edit_profile';
static const String familyMembersList = '/family_members_list';

GetPage(
  name: editProfile,
  page: () => const EditProfileScreen(),
),
GetPage(
  name: familyMembersList,
  page: () => const FamilyMembersListScreen(),
),
```

## Performance Considerations

1. **Lazy Loading:** Load family members only when screen is opened
2. **Caching:** Cache user profile data locally
3. **Optimistic Updates:** Update UI before API confirmation
4. **Debouncing:** Debounce form validation
5. **Image Optimization:** Compress and cache profile images

## Accessibility

1. **Semantic Labels:** All interactive elements have labels
2. **Touch Targets:** Minimum 48x48 dp
3. **Contrast Ratios:** WCAG AA compliant
4. **Screen Reader:** Proper announcements for actions
5. **Focus Management:** Logical tab order

## Security Considerations

1. **Input Validation:** Client and server-side
2. **Email Verification:** Verify email changes
3. **Authorization:** Ensure user can only edit own profile
4. **Data Sanitization:** Sanitize all inputs
5. **Secure Storage:** Store sensitive data securely

## Implementation Notes

1. **Reuse Existing Components:** Leverage existing family member UI patterns
2. **Consistent Design:** Match dashboard and appointments screen gradients
3. **Error Messages:** Use existing error handling patterns
4. **Loading States:** Use existing shimmer/skeleton loaders
5. **Animations:** Use app's default slide transitions (300ms)
