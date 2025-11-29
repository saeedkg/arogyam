import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../auth/user_management/service/auth_token_provider.dart';
import '../../_shared/constants/network_config.dart';
import '../../_shared/utils/file_downloader.dart';

/// Service for managing prescription PDF files
class PrescriptionService {
  PrescriptionService._();
  
  static final PrescriptionService _instance = PrescriptionService._();
  factory PrescriptionService() => _instance;

  /// Downloads prescription to temporary cache for viewing
  /// Returns local file path if successful, null otherwise
  Future<String?> fetchPrescriptionForViewing({
    required String prescriptionUrl,
    required String prescriptionId,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // Check if already cached
      final cachedPath = await getCachedPrescriptionPath(prescriptionId);
      if (cachedPath != null) {
        return cachedPath;
      }

      // Get temporary directory for caching
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/prescription_cache');
      
      // Create cache directory if it doesn't exist
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      // Create file path
      final fileName = 'prescription_$prescriptionId.pdf';
      final filePath = '${cacheDir.path}/$fileName';

      // Download directly to cache using Dio
      final dio = Dio();
      final authToken = await AuthTokenProvider().getToken(forceRefresh: false);

      dio.options.headers = {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
      };

      await dio.download(
        "${NetworkConfig.baseUrl}/patient/prescriptions/$prescriptionUrl/download",
        filePath,
        onReceiveProgress: onProgress,
      );

      return filePath;
    } catch (e) {
      print('Error fetching prescription for viewing: $e');
      return null;
    }
  }

  /// Downloads prescription permanently to device storage
  /// Returns true if successful, false otherwise
  Future<bool> downloadPrescriptionPermanently({
    required String prescriptionUrl,
    required String fileName,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      final filePath = await FileDownloader.downloadFile(
        url: prescriptionUrl,
        fileName: fileName,
        onProgress: onProgress,
      );
      
      return filePath != null;
    } catch (e) {
      print('Error downloading prescription permanently: $e');
      return false;
    }
  }

  /// Gets cached prescription file path if exists
  /// Returns file path if cached, null otherwise
  Future<String?> getCachedPrescriptionPath(String prescriptionId) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/prescription_cache');
      final fileName = 'prescription_$prescriptionId.pdf';
      final filePath = '${cacheDir.path}/$fileName';
      
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      
      return null;
    } catch (e) {
      print('Error getting cached prescription path: $e');
      return null;
    }
  }

  /// Clears temporary prescription cache
  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/prescription_cache');
      
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
