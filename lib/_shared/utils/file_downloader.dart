import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

/// Utility class for downloading files
class FileDownloader {
  FileDownloader._();

  /// Downloads a file from the given URL and saves it to device storage
  /// Returns the file path if successful, null otherwise
  static Future<String?> downloadFile({
    required String url,
    required String fileName,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get the directory to save the file
      final directory = await _getDownloadDirectory();
      if (directory == null) {
        throw Exception('Could not access download directory');
      }

      // Create the full file path
      final filePath = '${directory.path}/$fileName';

      // Download the file using Dio
      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: onProgress,
      );

      return filePath;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  /// Opens the downloaded file using the default app
  static Future<bool> openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      return result.type == ResultType.done;
    } catch (e) {
      print('Error opening file: $e');
      return false;
    }
  }

  /// Downloads and opens a file
  static Future<bool> downloadAndOpenFile({
    required String url,
    required String fileName,
    Function(int received, int total)? onProgress,
  }) async {
    final filePath = await downloadFile(
      url: url,
      fileName: fileName,
      onProgress: onProgress,
    );

    if (filePath != null) {
      return await openFile(filePath);
    }

    return false;
  }

  /// Request storage permission
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we don't need storage permission for downloads
      if (await Permission.storage.isGranted) {
        return true;
      }

      // Request permission
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }

      // For Android 13+, try photos permission
      if (await Permission.photos.isGranted) {
        return true;
      }

      final photosStatus = await Permission.photos.request();
      return photosStatus.isGranted;
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit permission for downloads to app directory
      return true;
    }

    return true; // For other platforms
  }

  /// Get the appropriate download directory based on platform
  static Future<Directory?> _getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Try to get the Downloads directory
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Navigate to Downloads folder
          final downloadsPath = Directory('/storage/emulated/0/Download');
          if (await downloadsPath.exists()) {
            return downloadsPath;
          }
          // Fallback to app's external storage
          return directory;
        }
      } else if (Platform.isIOS) {
        // For iOS, use the app's documents directory
        return await getApplicationDocumentsDirectory();
      }

      // Fallback for other platforms
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      print('Error getting download directory: $e');
      return null;
    }
  }

  /// Get a unique file name if file already exists
  static Future<String> getUniqueFileName(String directory, String fileName) async {
    final file = File('$directory/$fileName');
    if (!await file.exists()) {
      return fileName;
    }

    // File exists, add a number suffix
    final extension = fileName.split('.').last;
    final nameWithoutExtension = fileName.substring(0, fileName.length - extension.length - 1);

    int counter = 1;
    while (true) {
      final newFileName = '${nameWithoutExtension}_$counter.$extension';
      final newFile = File('$directory/$newFileName');
      if (!await newFile.exists()) {
        return newFileName;
      }
      counter++;
    }
  }
}
