# Implementation Plan

- [x] 1. Add required dependencies to pubspec.yaml
  - Add flutter_pdfview package (^1.3.2)
  - Add share_plus package (^10.1.4)
  - Run flutter pub get to install dependencies
  - _Requirements: 1.1, 4.1_

- [x] 2. Create PrescriptionService for file management
  - Create `lib/appointment/service/prescription_service.dart`
  - Implement `fetchPrescriptionForViewing()` method to download PDF to temporary cache
  - Implement `getCachedPrescriptionPath()` method to check for existing cached files
  - Implement `downloadPrescriptionPermanently()` method for permanent downloads
  - Implement `clearCache()` method for cleanup
  - Use existing FileDownloader utility for authenticated downloads
  - Use path_provider to get temporary and permanent storage directories
  - _Requirements: 1.1, 3.1, 5.3_

- [ ]* 2.1 Write unit tests for PrescriptionService
  - Test successful PDF download to cache
  - Test cache hit scenario (file already exists)
  - Test download failure handling
  - Test permanent download functionality
  - Test cache cleanup
  - _Requirements: 1.1, 3.1, 5.3_

- [x] 3. Create PrescriptionViewerScreen UI
  - Create `lib/appointment/ui/prescription_viewer_screen.dart`
  - Implement StatefulWidget with required parameters (prescriptionUrl, prescriptionId, doctorName)
  - Create app bar with title, back button, download button, and share button
  - Implement loading state UI with circular progress indicator
  - Implement error state UI with error message and retry button
  - Create page indicator overlay showing "Page X of Y"
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 4.1, 5.1_

- [x] 4. Integrate flutter_pdfview into PrescriptionViewerScreen
  - Import flutter_pdfview package
  - Create PDFViewController instance
  - Implement PDF rendering using PDFView widget
  - Configure vertical scrolling for page navigation
  - Implement onPageChanged callback to update page indicator
  - Handle PDF loading completion
  - Handle PDF rendering errors
  - _Requirements: 1.1, 1.5, 2.1, 2.2, 2.3, 2.4_

- [x] 5. Implement PDF loading logic in PrescriptionViewerScreen
  - Call PrescriptionService.fetchPrescriptionForViewing() in initState
  - Show loading state while fetching PDF
  - Update UI to loaded state when file path is received
  - Update UI to error state on failure
  - Implement retry functionality that re-calls fetch method
  - Handle different error types (network, auth, file not found, storage)
  - _Requirements: 1.2, 1.3, 6.1, 6.2, 6.3, 6.4_

- [x] 6. Implement download functionality in PrescriptionViewerScreen
  - Add download button to app bar
  - Implement onPressed handler that calls PrescriptionService.downloadPrescriptionPermanently()
  - Track download progress state
  - Show progress indicator on button during download
  - Disable button while download is in progress
  - Show success SnackBar with file location on completion
  - Show error SnackBar on failure with retry option
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 7. Implement share functionality in PrescriptionViewerScreen
  - Add share button to app bar
  - Import share_plus package
  - Implement onPressed handler that shares the cached PDF file
  - Handle share cancellation gracefully
  - Show error message if sharing fails
  - Ensure share button is only enabled when PDF is loaded
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 8. Update AppointmentDetailScreen to use new viewer
  - Change button text from "Download Prescription" to "View Prescription"
  - Change button icon from download_rounded to visibility_rounded
  - Update onPressed handler to navigate to PrescriptionViewerScreen
  - Pass prescriptionUrl, prescriptionId (bookingId), and doctorName as parameters
  - Remove local download progress tracking state
  - Remove _downloadPrescription() method
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [ ]* 9. Write widget tests for PrescriptionViewerScreen
  - Test loading state displays progress indicator
  - Test error state displays error message and retry button
  - Test loaded state displays PDF viewer
  - Test page indicator updates correctly
  - Test download button state changes during download
  - Test share button visibility when PDF is loaded
  - Test back button navigation
  - _Requirements: 1.2, 1.3, 1.4, 3.5, 4.1, 5.1_

- [ ]* 10. Write widget tests for updated AppointmentDetailScreen
  - Test "View Prescription" button appears when prescription is available
  - Test button navigates to PrescriptionViewerScreen with correct parameters
  - Test unavailable state remains unchanged
  - _Requirements: 7.1, 7.2, 7.3_

- [x] 11. Implement resource cleanup and lifecycle management
  - Dispose PDFViewController in PrescriptionViewerScreen dispose() method
  - Cancel any ongoing downloads when screen is disposed
  - Implement WillPopScope to handle back button properly
  - Ensure no memory leaks from PDF rendering
  - _Requirements: 5.2, 5.3_

- [x] 12. Add error handling for edge cases
  - Handle case when prescription URL is null or empty
  - Handle case when network is unavailable
  - Handle case when authentication token expires during download
  - Handle case when storage permissions are denied
  - Handle case when PDF file is corrupted
  - Display appropriate error messages for each case
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 13. Test on physical devices and fix platform-specific issues
  - Test on Android device (API 21+)
  - Test on iOS device (iOS 11+)
  - Verify PDF rendering works correctly on both platforms
  - Verify download to device storage works on both platforms
  - Verify share functionality works on both platforms
  - Fix any platform-specific bugs discovered
  - _Requirements: All requirements_

- [ ] 14. Final checkpoint - Ensure all functionality works end-to-end
  - Ensure all tests pass, ask the user if questions arise
  - Verify complete flow: appointment details → view prescription → navigate pages → download → share → back
  - Test with single-page and multi-page PDFs
  - Test error scenarios and recovery
  - Verify no crashes or memory leaks
  - _Requirements: All requirements_
