# Design Document: In-App Prescription Viewer

## Overview

This design document outlines the implementation of an in-app PDF viewer for prescriptions in the Arogyam mobile application. The feature will replace the current download-and-open-externally workflow with a seamless in-app viewing experience using the flutter_pdfview package. Users will be able to view, navigate, download, and share prescription PDFs without leaving the application.

## Architecture

### High-Level Architecture

```
AppointmentDetailScreen
        ↓
    (User taps "View Prescription")
        ↓
PrescriptionViewerScreen
        ↓
    ┌───────────────┴───────────────┐
    ↓                               ↓
PrescriptionService          PDFViewController
(Download & Cache)           (flutter_pdfview)
    ↓                               ↓
FileDownloader              Native PDF Renderer
```

### Component Interaction Flow

1. **User Interaction**: User taps "View Prescription" button in AppointmentDetailScreen
2. **Navigation**: App navigates to PrescriptionViewerScreen with prescription URL
3. **File Management**: PrescriptionService downloads PDF to temporary cache if not already cached
4. **Rendering**: flutter_pdfview renders the PDF from the local file path
5. **User Actions**: User can navigate pages, download permanently, or share the PDF

## Components and Interfaces

### 1. PrescriptionViewerScreen (UI Component)

**Location**: `lib/appointment/ui/prescription_viewer_screen.dart`

**Responsibilities**:
- Display PDF using flutter_pdfview
- Show loading states during PDF fetch
- Handle error states with retry functionality
- Provide navigation controls (back button)
- Display page indicator (current page / total pages)
- Offer download and share actions via app bar buttons

**State Management**:
- Uses StatefulWidget with local state
- Tracks: loading state, error state, current page, total pages, download progress

**Interface**:
```dart
class PrescriptionViewerScreen extends StatefulWidget {
  final String prescriptionUrl;
  final String prescriptionId;
  final String doctorName;
  
  const PrescriptionViewerScreen({
    required this.prescriptionUrl,
    required this.prescriptionId,
    required this.doctorName,
  });
}
```

### 2. PrescriptionService (Business Logic)

**Location**: `lib/appointment/service/prescription_service.dart`

**Responsibilities**:
- Download prescription PDFs with authentication
- Cache PDFs in temporary storage
- Manage file lifecycle (cleanup)
- Provide file paths for viewing
- Handle permanent downloads to user storage

**Interface**:
```dart
class PrescriptionService {
  /// Downloads prescription to temporary cache for viewing
  /// Returns local file path if successful
  Future<String?> fetchPrescriptionForViewing({
    required String prescriptionUrl,
    required String prescriptionId,
    Function(int received, int total)? onProgress,
  });
  
  /// Downloads prescription permanently to device storage
  Future<bool> downloadPrescriptionPermanently({
    required String prescriptionUrl,
    required String fileName,
    Function(int received, int total)? onProgress,
  });
  
  /// Gets cached prescription file path if exists
  Future<String?> getCachedPrescriptionPath(String prescriptionId);
  
  /// Clears temporary prescription cache
  Future<void> clearCache();
}
```

### 3. Updated AppointmentDetailScreen

**Modifications**:
- Change button text from "Download Prescription" to "View Prescription"
- Navigate to PrescriptionViewerScreen instead of downloading directly
- Remove download progress tracking from this screen (moved to viewer)

### 4. Share Functionality

**Location**: Integrated into PrescriptionViewerScreen

**Implementation**:
- Use `share_plus` package for native sharing
- Share the cached PDF file
- Handle share cancellation gracefully

## Data Models

### PrescriptionViewerState (Internal State)

```dart
enum PrescriptionLoadState {
  loading,
  loaded,
  error,
}

class PrescriptionViewerState {
  final PrescriptionLoadState loadState;
  final String? localFilePath;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool isDownloading;
  final double downloadProgress;
}
```

### Error Types

```dart
enum PrescriptionError {
  networkError,
  authenticationError,
  fileNotFound,
  invalidUrl,
  storageError,
  unknown,
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: PDF Viewer Navigation Consistency

*For any* prescription PDF with N pages, when a user navigates to page P (where 1 ≤ P ≤ N), the page indicator should display "P / N"

**Validates: Requirements 1.4, 2.4**

### Property 2: Download State Exclusivity

*For any* prescription viewer instance, the download button should be disabled if and only if a download is currently in progress

**Validates: Requirements 3.5**

### Property 3: File Caching Idempotence

*For any* prescription ID, calling fetchPrescriptionForViewing multiple times should return the same cached file path without re-downloading if the file exists in cache

**Validates: Requirements 1.1**

### Property 4: Navigation Boundary Enforcement

*For any* prescription PDF, when viewing page 1, scrolling up should not change the current page, and when viewing the last page, scrolling down should not change the current page

**Validates: Requirements 2.2, 2.3**

### Property 5: Error Recovery Consistency

*For any* error state in the PDF viewer, the retry action should re-attempt the same operation that failed (loading, downloading, or sharing)

**Validates: Requirements 1.3, 3.4, 6.1, 6.2**

### Property 6: Back Navigation Cleanup

*For any* prescription viewer session, when the user navigates back to the appointment details screen, the viewer should not leave any active downloads or unclosed resources

**Validates: Requirements 5.3**

### Property 7: Share File Availability

*For any* prescription PDF that is successfully loaded in the viewer, the share button should only be enabled when the local file exists and is readable

**Validates: Requirements 4.1, 4.2**

## Error Handling

### Error Categories and Responses

1. **Network Errors**
   - Display: "Unable to load prescription. Please check your internet connection."
   - Action: Retry button
   - Logging: Log network error details

2. **Authentication Errors**
   - Display: "Session expired. Please log in again."
   - Action: Navigate to login screen
   - Logging: Log auth failure

3. **File Not Found / Invalid URL**
   - Display: "Prescription not available. Please contact support."
   - Action: Go back button
   - Logging: Log missing prescription details

4. **Storage Errors**
   - Display: "Unable to save file. Please check storage permissions."
   - Action: Retry button, Check permissions button
   - Logging: Log storage error and permissions status

5. **PDF Rendering Errors**
   - Display: "Unable to display PDF. The file may be corrupted."
   - Action: Retry button, Download anyway button
   - Logging: Log PDF parsing error

### Error Recovery Strategy

- All errors should be recoverable via retry mechanism
- Network errors: Exponential backoff for retries (1s, 2s, 4s)
- Authentication errors: Clear token and redirect to login
- Storage errors: Request permissions if not granted
- Maintain error context for debugging

## Testing Strategy

### Unit Testing

**Framework**: Flutter's built-in test framework

**Test Coverage**:

1. **PrescriptionService Tests**
   - Test successful PDF download to cache
   - Test cache hit scenario (file already exists)
   - Test download failure handling
   - Test permanent download functionality
   - Test cache cleanup

2. **Error Handling Tests**
   - Test each error type displays correct message
   - Test retry functionality for each error type
   - Test authentication error redirects to login

3. **File Management Tests**
   - Test temporary file creation
   - Test file path generation
   - Test cache directory management

### Property-Based Testing

**Framework**: We will not implement property-based testing for this feature as it primarily involves UI interactions and external dependencies (file system, network, PDF rendering) that are better suited for integration and widget testing.

### Widget Testing

**Test Coverage**:

1. **PrescriptionViewerScreen Widget Tests**
   - Test loading state displays progress indicator
   - Test error state displays error message and retry button
   - Test loaded state displays PDF viewer
   - Test page indicator updates correctly
   - Test download button state changes during download
   - Test share button is visible when PDF is loaded
   - Test back button navigation

2. **AppointmentDetailScreen Updates**
   - Test "View Prescription" button appears when prescription is available
   - Test button navigates to PrescriptionViewerScreen
   - Test unavailable state remains unchanged

### Integration Testing

**Test Scenarios**:

1. **End-to-End Viewing Flow**
   - Navigate from appointment details to PDF viewer
   - Verify PDF loads and displays correctly
   - Navigate through pages
   - Return to appointment details

2. **Download Flow**
   - Open PDF viewer
   - Tap download button
   - Verify file saved to device storage
   - Verify success message displayed

3. **Share Flow**
   - Open PDF viewer
   - Tap share button
   - Verify native share dialog opens
   - Cancel share and verify return to viewer

4. **Error Recovery Flow**
   - Simulate network error
   - Verify error message
   - Tap retry
   - Verify successful load after retry

### Manual Testing Checklist

- [ ] Test on Android devices (various API levels)
- [ ] Test on iOS devices (various iOS versions)
- [ ] Test with single-page prescriptions
- [ ] Test with multi-page prescriptions
- [ ] Test with large PDF files (>5MB)
- [ ] Test with poor network conditions
- [ ] Test offline behavior
- [ ] Test storage permission scenarios
- [ ] Test with expired authentication tokens
- [ ] Test share functionality with various apps (WhatsApp, Email, etc.)
- [ ] Test back button behavior
- [ ] Test app backgrounding during PDF load
- [ ] Test memory usage with multiple PDF views

## Dependencies

### New Dependencies to Add

1. **flutter_pdfview** (^1.3.2)
   - Purpose: Render PDF documents natively
   - Platform support: Android, iOS
   - License: MIT

2. **share_plus** (^10.1.4)
   - Purpose: Native sharing functionality
   - Platform support: Android, iOS, Web, Windows, macOS, Linux
   - License: BSD-3-Clause

### Existing Dependencies to Use

- **dio**: HTTP client for downloading PDFs
- **path_provider**: Access to temporary and permanent storage directories
- **permission_handler**: Request storage permissions
- **get**: Navigation between screens

## UI/UX Specifications

### PrescriptionViewerScreen Layout

**App Bar**:
- Title: "Prescription - Dr. [Doctor Name]"
- Leading: Back button (arrow_back_ios)
- Actions: Download button (download_rounded), Share button (share_rounded)
- Background: White
- Elevation: 0.5

**Body**:
- Full-screen PDF viewer
- Background: Grey (#F5F5F5)
- PDF container: White background with subtle shadow

**Page Indicator** (Overlay at bottom):
- Position: Bottom center, 16dp from bottom
- Style: Semi-transparent dark background, white text
- Format: "Page X of Y"
- Font: 14sp, medium weight

**Loading State**:
- Center-aligned circular progress indicator
- Text below: "Loading prescription..."
- Background: White

**Error State**:
- Center-aligned error icon (error_outline_rounded, 80dp)
- Error message text (16sp, centered)
- Retry button (elevated, primary color)
- Padding: 40dp all sides

### Button States

**View Prescription Button** (AppointmentDetailScreen):
- Enabled: Blue background (#2196F3), white text
- Loading: Blue background with opacity, loading indicator
- Icon: visibility_rounded (instead of download_rounded)

**Download Button** (PrescriptionViewerScreen App Bar):
- Enabled: Icon button, grey color
- Downloading: Icon button with progress indicator overlay
- Disabled: Icon button, light grey color

**Share Button** (PrescriptionViewerScreen App Bar):
- Enabled: Icon button, grey color
- Disabled: Icon button, light grey color (when PDF not loaded)

## Performance Considerations

1. **Caching Strategy**
   - Cache PDFs in temporary directory for quick re-access
   - Implement cache size limit (e.g., 50MB total)
   - Clear old cache files after 7 days
   - Clear cache on app logout

2. **Memory Management**
   - flutter_pdfview handles memory efficiently by rendering pages on-demand
   - Dispose PDF controller properly in widget lifecycle
   - Avoid loading entire PDF into memory

3. **Network Optimization**
   - Show download progress for large files
   - Support resume on network interruption (if possible with Dio)
   - Compress PDFs on server-side if not already compressed

4. **Rendering Performance**
   - Use native PDF rendering (provided by flutter_pdfview)
   - Lazy load pages as user scrolls
   - Pre-render adjacent pages for smooth scrolling

## Security Considerations

1. **Authentication**
   - Include auth token in all PDF download requests
   - Handle token expiration gracefully
   - Refresh token if needed before download

2. **File Storage**
   - Store temporary PDFs in app-private directory
   - Clear sensitive files on logout
   - Don't expose file paths in logs

3. **Data Privacy**
   - Don't cache PDFs indefinitely
   - Implement secure file deletion
   - Respect user's data deletion requests

## Platform-Specific Considerations

### Android

- **Minimum SDK**: API 21 (Android 5.0)
- **Permissions**: Storage permission for permanent downloads (handled by existing FileDownloader)
- **PDF Rendering**: Uses native Android PDF renderer

### iOS

- **Minimum Version**: iOS 11.0
- **Permissions**: No special permissions needed for app directory storage
- **PDF Rendering**: Uses native iOS PDF renderer (PDFKit)

## Migration Strategy

### Phase 1: Add PDF Viewer (Non-Breaking)
- Add new PrescriptionViewerScreen
- Add PrescriptionService
- Keep existing download functionality as fallback

### Phase 2: Update UI
- Change button text to "View Prescription"
- Update navigation to use new viewer
- Keep download option in viewer

### Phase 3: Testing & Rollout
- Test thoroughly on both platforms
- Monitor crash reports and user feedback
- Rollback to old flow if critical issues found

## Future Enhancements

1. **Zoom Functionality**: Allow pinch-to-zoom on PDF pages
2. **Search**: Search text within prescription PDFs
3. **Annotations**: Allow users to highlight or add notes
4. **Offline Mode**: Pre-download prescriptions for offline viewing
5. **Print**: Add print functionality for prescriptions
6. **Multiple Prescriptions**: View all prescriptions for an appointment in a gallery
