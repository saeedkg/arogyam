# Design Document

## Overview

The CareDiscoveryScreen redesign transforms the healthcare discovery experience into a comprehensive, doctor-focused interface that guides users through multiple pathways to find the right medical specialist. The design follows a vertical scrolling layout with distinct sections, each serving a specific purpose in helping users discover doctors.

The screen will be organized into the following sections from top to bottom:
1. Enhanced Search Bar
2. Popular Specialties (2 rows, 8 items with "View All")
3. Common Symptoms (horizontal scroll)
4. Browse by Health Concern (grid of body systems/health areas)
5. All Specialties (full specialization list from API)

This approach ensures users can find doctors whether they know the specialty name, have specific symptoms, or want to browse by body part/health concern.

## Architecture

### Component Structure

```
CareDiscoveryScreen (StatefulWidget)
├── AppBar (with back button and title)
└── SingleChildScrollView
    ├── EnhancedSearchBar (custom widget)
    ├── PopularSpecialtiesSection (custom widget)
    ├── CommonSymptomsSection (custom widget)
    ├── HealthConcernsSection (custom widget)
    └── AllSpecialtiesSection (reuses existing SpecializationGrid)
```

### State Management

The screen will use GetX for state management with a dedicated controller:

```dart
CareDiscoveryController extends GetxController {
  // Existing
  - RxBool isLoading
  - RxList<Specialization> specializations (from API)
  
  // New
  - List<PopularSpecialty> popularSpecialties (hardcoded)
  - List<CommonSymptom> commonSymptoms (hardcoded)
  - List<HealthConcern> healthConcerns (hardcoded)
  
  // Methods
  - loadSpecializations() // existing
  - getPopularSpecialties() // returns hardcoded list
  - getCommonSymptoms() // returns hardcoded list
  - getHealthConcerns() // returns hardcoded list
}
```

### Service Layer

Create a new service class to manage hardcoded data with future API integration in mind:

```dart
CareDiscoveryDataService {
  // Returns hardcoded popular specialties
  // Can be replaced with API call in future
  Future<List<PopularSpecialty>> fetchPopularSpecialties()
  
  // Returns hardcoded common symptoms
  // Can be replaced with API call in future
  Future<List<CommonSymptom>> fetchCommonSymptoms()
  
  // Returns hardcoded health concerns
  // Can be replaced with API call in future
  Future<List<HealthConcern>> fetchHealthConcerns()
}
```

## Components and Interfaces

### 1. Enhanced Search Bar Component

**Purpose:** Provide a visually appealing, tappable search interface that navigates to the full search screen.

**Design Specifications:**
- Container with gradient background (white to light green tint)
- Border with primary green color (1.5px, 10% opacity)
- Box shadow with green tint for depth
- Rounded corners (20px radius)
- Padding: 20px all around
- Height: Auto (based on content)

**Layout:**
```
[Search Icon Container] [Text Content] [Arrow Icon]
     (48x48)              (Flexible)      (32x32)
```

**Visual Elements:**
- Search Icon: Gradient background (primary green), white icon, 24px size
- Title: "Search Healthcare" - 18px, bold (700), black87
- Subtitle: "Doctors, specialties & symptoms" - 14px, medium (500), grey600
- Arrow: Light green background (10% opacity), primary green icon, 16px

**Interaction:**
- OnTap: Navigate to SearchScreen with preSelectedAppointmentType

### 2. Popular Specialties Section

**Purpose:** Display the 8 most commonly accessed medical specialties in a fixed 2-row grid.

**Design Specifications:**
- Section Header: "Popular Specialties" - 20px, bold (800), black87
- "View All" button: Rounded container, light green background, primary green text
- Grid: 4 columns × 2 rows (fixed 8 items)
- Spacing: 16px horizontal, 8px vertical
- Card aspect ratio: 0.85

**Specialty Card Design:**
- Circle container: 56px diameter
- Solid color background (from predefined color palette)
- White icon: 28px size
- Shadow: Color-matched with 30% opacity, 8px blur
- Label: 11px, medium (500), black87, centered, max 1 line

**Color Palette for Specialties:**
1. Dentistry - Peach (#F5AD7E)
2. Cardiology - Rose Dust (#DC9497)
3. Pulmonology - Sage Green (#93C19E)
4. General Medicine - Blue Bell (#ACA1CD)
5. Neurology - Medium Sky Blue (#89CCDB)
6. Gastroenterology - Teal (#4D9B91)
7. Orthopedics - Blush (#DEB6B5)
8. Dermatology - Deep Purple (#352261)

**Interaction:**
- OnTap specialty: Navigate to consultation type selection or doctor listing
- OnTap "View All": Scroll to the "All Specialties" section at the bottom of the screen

**Data Structure:**
```dart
class PopularSpecialty {
  final String name;
  final String iconPath;
  final Color backgroundColor;
  final String? svgIcon; // Optional SVG string from API
}
```

### 3. Common Symptoms Section

**Purpose:** Help users find care based on symptoms they're experiencing, even without knowing the specialty.

**Design Specifications:**
- Section Header: "Common Symptoms" - 20px, bold (800), black87
- Horizontal scrollable list (ListView.builder with horizontal axis)
- Card size: 140px width × 160px height
- Spacing: 12px between cards
- Padding: 20px horizontal for screen edges

**Symptom Card Design:**
- White background with subtle shadow
- Rounded corners: 16px
- Padding: 16px
- Border: 1px, grey200

**Card Layout:**
```
┌─────────────────┐
│   [Icon 48x48]  │
│                 │
│  Symptom Name   │
│   (14px bold)   │
│                 │
│  Description    │
│  (12px regular) │
│   (2-3 lines)   │
└─────────────────┘
```

**Icon Design:**
- Circle container: 48px diameter
- Light colored background (symptom-specific)
- Colored icon: 24px size
- Shadow: Subtle, 4px blur

**Hardcoded Symptoms:**
1. Fever - Icon: thermometer, Color: warningOrange
2. Cough - Icon: lungs, Color: mediumSkyBlue
3. Headache - Icon: head, Color: deepPurple
4. Stomach Pain - Icon: stomach, Color: peach
5. Back Pain - Icon: back, Color: roseDust
6. Skin Issues - Icon: skin, Color: blush
7. Chest Pain - Icon: heart, Color: errorRed
8. Fatigue - Icon: energy, Color: sageGreen

**Interaction:**
- OnTap: Navigate to SearchScreen with symptom pre-filled or to relevant specialty

**Data Structure:**
```dart
class CommonSymptom {
  final String name;
  final String description;
  final String iconPath;
  final Color backgroundColor;
  final Color iconColor;
  final List<String> relatedSpecialties; // For future navigation
}
```

### 4. Browse by Health Concern Section

**Purpose:** Help users find doctors based on body systems or health areas, making it easier to navigate even without medical knowledge.

**Design Specifications:**
- Section Header: "Browse by Health Concern" - 20px, bold (800), black87
- Grid: 3 columns
- Spacing: 12px horizontal and vertical
- Card aspect ratio: 1.1 (slightly taller than wide)

**Health Concern Card Design:**
- White background with subtle shadow
- Rounded corners: 16px
- Padding: 16px
- Border: 1px, grey200

**Card Layout:**
```
┌──────────────┐
│              │
│ [Icon 40x40] │
│              │
│ Concern Name │
│  (13px bold) │
│              │
│   Subtitle   │
│ (11px light) │
└──────────────┘
```

**Icon Design:**
- Circle container: 40px diameter
- Gradient background (concern-specific colors)
- White icon: 20px size
- Shadow: Subtle, 4px blur

**Hardcoded Health Concerns:**
1. Heart & Circulation
   - Icon: heart
   - Subtitle: "Cardiology"
   - Color: roseDust
   - Related: Cardiology

2. Digestive System
   - Icon: stomach
   - Subtitle: "Gastroenterology"
   - Color: peach
   - Related: Gastroenterology

3. Respiratory System
   - Icon: lungs
   - Subtitle: "Pulmonology"
   - Color: mediumSkyBlue
   - Related: Pulmonology

4. Bones & Joints
   - Icon: bone
   - Subtitle: "Orthopedics"
   - Color: sageGreen
   - Related: Orthopedics

5. Skin & Hair
   - Icon: skin
   - Subtitle: "Dermatology"
   - Color: blush
   - Related: Dermatology

6. Mental Health
   - Icon: brain
   - Subtitle: "Psychiatry"
   - Color: deepPurple
   - Related: Psychiatry

7. Women's Health
   - Icon: female
   - Subtitle: "Gynecology"
   - Color: roseDust
   - Related: Gynecology

8. Children's Health
   - Icon: child
   - Subtitle: "Pediatrics"
   - Color: blueBell
   - Related: Pediatrics

9. Eye Care
   - Icon: eye
   - Subtitle: "Ophthalmology"
   - Color: mediumSkyBlue
   - Related: Ophthalmology

10. Dental Care
    - Icon: tooth
    - Subtitle: "Dentistry"
    - Color: peach
    - Related: Dentistry

11. Ear Nose Throat
    - Icon: ear
    - Subtitle: "ENT"
    - Color: teal
    - Related: ENT

12. General Health
    - Icon: stethoscope
    - Subtitle: "General Medicine"
    - Color: sageGreen
    - Related: General Medicine

**Interaction:**
- OnTap: Navigate to the related specialty's doctor listing
- Visual feedback: Scale animation (0.95) on press

**Data Structure:**
```dart
class HealthConcern {
  final String name;
  final String subtitle;
  final String iconPath;
  final Color primaryColor;
  final String relatedSpecialty; // Maps to specialty name
}
```

### 5. All Specialties Section

**Purpose:** Display the complete list of medical specializations fetched from the API.

**Design Specifications:**
- Section Header: "All Specialties" - 20px, bold (800), black87
- Reuse existing SpecializationGrid component
- Grid: 4 columns
- Spacing: 16px horizontal, 8px vertical
- Show all items (no "See All" toggle needed here)
- Add scroll key for programmatic scrolling from "View All" button

**Modifications to Existing Component:**
- Remove the "See All" button (always show all)
- Keep existing card design and interactions
- Maintain existing color mapping logic
- Add GlobalKey for scroll target

## Data Models

### New Entity Classes

```dart
// lib/care_discovery/entities/popular_specialty.dart
class PopularSpecialty {
  final String id;
  final String name;
  final String iconPath;
  final Color backgroundColor;
  final String? svgIcon;
  
  PopularSpecialty({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.backgroundColor,
    this.svgIcon,
  });
}

// lib/care_discovery/entities/common_symptom.dart
class CommonSymptom {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final Color backgroundColor;
  final Color iconColor;
  final List<String> relatedSpecialties;
  
  CommonSymptom({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.backgroundColor,
    required this.iconColor,
    required this.relatedSpecialties,
  });
}

// lib/care_discovery/entities/health_concern.dart
class HealthConcern {
  final String id;
  final String name;
  final String subtitle;
  final String iconPath;
  final Color primaryColor;
  final String relatedSpecialty;
  
  HealthConcern({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.iconPath,
    required this.primaryColor,
    required this.relatedSpecialty,
  });
}
```

## Error Handling

### API Failures
- If specializations API fails: Show error message with retry button in All Categories section
- Other sections (hardcoded) should still display normally
- Error UI: Red border container with error icon, message, and "Retry" button

### Empty States
- If API returns empty specializations: Show "No specializations available" message
- Hardcoded sections will always have data, so no empty states needed

### Loading States
- Initial load: Show shimmer/skeleton loaders for each section
- Shimmer design: Grey gradient animation, matching section layouts
- API sections load asynchronously without blocking hardcoded sections

## Testing Strategy

### Unit Tests
1. Controller Tests
   - Test getPopularSpecialties returns correct hardcoded data
   - Test getCommonSymptoms returns correct hardcoded data
   - Test getHealthConcerns returns correct hardcoded data
   - Test loadSpecializations API integration
   - Test error handling for API failures

2. Service Tests
   - Test CareDiscoveryDataService methods return expected data structures
   - Test data consistency and completeness

3. Entity Tests
   - Test entity constructors and properties
   - Test data serialization if needed in future

### Widget Tests
1. CareDiscoveryScreen Tests
   - Test screen renders all sections correctly
   - Test loading state displays properly
   - Test error state displays with retry button
   - Test navigation to SearchScreen on search bar tap
   - Test scroll to All Specialties on "View All" tap

2. Component Tests
   - Test EnhancedSearchBar renders and navigates correctly
   - Test PopularSpecialtiesSection displays 8 items in 2 rows
   - Test CommonSymptomsSection horizontal scroll behavior
   - Test HealthConcernsSection grid layout (3 columns)
   - Test AllSpecialtiesSection displays API data

3. Interaction Tests
   - Test specialty card tap navigation
   - Test symptom card tap navigation
   - Test health concern card tap navigation
   - Test "View All Specialties" button scrolls to bottom section

### Integration Tests
1. Full Flow Tests
   - Test complete user journey from CareDiscoveryScreen to doctor booking
   - Test navigation stack preservation
   - Test back button behavior
   - Test with and without preSelectedAppointmentType

2. Performance Tests
   - Test scroll performance with all sections loaded
   - Test initial render time
   - Test memory usage with images and icons

## Visual Design System

### Typography Scale
- Section Headers: 20px, FontWeight.w800, black87
- Card Titles: 16px, FontWeight.w700, black87
- Card Subtitles: 14px, FontWeight.w600, black87
- Descriptions: 13px, FontWeight.w500, grey600
- Labels: 11-12px, FontWeight.w500, grey700

### Spacing System
- Screen padding: 20px horizontal
- Section spacing: 24px vertical
- Card spacing: 12-16px
- Internal padding: 16-20px

### Color Usage
- Primary actions: primaryGreen (#22C58B)
- Backgrounds: backgroundLight (#F7FAFF), white
- Text: black87, grey600, grey700
- Borders: grey200, primaryGreen with opacity
- Shadows: black with 8-12% opacity

### Animation and Transitions
- Card tap: Scale to 0.95, duration 150ms
- Navigation: Default Flutter page transition
- Loading: Shimmer animation, 1.5s duration
- Scroll: Native smooth scrolling

## Accessibility Considerations

### Semantic Labels
- All interactive elements have semantic labels
- Section headers use proper heading semantics
- Icons have descriptive labels for screen readers

### Touch Targets
- Minimum 44x44 points for all interactive elements
- Adequate spacing between tappable items
- Clear visual feedback on interaction

### Color Contrast
- All text meets WCAG AA standards (4.5:1 for normal text)
- Icons and important UI elements meet 3:1 contrast ratio
- Color is not the only means of conveying information

### Dynamic Text
- Support for system text size settings
- Layout adapts to larger text sizes
- No text truncation at default sizes

## Implementation Notes

### Phase 1: Core Structure
1. Create new entity classes (PopularSpecialty, CommonSymptom, HealthConcern)
2. Create CareDiscoveryDataService with hardcoded data
3. Update CareDiscoveryController with new methods
4. Create new UI components (EnhancedSearchBar, PopularSpecialtiesSection, CommonSymptomsSection, HealthConcernsSection)

### Phase 2: Integration
5. Update CareDiscoveryScreen layout with all sections
6. Implement navigation flows
7. Add loading and error states
8. Implement scroll-to functionality for "View All"
9. Test all interactions

### Phase 3: Polish
10. Add animations and transitions
11. Implement accessibility features
12. Optimize performance
13. Add comprehensive tests

### Future Enhancements
- Replace hardcoded data with API calls when endpoints are available
- Add personalization based on user history
- Implement search within symptoms and health concerns
- Add favorites/bookmarks for specialties
- Integrate health tips and articles
- Add "Recently Viewed" section
