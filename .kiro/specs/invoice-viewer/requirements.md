# Requirements Document: Invoice Viewer

## Introduction

This feature enables patients to view and download appointment invoices/receipts in PDF format. The invoice viewer provides a similar experience to the prescription viewer, allowing users to view, download, and share their appointment invoices.

## Glossary

- **Invoice**: A PDF document containing payment details and receipt for an appointment
- **Invoice_Viewer**: The screen component that displays the invoice PDF
- **Invoice_Service**: The service layer that handles invoice fetching and downloading
- **Appointment_ID**: The unique identifier for an appointment
- **Base_URL**: The API base URL (https://arogyam.focus-its.com/api/v1)

## Requirements

### Requirement 1: View Invoice

**User Story:** As a patient, I want to view my appointment invoice in the app, so that I can review payment details without leaving the application.

#### Acceptance Criteria

1. WHEN a user taps "Download Receipt" button on appointment detail screen, THE Invoice_Viewer SHALL navigate to the invoice viewer screen
2. WHEN the invoice viewer screen loads, THE Invoice_Viewer SHALL fetch the invoice PDF from the API endpoint `/patient/appointments/{appointment_id}/invoice`
3. WHEN the invoice is being fetched, THE Invoice_Viewer SHALL display a loading indicator with "Loading invoice..." text
4. WHEN the invoice is successfully fetched, THE Invoice_Viewer SHALL display the PDF in a scrollable viewer
5. WHEN the invoice fetch fails, THE Invoice_Viewer SHALL display an error message with a retry button

### Requirement 2: Download Invoice

**User Story:** As a patient, I want to download my invoice to my device, so that I can keep a permanent copy for my records.

#### Acceptance Criteria

1. WHEN the invoice is displayed, THE Invoice_Viewer SHALL show a download button in the app bar
2. WHEN a user taps the download button, THE Invoice_Service SHALL download the invoice to the device's Downloads folder
3. WHEN the download is in progress, THE Invoice_Viewer SHALL show download progress
4. WHEN the download completes successfully, THE Invoice_Viewer SHALL display a success message "Invoice downloaded successfully"
5. WHEN the download fails, THE Invoice_Viewer SHALL display an error message with a retry option

### Requirement 3: Share Invoice

**User Story:** As a patient, I want to share my invoice with others, so that I can send it via email, messaging apps, or other sharing methods.

#### Acceptance Criteria

1. WHEN the invoice is displayed, THE Invoice_Viewer SHALL show a share button in the app bar
2. WHEN a user taps the share button, THE Invoice_Viewer SHALL open the system share sheet
3. WHEN sharing, THE Invoice_Viewer SHALL include the invoice file and a subject line "Invoice - Dr. {doctor_name}"
4. WHEN sharing fails, THE Invoice_Viewer SHALL display an error message

### Requirement 4: PDF Navigation

**User Story:** As a patient, I want to navigate through multi-page invoices easily, so that I can view all invoice details.

#### Acceptance Criteria

1. WHEN an invoice has multiple pages, THE Invoice_Viewer SHALL allow vertical scrolling through pages
2. WHEN a user changes pages, THE Invoice_Viewer SHALL display a page indicator showing "Page X of Y"
3. THE Invoice_Viewer SHALL remember the current page position during the viewing session
4. THE Invoice_Viewer SHALL support pinch-to-zoom and pan gestures for better readability

### Requirement 5: Error Handling

**User Story:** As a patient, I want clear error messages when something goes wrong, so that I understand what happened and how to fix it.

#### Acceptance Criteria

1. WHEN the network connection fails, THE Invoice_Viewer SHALL display "Unable to load invoice. Please check your internet connection."
2. WHEN the invoice is not found (404), THE Invoice_Viewer SHALL display "Invoice not available. Please contact support."
3. WHEN the session expires, THE Invoice_Viewer SHALL display "Session expired. Please log in again."
4. WHEN storage permission is denied, THE Invoice_Viewer SHALL display "Unable to save file. Please check storage permissions."
5. WHEN any error occurs, THE Invoice_Viewer SHALL provide a "Try Again" button to retry the operation

### Requirement 6: API Integration

**User Story:** As a developer, I want a service layer for invoice operations, so that the code is maintainable and follows the existing architecture.

#### Acceptance Criteria

1. THE Invoice_Service SHALL fetch invoices from the endpoint `{base_url}/patient/appointments/{appointment_id}/invoice`
2. THE Invoice_Service SHALL cache the invoice locally for viewing
3. THE Invoice_Service SHALL download invoices permanently to the Downloads folder with filename format `invoice_{appointment_id}.pdf`
4. THE Invoice_Service SHALL report download progress via callbacks
5. THE Invoice_Service SHALL handle authentication tokens automatically via the network adapter

### Requirement 7: Screen Navigation

**User Story:** As a patient, I want smooth navigation to and from the invoice viewer, so that I have a seamless experience.

#### Acceptance Criteria

1. WHEN navigating to the invoice viewer, THE System SHALL pass appointment_id, doctor_name, and invoice_url as parameters
2. WHEN the back button is pressed, THE Invoice_Viewer SHALL navigate back to the previous screen
3. WHEN a download is in progress, THE Invoice_Viewer SHALL prevent navigation and show a message "Please wait for download to complete"
4. THE Invoice_Viewer SHALL display the doctor name in the app bar title as "Invoice - Dr. {doctor_name}"

### Requirement 8: UI Consistency

**User Story:** As a patient, I want the invoice viewer to look and feel consistent with the rest of the app, so that I have a familiar experience.

#### Acceptance Criteria

1. THE Invoice_Viewer SHALL use the same color scheme as PrescriptionViewerScreen (AppColors.primaryGreen, AppColors.grey50, etc.)
2. THE Invoice_Viewer SHALL use the same button styles and layouts as PrescriptionViewerScreen
3. THE Invoice_Viewer SHALL use the same loading, error, and success message patterns as PrescriptionViewerScreen
4. THE Invoice_Viewer SHALL follow the same PDF viewing patterns (page indicator, zoom, scroll) as PrescriptionViewerScreen
