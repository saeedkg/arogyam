# Prescription Download Implementation

## Overview
Implemented file download functionality for the "Download Prescription" button in the appointment detail screen. The implementation includes progress tracking, permission handling, and automatic file opening after download.

## Changes Made

### 1. Added Dependencies (`pubspec.yaml`)

Added two new packages for file handling:

```yaml
path_provider: ^2.1.5  # For getting device directories
open_filex: ^4.5.0     # For opening downloaded files
```

**Installation:**
```bash
flutter pub get
```

### 2. Created FileDownloader Utility (`lib/_shared/utils/file_downloader.dart`)

A comprehensive utility class for downloading files with the following features:

#### Key Features:
- ✅ **Permission Handling** - Automatically requests storage permissions
- ✅ **Progress Tracking** - Provides download progress callbacks
- ✅ **Platform Support** - Works on Android and iOS
- ✅ **Auto-Open** - Opens downloaded file with default app
- ✅ **Error Handling** - Comprehensive error handling
- ✅ **Smart Directory** - Saves to Downloads folder on Android, Documents on iOS

#### Main Methods:

**`downloadFile()`** - Downloads a file from URL
```dart
final filePath = await FileDownloader.downloadFile(
  url: 'https://example.com/file.pdf',
  fileName: 'prescription.pdf',
  onProgress: (received, total) {
    print('Progress: ${(received / total * 100).toInt()}%');
  },
);
```

**`openFile()`** - Opens a downloaded file
```dart
final success = await FileDownloader.openFile(filePath);
```

**`downloadAndOpenFile()`** - Downloads and opens in one call
```dart
final success = await FileDownloader.downloadAndOpenFile(
  url: 'https://example.com/file.pdf',
  fileName: 'prescription.pdf',
  onProgress: (received, total) {
    // Handle progress
  },
);
```

### 3. Updated Appointment Detail Screen (`lib/appointment/appointment_detail_screen.dart`)

#### Added State Variables:
```dart
bool _isDownloadingPrescription = false;
double _downloadProgress = 0.0;
```

#### Added Download Method:
```dart
Future<void> _downloadPrescription(String prescriptionUrl) async {
  // Downloads file with progress tracking
  // Shows success/error snackbar
  // Opens file automatically after download
}
```

#### Updated Download Button:
- Shows download progress with percentage
- Disables button during download
- Displays circular progress indicator
- Shows success/error feedback via SnackBar

#### Additional Improvements:
- ✅ Fixed deprecated `withOpacity` → `withValues(alpha:)`
- ✅ Removed unused `_formatDate`, `_formatTime`, `_pad`, `_month` methods
- ✅ Added `FileDownloader` import

## How It Works

### User Flow:

1. **User taps "Download Prescription" button**
   - Button becomes disabled
   - Shows "Downloading..." with progress indicator

2. **Permission Check**
   - Automatically requests storage permission if needed
   - Handles Android 13+ permission changes

3. **File Download**
   - Downloads file using Dio
   - Shows progress percentage (e.g., "Downloading 45%")
   - Saves to appropriate directory:
     - Android: `/storage/emulated/0/Download/`
     - iOS: App's Documents directory

4. **Auto-Open**
   - Automatically opens the downloaded file
   - Uses device's default PDF viewer

5. **Feedback**
   - Success: Green snackbar with checkmark
   - Error: Red snackbar with error message

### Download Button States:

**Normal State:**
```
[📥 Download Prescription]
```

**Downloading State:**
```
[⏳ Downloading 45%]
```

**After Download:**
```
[📥 Download Prescription]  (Re-enabled)
```

## Platform-Specific Behavior

### Android:
- Downloads to `/storage/emulated/0/Download/` folder
- Requests storage permission (handles API 33+ changes)
- File accessible from Files app and Downloads folder

### iOS:
- Downloads to app's Documents directory
- No permission needed
- File accessible from Files app

## Error Handling

The implementation handles various error scenarios:

1. **Permission Denied**
   - Shows error message
   - Guides user to grant permission

2. **Network Error**
   - Shows error message
   - User can retry

3. **Storage Full**
   - Shows appropriate error message

4. **Invalid URL**
   - Shows error message

## UI/UX Features

### Progress Indicator:
- Circular progress with percentage
- Updates in real-time
- Smooth animation

### SnackBar Feedback:
- **Success**: Green background, checkmark icon
- **Error**: Red background, error icon
- Floating style with rounded corners
- Auto-dismisses after 3 seconds

### Button States:
- **Enabled**: Blue background, clickable
- **Downloading**: Dimmed blue, disabled
- **Disabled**: Gray background (when no prescription)

## Code Example

### Basic Usage:
```dart
// In your screen
Future<void> _downloadPrescription(String url) async {
  setState(() => _isDownloading = true);
  
  final success = await FileDownloader.downloadAndOpenFile(
    url: url,
    fileName: 'prescription_${appointmentId}.pdf',
    onProgress: (received, total) {
      setState(() {
        _progress = received / total;
      });
    },
  );
  
  setState(() => _isDownloading = false);
  
  if (success) {
    // Show success message
  } else {
    // Show error message
  }
}
```

### In Widget:
```dart
ElevatedButton(
  onPressed: _isDownloading ? null : () => _downloadPrescription(url),
  child: _isDownloading
      ? Row(
          children: [
            CircularProgressIndicator(value: _progress),
            Text('Downloading ${(_progress * 100).toInt()}%'),
          ],
        )
      : Row(
          children: [
            Icon(Icons.download_rounded),
            Text('Download Prescription'),
          ],
        ),
)
```

## Testing Checklist

- [ ] Install dependencies: `flutter pub get`
- [ ] Test download on Android device
- [ ] Test download on iOS device
- [ ] Test permission request flow
- [ ] Test progress indicator updates
- [ ] Test file opens after download
- [ ] Test error handling (no internet, invalid URL)
- [ ] Test button states (enabled/disabled/downloading)
- [ ] Test snackbar messages
- [ ] Verify file saved to correct location

## Permissions Required

### Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

### iOS (`ios/Runner/Info.plist`):
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to save prescription files</string>
```

## Future Enhancements

1. **Download History** - Track downloaded prescriptions
2. **Share Option** - Share prescription via WhatsApp, Email, etc.
3. **Print Option** - Direct print functionality
4. **Multiple Formats** - Support for images, Word docs, etc.
5. **Offline Access** - View previously downloaded prescriptions offline
6. **Cloud Backup** - Sync prescriptions to cloud storage

## Troubleshooting

### Issue: Permission Denied
**Solution**: Check AndroidManifest.xml has correct permissions

### Issue: File Not Opening
**Solution**: Ensure device has a PDF viewer app installed

### Issue: Download Fails
**Solution**: Check internet connection and URL validity

### Issue: Progress Not Updating
**Solution**: Ensure `onProgress` callback is properly connected to setState

## Files Modified

1. `pubspec.yaml` - Added dependencies
2. `lib/_shared/utils/file_downloader.dart` - New utility class
3. `lib/appointment/appointment_detail_screen.dart` - Updated with download functionality

## Dependencies

- `dio: ^5.9.0` - Already installed (for HTTP requests)
- `path_provider: ^2.1.5` - New (for directory access)
- `open_filex: ^4.5.0` - New (for opening files)
- `permission_handler: ^11.3.1` - Already installed (for permissions)
