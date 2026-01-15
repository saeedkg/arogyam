import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../auth/user_management/service/auth_token_provider.dart';
import '../../_shared/constants/network_config.dart';
import '../../_shared/utils/file_downloader.dart';

/// Service for managing invoice PDF files
class InvoiceService {
  InvoiceService._();
  
  static final InvoiceService _instance = InvoiceService._();
  factory InvoiceService() => _instance;

  /// Downloads invoice to temporary cache for viewing
  /// Returns local file path if successful, null otherwise
  Future<String?> fetchInvoiceForViewing({
    required String appointmentId,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // Check if already cached
      final cachedPath = await getCachedInvoicePath(appointmentId);
      if (cachedPath != null) {
        return cachedPath;
      }

      // Get temporary directory for caching
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/invoice_cache');
      
      // Create cache directory if it doesn't exist
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      // Create file path
      final fileName = 'invoice_$appointmentId.pdf';
      final filePath = '${cacheDir.path}/$fileName';

      // Download directly to cache using Dio
      final dio = Dio();
      final authToken = await AuthTokenProvider().getToken(forceRefresh: false);

      dio.options.headers = {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
      };

      await dio.download(
        "${NetworkConfig.baseUrl}/patient/appointments/$appointmentId/invoice",
        filePath,
        onReceiveProgress: onProgress,
      );

      return filePath;
    } catch (e) {
      print('Error fetching invoice for viewing: $e');
      return null;
    }
  }

  /// Downloads invoice permanently to device storage
  /// Returns true if successful, false otherwise
  Future<bool> downloadInvoicePermanently({
    required String appointmentId,
    required String fileName,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      final authToken = await AuthTokenProvider().getToken(forceRefresh: false);
      final url = "${NetworkConfig.baseUrl}/patient/appointments/$appointmentId/invoice";
      
      final filePath = await FileDownloader.downloadFile(
        url: url,
        fileName: fileName,
        onProgress: onProgress,

      );
      
      return filePath != null;
    } catch (e) {
      print('Error downloading invoice permanently: $e');
      return false;
    }
  }

  /// Gets cached invoice file path if exists
  /// Returns file path if cached, null otherwise
  Future<String?> getCachedInvoicePath(String appointmentId) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/invoice_cache');
      final fileName = 'invoice_$appointmentId.pdf';
      final filePath = '${cacheDir.path}/$fileName';
      
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      
      return null;
    } catch (e) {
      print('Error getting cached invoice path: $e');
      return null;
    }
  }

  /// Clears temporary invoice cache
  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/invoice_cache');
      
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
