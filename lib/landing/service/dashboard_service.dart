import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../../_shared/constants/network_config.dart';
import '../entities/dashboard_data.dart';

class DashboardService {
  final NetworkAdapter _networkAdapter;

  DashboardService({NetworkAdapter? networkAdapter}) 
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  Future<DashboardData> fetchDashboardData() async {
    final url = '${NetworkConfig.baseUrl}/patient/dashboard';
    final apiRequest = APIRequest(url);
    
    try {
      final res = await _networkAdapter.get(apiRequest);
      
      if (res.data is Map<String, dynamic>) {
        var dashboardData = DashboardData.fromJson(res.data as Map<String, dynamic>);
        
        // Add mock follow-up chats if API returns empty
        if (dashboardData.followUpChats.isEmpty) {
          dashboardData = DashboardData(
            appointmentCounts: dashboardData.appointmentCounts,
            consultationsToJoin: dashboardData.consultationsToJoin,
            totalDoctors: dashboardData.totalDoctors,
            recentConsultations: dashboardData.recentConsultations,
            upcomingAppointments: dashboardData.upcomingAppointments,
            familyMembersCount: dashboardData.familyMembersCount,
            followUpChats: [
              FollowUpChatSummary(
                id: 1,
                appointmentId: 101,
                doctorName: 'Sarah Johnson',
                doctorImage: null,
                latestMessage: 'Please take the prescribed medication twice daily',
                unreadCount: 2,
                latestMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
              ),
              FollowUpChatSummary(
                id: 2,
                appointmentId: 102,
                doctorName: 'Michael Chen',
                doctorImage: null,
                latestMessage: 'How are you feeling today?',
                unreadCount: 0,
                latestMessageAt: DateTime.now().subtract(const Duration(days: 1)),
              ),
            ],
          );
        }
        
        return dashboardData;
      }
      
      throw Exception('Invalid response format');
      
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        // Check for TOKEN_INVALID with action: login
        if (exception.responseData != null && exception.responseData is Map<String, dynamic>) {
          final responseMap = exception.responseData as Map<String, dynamic>;
          final errorCode = responseMap['error_code'];
          final action = responseMap['action'];
          
          // If token is invalid and action is login, throw special exception
          if (errorCode == 'TOKEN_INVALID' && action == 'login') {
            throw TokenInvalidException(responseMap['message'] ?? 'Your session has expired. Please login again.');
          }
        }
        
        // Handle other HTTP exceptions
        if (exception.responseData != null &&
            exception.responseData is Map<String, dynamic> &&
            (exception.responseData as Map<String, dynamic>)["message"] != null) {
          final responseMap = exception.responseData as Map<String, dynamic>;
          final message = responseMap["message"] as String;
          final errorCode = responseMap["errorCode"] ?? exception.httpCode;
          throw ServerSentException(message, errorCode);
        }
        throw ServerSentException('Failed to fetch dashboard data', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }
}