# Implementation Plan

- [x] 1. Create UserProfile entity and ProfileService


  - Create `lib/profile/entities/user_profile.dart` with UserProfile model
  - Implement `fromJson` and `toUpdatePayload` methods
  - Create `lib/profile/service/profile_service.dart`
  - Implement `updateProfile` method with PUT request to `/patient/profile`
  - Add error handling for network and API errors
  - _Requirements: 2.1, 2.2, 2.5_

- [x] 2. Update FamilyMemberService with delete functionality


  - Add `deleteFamilyMember(String familyMemberId)` method to `lib/family_member/service/FamilyMember_service.dart`
  - Implement DELETE request to `/patient/family-members/{family_member_id}`
  - Add error handling for delete operation
  - _Requirements: 1.5, 1.6_

- [x] 3. Create Edit Profile Screen UI




  - Create `lib/profile/ui/edit_profile_screen.dart`
  - Implement gradient AppBar matching app design (teal to green)
  - Create form with TextFormFields for name, email, date of birth, gender
  - Add date picker for date of birth field
  - Add gender dropdown/radio buttons
  - Implement form validation (required fields, email format, date format)
  - Add Save and Cancel buttons
  - _Requirements: 2.1, 2.2, 2.3, 3.3, 3.4_

- [x] 4. Implement Edit Profile Screen logic


  - Load current user data and pre-fill form
  - Implement real-time form validation
  - Handle save button tap - call ProfileService
  - Show loading indicator during API call
  - Handle success - show success message and navigate back
  - Handle errors - display error messages
  - Implement cancel button - discard changes and navigate back
  - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_

- [x] 5. Create Family Members List Screen UI





  - Create `lib/profile/ui/family_members_list_screen.dart`
  - Implement gradient AppBar with "Family Members" title
  - Create family member card widget with avatar, name, relationship, age, gender, delete button
  - Implement pull-to-refresh functionality
  - Add empty state with illustration and message
  - Add loading shimmer/skeleton for loading state
  - Style cards with shadows, rounded corners, proper spacing
  - _Requirements: 1.2, 1.3, 3.2, 3.7_

- [x] 6. Implement Family Members List Screen logic





  - Load family members using existing FamilyMemberService
  - Display family members in list
  - Implement pull-to-refresh to reload data
  - Handle empty state when no family members
  - Handle loading state with shimmer
  - Handle error state with error message
  - _Requirements: 1.2, 1.3, 1.7, 1.8_

- [x] 7. Implement delete family member functionality





  - Add delete icon button to family member cards
  - Create delete confirmation dialog
  - Handle delete button tap - show confirmation
  - On confirm - call FamilyMemberService.deleteFamilyMember
  - Show loading indicator during delete
  - On success - remove member from list and show success message
  - On error - show error message
  - _Requirements: 1.4, 1.5, 1.6, 3.4_

- [x] 8. Update Profile Screen menu



  - Add "Edit Profile" menu item to `lib/profile/profile_screen.dart`
  - Add "Family Members" menu item
  - Implement navigation to Edit Profile Screen
  - Implement navigation to Family Members List Screen
  - Add appropriate icons (edit_rounded, family_restroom_rounded)
  - Add appropriate colors matching other menu items
  - _Requirements: 4.1, 4.2_

- [x] 9. Add routes and navigation


  - Add `editProfile` and `familyMembersList` routes to `lib/_shared/routing/app_routes.dart`
  - Create GetPage entries for both screens
  - Implement navigation methods in `lib/_shared/routing/app_navigation.dart`
  - Ensure slide transitions work (already configured in main.dart)
  - _Requirements: 4.2, 4.3_

- [x] 10. Implement data refresh after updates


  - Refresh profile data in profile screen after edit
  - Refresh family members list after delete
  - Update current user data in local storage after profile update
  - Ensure UI reflects latest data
  - _Requirements: 4.3_

- [x] 11. Add loading states and error handling


  - Implement loading indicators for all async operations
  - Add error snackbars with appropriate messages
  - Handle network errors gracefully
  - Add retry options for failed operations
  - Disable buttons during loading
  - _Requirements: 3.5, 3.6, 3.8, 4.5_

- [x] 12. Polish UI and animations


  - Ensure consistent gradient backgrounds across all screens
  - Add smooth transitions between screens
  - Implement card animations (fade in, slide)
  - Add ripple effects to interactive elements
  - Ensure proper spacing and alignment
  - Test on different screen sizes
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 13. Handle guest mode


  - Check if user is in guest mode
  - Hide/disable Edit Profile and Family Members options for guests
  - Show appropriate message if guest tries to access
  - _Requirements: 4.4_

- [x] 14. Final testing and validation



  - Test complete edit profile flow
  - Test complete delete family member flow
  - Test form validation (all fields)
  - Test error scenarios (network errors, API errors)
  - Test empty states
  - Test loading states
  - Verify UI matches design specifications
  - Test navigation flow
  - _Requirements: All_
