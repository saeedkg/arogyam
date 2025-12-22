# PendingConsultationScreen Health Records Integration

## Overview
Added health records functionality to the PendingConsultationScreen to display appointment-specific health records and allow navigation to the HealthRecordViewerScreen.

## Implementation Details

### 🔗 **API Integration**

#### New API Endpoint:
- **URL**: `{{base_url}}/patient/health-records?appointment_id={{appointment_id}}`
- **Method**: GET
- **Purpose**: Fetch health records specific to an appointment

#### Response Structure Handled:
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 6,
        "title": "Health Record Title",
        "description": "Record description",
        "type": "lab_report",
        "file_path": "health-records/path/file.jpg",
        "file_name": "original_file.jpg",
        "file_type": "image/jpeg",
        "file_size": 332415,
        "created_at": "2025-12-22T06:31:07.000000Z",
        "appointment_id": 21
      }
    ]
  }
}
```

### 🏗️ **Code Changes Made**

#### 1. **Enhanced HealthRecordsService** (`lib/health_records/service/health_records_service.dart`):
```dart
Future<List<HealthRecord>> fetchHealthRecordsForAppointment(String appointmentId) async {
  final url = HealthRecordsUrls.getHealthRecordsForAppointmentUrl(appointmentId);
  // API call implementation with proper error handling
}
```

#### 2. **Updated HealthRecordsUrls** (`lib/health_records/constants/health_records_urls.dart`):
```dart
static String getHealthRecordsForAppointmentUrl(String appointmentId) {
  return '${NetworkConfig.baseUrl}/patient/health-records?appointment_id=$appointmentId';
}
```

#### 3. **Enhanced HealthRecord Entity** (`lib/health_records/entities/health_record.dart`):
```dart
class HealthRecord {
  final String fileName;
  final String fileType;
  final int fileSize;
  final String type;
  
  bool get isImage => fileType?.startsWith('image/') == true;
  bool get isPdf => fileType == 'application/pdf';
  String get displayFileSize => // Formatted file size
}
```

#### 4. **Updated PendingConsultationController** (`lib/consultation_pending/controller/pending_consultation_controller.dart`):
```dart
final RxBool isLoadingHealthRecords = false.obs;
final RxList<HealthRecord> healthRecords = <HealthRecord>[].obs;

Future<void> loadHealthRecords(String appointmentId) async {
  // Load health records for specific appointment
}

Future<void> refreshHealthRecords(String appointmentId) async {
  // Refresh health records after upload
}
```

#### 5. **Enhanced PendingConsultationScreen** (`lib/consultation_pending/ui/pending_consultation_screen.dart`):
- Added health records section between consultation details and upload section
- Professional card-based design for health records display
- File type icons and colors based on file type
- Navigation to HealthRecordViewerScreen on tap
- Automatic refresh after document upload

### 🎨 **UI/UX Features**

#### Health Records Section:
1. **Professional Header**:
   - Green-themed design to match medical context
   - Shows record count
   - Folder icon for visual clarity

2. **Record Cards**:
   - File type specific icons (image, PDF, document)
   - Color-coded based on file type
   - Shows title, type, file size
   - Displays description/notes if available
   - Tap to view functionality

3. **File Type Support**:
   - **Images**: Blue icon with image symbol
   - **PDFs**: Red icon with PDF symbol
   - **Other**: Gray icon with document symbol

4. **Smart Display**:
   - Only shows section if records exist
   - Loading state while fetching
   - Proper error handling
   - Responsive design

### 🔄 **Data Flow**

1. **Screen Load**:
   ```
   PendingConsultationScreen → Controller.load() → 
   loadHealthRecords() → API Call → Update UI
   ```

2. **Document Upload**:
   ```
   Upload Dialog → Success → refreshHealthRecords() → 
   API Call → Update UI
   ```

3. **Record View**:
   ```
   Tap Record Card → Navigate to HealthRecordViewerScreen
   ```

### 📱 **Navigation Integration**

#### Health Record Viewer Navigation:
```dart
Get.toNamed('/health-record-viewer', arguments: {
  'recordId': record.id,
  'title': record.title,
  'fileUrl': record.fileUrl,
  'fileType': record.fileType,
});
```

### 🎯 **Key Features**

1. **Appointment-Specific Records**:
   - Only shows health records related to the current appointment
   - Filters out unrelated records automatically

2. **File Type Intelligence**:
   - Recognizes images, PDFs, and other document types
   - Shows appropriate icons and colors
   - Displays formatted file sizes

3. **Seamless Integration**:
   - Fits naturally into existing consultation flow
   - Maintains consistent design language
   - Proper loading and error states

4. **Real-time Updates**:
   - Automatically refreshes after document upload
   - Shows latest records without manual refresh

### 🔧 **Technical Implementation**

#### API Response Mapping:
```dart
HealthRecord _mapToHealthRecord(Map<String, dynamic> json) {
  return HealthRecord(
    id: '${json['id']}',
    title: json['title'] ?? 'Untitled Record',
    category: json['category']?['name'] ?? 'General',
    notes: json['description'],
    fileUrl: json['file_path'],
    fileName: json['file_name'],
    fileType: json['file_type'],
    fileSize: json['file_size'],
    type: json['type'] ?? 'general',
    // Date parsing with fallbacks
  );
}
```

#### Error Handling:
- Network failure exceptions
- Server error responses
- Invalid data handling
- Graceful fallbacks

### 🎨 **Visual Design**

#### Color Scheme:
- **Health Records Header**: Green theme (`Colors.green.shade50`)
- **Image Files**: Blue (`Colors.blue.shade600`)
- **PDF Files**: Red (`Colors.red.shade600`)
- **Other Files**: Gray (`Colors.grey.shade600`)

#### Layout:
- Consistent with existing consultation screen design
- Professional medical app appearance
- Clear visual hierarchy
- Proper spacing and padding

### 🚀 **Benefits**

1. **Enhanced User Experience**:
   - Patients can easily view shared health records
   - Quick access to appointment-specific documents
   - Seamless navigation to detailed viewer

2. **Better Doctor-Patient Communication**:
   - Shared records are clearly visible
   - Easy to reference during consultation
   - Organized by appointment context

3. **Improved Workflow**:
   - Upload and view in same screen
   - Real-time updates after upload
   - Contextual record display

4. **Professional Appearance**:
   - Medical-grade UI design
   - Consistent with app theme
   - Clear file type identification

The implementation provides a comprehensive health records viewing experience within the consultation context, making it easy for patients to access and share their medical documents during consultations.