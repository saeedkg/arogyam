# Implementation Plan: Invoice Viewer

## Overview

This implementation plan breaks down the Invoice Viewer feature into discrete, manageable tasks. The approach follows the existing PrescriptionViewerScreen pattern to ensure consistency and leverage proven architecture. Tasks are organized to build incrementally, with testing integrated throughout.

## Tasks

- [x] 1. Create InvoiceService with core functionality
  - Create `lib/appointment/service/invoice_service.dart`
  - Implement singleton pattern
  - Implement `fetchInvoiceForViewing()` method with caching
  - Implement `downloadInvoicePermanently()` method
  - Implement `getCachedInvoicePath()` helper method
  - Implement `clearCache()` method
  - Use Dio for HTTP requests with authentication
  - API endpoint: `{base_url}/patient/appointments/{appointment_id}/invoice`
  - Cache directory: `{temp}/invoice_cache/`
  - File naming: `invoice_{appointment_id}.pdf`
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ]* 1.1 Write unit tests for InvoiceService
  - Test successful invoice fetch
  - Test cache hit scenario (no redundant network calls)
  - Test download progress callbacks
  - Test permanent download functionality
  - Test cache clearing
  - Test error handling for network failures
  - Test error handling for invalid appointment IDs
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ]* 1.2 Write property test for invoice fetch idempotence
  - **Property 1: Invoice Fetch Idempotence**
  - **Validates: Requirements 6.2**

- [ ]* 1.3 Write property test for cache consistency
  - **Property 6: Cache Consistency**
  - **Validates: Requirements 6.2**

- [x] 2. Create InvoiceViewerScreen UI structure
  - Create `lib/appointment/ui/invoice_viewer_screen.dart`
  - Implement StatefulWidget with required parameters (appointmentId, doctorName)
  - Set up state variables (isLoading, hasError, errorMessage, localFilePath, etc.)
  - Create AppBar with title "Invoice - Dr. {doctor_name}"
  - Add back button, download button, and share button to AppBar
  - Implement basic Scaffold structure
  - _Requirements: 1.1, 7.1, 7.4_

- [x] 3. Implement loading state UI
  - Create `_buildLoadingState()` method
  - Display CircularProgressIndicator with AppColors.primaryGreen
  - Show "Loading invoice..." text below spinner
  - Center content vertically and horizontally
  - _Requirements: 1.3_

- [x] 4. Implement error state UI
  - Create `_buildErrorState()` method
  - Display error icon (Icons.error_outline_rounded, 80px, grey400)
  - Show error title "Unable to Load Invoice"
  - Display specific error message from state
  - Add "Try Again" button with retry functionality
  - Style button with AppColors.primaryGreen, 48px height, 12px border radius
  - _Requirements: 1.5, 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 5. Implement error message categorization
  - Create `_getErrorMessage()` method
  - Categorize network errors: "Unable to load invoice. Please check your internet connection."
  - Categorize 404 errors: "Invoice not available. Please contact support."
  - Categorize auth errors: "Session expired. Please log in again."
  - Categorize permission errors: "Unable to save file. Please check storage permissions."
  - Provide generic fallback: "Unable to load invoice. Please try again."
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [ ]* 5.1 Write property test for error message specificity
  - **Property 4: Error Message Specificity**
  - **Validates: Requirements 5.1, 5.2, 5.3, 5.4**

- [x] 6. Implement PDF viewer state
  - Create `_buildPdfViewer()` method
  - Integrate flutter_pdfview PDFView widget
  - Configure PDF settings (enableSwipe, swipeHorizontal: false, autoSpacing, pageFling, pageSnap)
  - Set background color to AppColors.grey100
  - Handle onRender callback to get total pages
  - Handle onPageChanged callback to track current page
  - Handle onError callback for PDF display errors
  - Store PDFViewController reference
  - _Requirements: 1.4, 4.1, 4.3, 4.4_

- [x] 7. Implement page indicator overlay
  - Create page indicator widget positioned at bottom center
  - Display "Page X of Y" text
  - Style with AppColors.primaryGreen background, white text
  - Add rounded corners (24px border radius) and shadow
  - Position 24px from bottom
  - Only show when totalPages > 0
  - _Requirements: 4.2_

- [x] 8. Implement invoice loading functionality
  - Create `_loadInvoice()` method in initState
  - Call InvoiceService.fetchInvoiceForViewing()
  - Pass appointmentId from widget parameters
  - Handle loading state (set isLoading = true)
  - Handle success (set localFilePath, isLoading = false)
  - Handle errors (set hasError = true, errorMessage)
  - Implement retry functionality via `_retry()` method
  - _Requirements: 1.2, 1.3, 1.4, 1.5_

- [ ]* 8.1 Write property test for file path validity
  - **Property 3: File Path Validity**
  - **Validates: Requirements 1.4, 2.2**

- [x] 9. Implement download functionality
  - Create `_downloadInvoice()` method
  - Call InvoiceService.downloadInvoicePermanently()
  - Set isDownloading state during operation
  - Track download progress via callback
  - Update downloadProgress state variable
  - Show success SnackBar on completion: "Invoice downloaded successfully"
  - Show error SnackBar on failure with retry action
  - Disable download button during download (grey400 color)
  - File name format: `invoice_{appointment_id}.pdf`
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ]* 9.1 Write property test for download progress monotonicity
  - **Property 2: Download Progress Monotonicity**
  - **Validates: Requirements 2.3**

- [x] 10. Implement share functionality
  - Create `_shareInvoice()` method
  - Use share_plus package to share PDF file
  - Create XFile from localFilePath
  - Set subject: "Invoice - Dr. {doctor_name}"
  - Set text: "Sharing invoice from Dr. {doctor_name}"
  - Handle errors with SnackBar message
  - Disable share button when localFilePath is null (grey400 color)
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 11. Implement navigation blocking during download
  - Use PopScope widget with canPop property
  - Set canPop = !isDownloading
  - Implement onPopInvokedWithResult callback
  - Show SnackBar when navigation blocked: "Please wait for download to complete"
  - _Requirements: 7.3_

- [ ]* 11.1 Write property test for navigation state consistency
  - **Property 5: Navigation State Consistency**
  - **Validates: Requirements 7.3**

- [x] 12. Integrate with AppointmentDetailScreen
  - Open `lib/appointment/appointment_detail_screen.dart`
  - Find "Download Receipt" button onPressed handler
  - Add navigation to InvoiceViewerScreen using Get.to()
  - Pass appointmentId: `widget.appointment.id.toString()`
  - Pass doctorName: `widget.appointment.doctorName`
  - Import InvoiceViewerScreen
  - _Requirements: 1.1, 7.1, 7.2_

- [x] 13. Checkpoint - Test end-to-end flow
  - Ensure all tests pass
  - Test navigation from appointment detail to invoice viewer
  - Test invoice loading with valid appointment ID
  - Test error handling with invalid appointment ID
  - Test download functionality
  - Test share functionality
  - Test back navigation and download blocking
  - Verify UI consistency with PrescriptionViewerScreen
  - Ask the user if questions arise

- [ ]* 14. Write integration tests
  - Test complete flow from AppointmentDetailScreen to InvoiceViewerScreen
  - Test loading state transitions
  - Test error state and retry flow
  - Test download button interaction
  - Test share button interaction
  - Test page navigation in multi-page PDFs
  - Test back navigation blocking during download
  - _Requirements: All_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties with minimum 100 iterations
- Unit tests validate specific examples and edge cases
- Integration tests validate end-to-end flows
- Follow existing PrescriptionViewerScreen patterns for consistency
- Use AppColors constants for all colors
- Maintain 48px minimum touch targets for accessibility
- Test on multiple devices and screen sizes
