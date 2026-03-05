# Implementation Plan

- [x] 1. Create entity classes for new data models


  - Create PopularSpecialty, CommonSymptom, and HealthConcern entity classes with proper constructors and properties
  - _Requirements: 7.1, 7.3, 7.4, 7.5_






- [ ] 2. Create CareDiscoveryDataService with hardcoded data
- [x] 2.1 Implement service class structure

  - Create CareDiscoveryDataService class with methods for fetching popular specialties, common symptoms, and health concerns
  - Implement proper async/await patterns for future API integration
  - _Requirements: 7.1, 7.6_


- [ ] 2.2 Add hardcoded popular specialties data
  - Implement fetchPopularSpecialties() method with 8 hardcoded specialties (Dentistry, Cardiology, Pulmonology, General Medicine, Neurology, Gastroenterology, Orthopedics, Dermatology)
  - Include icon paths, colors, and SVG support
  - _Requirements: 1.2, 7.3_


- [x] 2.3 Add hardcoded common symptoms data





  - Implement fetchCommonSymptoms() method with 8 symptoms (Fever, Cough, Headache, Stomach Pain, Back Pain, Skin Issues, Chest Pain, Fatigue)
  - Include descriptions, icons, colors, and related specialties
  - _Requirements: 2.5, 7.4_


- [ ] 2.4 Add hardcoded health concerns data
  - Implement fetchHealthConcerns() method with 12 health concerns (Heart & Circulation, Digestive System, Respiratory System, Bones & Joints, Skin & Hair, Mental Health, Women's Health, Children's Health, Eye Care, Dental Care, ENT, General Health)


  - Include subtitles, icons, colors, and related specialty mappings
  - _Requirements: 3.3, 7.5_

- [ ] 3. Update CareDiscoveryController
- [x] 3.1 Add new observable properties




  - Add RxList properties for popularSpecialties, commonSymptoms, and healthConcerns
  - Initialize CareDiscoveryDataService instance
  - _Requirements: 7.1_


- [ ] 3.2 Implement data loading methods
  - Create loadPopularSpecialties(), loadCommonSymptoms(), and loadHealthConcerns() methods
  - Implement proper error handling for each method
  - Call all loading methods in onInit()
  - _Requirements: 7.7, 9.1, 9.2_


- [ ] 4. Create EnhancedSearchBar component
  - Build widget with gradient background, border, and shadow effects
  - Implement layout with search icon container, text content, and arrow icon
  - Add onTap navigation to SearchScreen with preSelectedAppointmentType



  - Use proper spacing (20px padding) and rounded corners (20px radius)
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 6.3_

- [x] 5. Create PopularSpecialtiesSection component

- [ ] 5.1 Build section header and "View All" button
  - Create section header with "Popular Specialties" title (20px, bold)
  - Implement "View All" button with light green background and primary green text
  - Add onTap handler for "View All" to scroll to All Specialties section
  - _Requirements: 1.1, 1.3, 4.7, 6.2_


- [ ] 5.2 Implement specialty grid layout
  - Create GridView with 4 columns × 2 rows (fixed 8 items)
  - Set spacing (16px horizontal, 8px vertical) and aspect ratio (0.85)
  - Build specialty cards with circle containers (56px), icons (28px), and labels
  - Apply color palette and shadows to cards
  - _Requirements: 1.2, 1.5, 6.3_

- [ ] 5.3 Add specialty card interactions
  - Implement onTap navigation to consultation type selection or doctor listing
  - Add visual feedback (scale or opacity change) on tap
  - Pass preSelectedAppointmentType if available
  - _Requirements: 1.6, 6.7, 8.1_

- [ ] 6. Create CommonSymptomsSection component
- [ ] 6.1 Build section header and horizontal scroll layout
  - Create section header with "Common Symptoms" title (20px, bold)
  - Implement horizontal ListView.builder with proper spacing (12px between cards)
  - Set card dimensions (140px width × 160px height)
  - _Requirements: 2.1, 2.2, 6.2_

- [ ] 6.2 Implement symptom card design
  - Build card with white background, rounded corners (16px), and shadow
  - Create layout with icon container (48px circle), symptom name (14px bold), and description (12px, 2-3 lines)
  - Apply symptom-specific colors to icon backgrounds
  - _Requirements: 2.3, 6.3_

- [ ] 6.3 Add symptom card interactions
  - Implement onTap navigation to relevant doctors or specialties
  - Add visual feedback on tap
  - Handle related specialties navigation
  - _Requirements: 2.4, 6.7, 8.1_

- [-] 7. Create HealthConcernsSection component

- [x] 7.1 Build section header and grid layout


  - Create section header with "Browse by Health Concern" title (20px, bold)
  - Implement GridView with 3 columns
  - Set spacing (12px horizontal and vertical) and aspect ratio (1.1)
  - _Requirements: 3.1, 3.2, 6.2_

- [x] 7.2 Implement health concern card design

  - Build card with white background, rounded corners (16px), border, and shadow
  - Create layout with icon container (40px circle with gradient), concern name (13px bold), and subtitle (11px)
  - Apply concern-specific gradient colors
  - _Requirements: 3.4, 6.3_

- [x] 7.3 Add health concern card interactions


  - Implement onTap navigation to related specialty's doctor listing
  - Add scale animation (0.95) on press
  - Map health concern to correct specialty name
  - _Requirements: 3.5, 6.7, 8.1_

- [x] 8. Update AllSpecialtiesSection (modify existing SpecializationGrid)


  - Add GlobalKey for scroll targeting from "View All" button
  - Remove "See All" toggle (always show all items)
  - Update section header to "All Specialties"
  - Maintain existing card design and color mapping
  - _Requirements: 4.1, 4.2, 4.4, 4.5, 4.6_

- [-] 9. Integrate all sections into CareDiscoveryScreen

- [x] 9.1 Update screen layout structure


  - Wrap body in SingleChildScrollView with ScrollController
  - Add all sections in correct order: EnhancedSearchBar, PopularSpecialtiesSection, CommonSymptomsSection, HealthConcernsSection, AllSpecialtiesSection
  - Apply proper spacing between sections (24px vertical)
  - _Requirements: 6.1, 9.3_

- [x] 9.2 Implement scroll-to functionality


  - Create ScrollController and GlobalKey for All Specialties section
  - Implement scrollToAllSpecialties() method in controller or screen
  - Connect "View All" button tap to scroll animation
  - _Requirements: 1.4, 4.7_

- [x] 9.3 Add loading and error states


  - Implement shimmer/skeleton loaders for each section
  - Create error UI with retry button for API failures
  - Ensure hardcoded sections display even if API fails
  - _Requirements: 4.3, 9.1, 9.2_

- [x] 10. Implement navigation flows

  - Ensure all specialty/symptom/concern taps navigate correctly
  - Preserve navigation stack appropriately
  - Handle preSelectedAppointmentType throughout flows
  - Test back button behavior
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 11. Add visual polish and animations

  - Implement card tap animations (scale to 0.95, 150ms duration)
  - Add shimmer animation for loading states (1.5s duration)
  - Ensure smooth scroll animations
  - Apply consistent shadows, borders, and rounded corners
  - _Requirements: 6.3, 6.7, 9.3_

- [x] 12. Implement accessibility features


  - Add semantic labels to all interactive elements
  - Ensure minimum 44x44 touch targets
  - Verify color contrast ratios meet WCAG AA standards
  - Test with screen reader
  - Support dynamic text sizing
  - _Requirements: 10.1, 10.2, 10.3, 10.4_

- [ ]* 13. Write unit tests
  - Test CareDiscoveryController methods (getPopularSpecialties, getCommonSymptoms, getHealthConcerns, loadSpecializations)
  - Test CareDiscoveryDataService returns correct data structures
  - Test entity constructors and properties
  - Test error handling for API failures
  - _Requirements: 7.7_

- [ ]* 14. Write widget tests
  - Test CareDiscoveryScreen renders all sections correctly
  - Test each component (EnhancedSearchBar, PopularSpecialtiesSection, CommonSymptomsSection, HealthConcernsSection, AllSpecialtiesSection)
  - Test loading and error states
  - Test navigation interactions
  - Test scroll-to functionality
  - _Requirements: 6.1, 6.7_

- [ ]* 15. Write integration tests
  - Test complete user journey from CareDiscoveryScreen to doctor booking
  - Test navigation stack preservation
  - Test with and without preSelectedAppointmentType
  - Test scroll performance and memory usage
  - _Requirements: 8.1, 8.2, 8.3, 9.3_
