import '../../_shared/constants/network_config.dart';
import '../../network/entities/api_request.dart';
import '../../network/entities/api_response.dart';
import '../../network/services/arogyam_api.dart';
import '../entities/requests/device_registration_request.dart';
import '../entities/requests/device_settings_request.dart';
import '../entities/requests/notification_preference_request.dart';
import '../entities/requests/quiet_hours_request.dart';

class NotificationRepository {
  final AROGYAMAPI _api;
  final String _userRole; // 'patient' or 'doctor'

  NotificationRepository(this._api, this._userRole);

  // ==================== Device Management ====================

  Future<APIResponse> registerDevice(DeviceRegistrationRequest request) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/devices/register');
    apiRequest.addParameters(request.toJson());
    return await _api.post(apiRequest);
  }

  Future<APIResponse> getDevices({String? status, String? deviceType}) async {
    String url = '${NetworkConfig.baseUrl}/$_userRole/devices';
    List<String> queryParams = [];
    
    if (status != null) queryParams.add('status=$status');
    if (deviceType != null) queryParams.add('device_type=$deviceType');
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final apiRequest = APIRequest(url);
    return await _api.get(apiRequest);
  }

  Future<APIResponse> getDeviceDetails(String deviceId) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/devices/$deviceId');
    return await _api.get(apiRequest);
  }

  Future<APIResponse> updateDeviceSettings(
    String deviceId,
    DeviceSettingsRequest request,
  ) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/devices/$deviceId');
    apiRequest.addParameters(request.toJson());
    return await _api.put(apiRequest);
  }

  Future<APIResponse> removeDevice(String deviceId) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/devices/$deviceId');
    return await _api.delete(apiRequest);
  }

  Future<APIResponse> setPrimaryDevice(String deviceId) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/devices/$deviceId/primary');
    apiRequest.addParameters({});
    return await _api.post(apiRequest);
  }

  Future<APIResponse> refreshFCMToken(String deviceId, String fcmToken) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/devices/$deviceId/refresh-token');
    apiRequest.addParameters({'fcm_token': fcmToken});
    return await _api.post(apiRequest);
  }

  // ==================== Notification Preferences ====================

  Future<APIResponse> getNotificationPreferences(String deviceId) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/devices/$deviceId/preferences');
    return await _api.get(apiRequest);
  }

  Future<APIResponse> updateNotificationPreference(
    String deviceId,
    NotificationPreferenceRequest request,
  ) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/devices/$deviceId/preferences');
    apiRequest.addParameters(request.toJson());
    return await _api.put(apiRequest);
  }

  Future<APIResponse> setQuietHours(
    String deviceId,
    QuietHoursRequest request,
  ) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/devices/$deviceId/quiet-hours');
    apiRequest.addParameters(request.toJson());
    return await _api.put(apiRequest);
  }

  Future<APIResponse> bulkUpdatePreferences(
    String deviceId,
    List<NotificationPreferenceRequest> preferences,
  ) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/devices/$deviceId/preferences/bulk');
    apiRequest.addParameters({
      'preferences': preferences.map((p) => p.toJson()).toList(),
    });
    return await _api.post(apiRequest);
  }

  // ==================== Notification History ====================

  Future<APIResponse> getNotificationHistory({
    String? deviceId,
    String? notificationType,
    String? status,
    String? fromDate,
    String? toDate,
    int page = 1,
    int perPage = 20,
  }) async {
    String url = '${NetworkConfig.baseUrl}/$_userRole/notifications/history';
    List<String> queryParams = [];
    
    if (deviceId != null) queryParams.add('device_id=$deviceId');
    if (notificationType != null) queryParams.add('notification_type=$notificationType');
    if (status != null) queryParams.add('status=$status');
    if (fromDate != null) queryParams.add('from_date=$fromDate');
    if (toDate != null) queryParams.add('to_date=$toDate');
    queryParams.add('page=$page');
    queryParams.add('per_page=$perPage');
    
    url += '?${queryParams.join('&')}';

    final apiRequest = APIRequest(url);
    return await _api.get(apiRequest);
  }

  Future<APIResponse> getNotificationDetails(String notificationId) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/notifications/$notificationId');
    return await _api.get(apiRequest);
  }

  Future<APIResponse> markNotificationAsClicked(String notificationId) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/notifications/$notificationId/clicked');
    apiRequest.addParameters({});
    return await _api.post(apiRequest);
  }

  Future<APIResponse> getNotificationStatistics({
    String? deviceId,
    String? fromDate,
    String? toDate,
    String? groupBy,
  }) async {
    String url = '${NetworkConfig.baseUrl}/$_userRole/notifications/stats';
    List<String> queryParams = [];
    
    if (deviceId != null) queryParams.add('device_id=$deviceId');
    if (fromDate != null) queryParams.add('from_date=$fromDate');
    if (toDate != null) queryParams.add('to_date=$toDate');
    if (groupBy != null) queryParams.add('group_by=$groupBy');
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final apiRequest = APIRequest(url);
    return await _api.get(apiRequest);
  }

  // ==================== Testing ====================

  Future<APIResponse> sendTestNotification(
    String deviceId, {
    String? title,
    String? body,
  }) async {
    final Map<String, dynamic> requestBody = {};
    if (title != null) requestBody['title'] = title;
    if (body != null) requestBody['body'] = body;

    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/devices/$deviceId/test');
    apiRequest.addParameters(requestBody);
    return await _api.post(apiRequest);
  }

  Future<APIResponse> validateFCMToken(String deviceId) async {
    final apiRequest = APIRequest('${NetworkConfig.baseUrl}/$_userRole/devices/$deviceId/validate-token');
    apiRequest.addParameters({});
    return await _api.post(apiRequest);
  }
}
