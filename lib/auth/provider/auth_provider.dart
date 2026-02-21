import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'dart:io';
import '../user_management/service/new_user_adder.dart';
import '../service/auth_service.dart';
import '../service/logout_service.dart';
import '../entities/verify_otp_response.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../notification/service/device_service.dart';
import '../../notification/service/fcm_service.dart';
import '../../notification/service/notification_service.dart';
import '../../notification/repository/notification_repository.dart';
import '../../notification/entities/requests/device_registration_request.dart';
import '../../notification/utils/retry_policy.dart';
import '../../network/services/arogyam_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final _newUserAdder = NewUserAdder();



      bool _isLoading = false;
  String? _error;
  String? _requestOtpError;
  String? _verifyOtpError;
  String? _registerProfileError;
  int? _expiresIn;
  VerifyOtpResponse? _verifyOtpResponse;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get requestOtpError => _requestOtpError;
  String? get verifyOtpError => _verifyOtpError;
  String? get registerProfileError => _registerProfileError;
  int? get expiresIn => _expiresIn;
  VerifyOtpResponse? get verifyOtpResponse => _verifyOtpResponse;

  Future<void> requestOtp(String phoneNumber) async {
    _isLoading = true;
    _requestOtpError = null;
    _expiresIn = null;
    notifyListeners();
    try {
      // Get app signature for Android SMS auto-read
      String? appSignature;
      if (Platform.isAndroid) {
        try {
          appSignature = await SmsAutoFill().getAppSignature;
          debugPrint('Sending app signature to backend: $appSignature');
        } catch (e) {
          debugPrint('Failed to get app signature: $e');
        }
      }
      
      final expires = await _authService.getOtp(phoneNumber, appSignature: appSignature);
      _expiresIn = expires;
    } catch (e) {
      if (e is ServerSentException) {
        // Use the server-sent message directly
        _requestOtpError = e.userReadableMessage;
      } else {
        _requestOtpError = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<VerifyOtpResponse?> verifyOtp({required String mobile, required String otp, BuildContext? context}) async {
    _isLoading = true;
    _verifyOtpError = null;
    _verifyOtpResponse = null;
    notifyListeners();
    try {
      // Don't pass name initially - let server check if user exists
      final response = await _authService.verifyOtp(mobile: mobile, otp: otp);
      _verifyOtpResponse = response;
      
      // Only save user and clear state if user already exists (not a new user)
      print("object-----------");
      print(verifyOtpResponse?.userExists);
      if (verifyOtpResponse?.user != null && verifyOtpResponse?.userExists == true) {
        await _newUserAdder.addUser(_verifyOtpResponse!.user!);
        // Register device for push notifications (non-blocking)
        _registerDeviceInBackground();
        // Clear all auth state after successful login
        resetAuthState();
      }
      return response;
    } catch (e) {
      if (e is ServerSentException) {
        // Use the server-sent message directly
        _verifyOtpError = e.userReadableMessage;
      } else {
        _verifyOtpError = e.toString();
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<VerifyOtpResponse?> registerProfile({
    required String mobile,
    required String otp,
    required String name,
    required String email,
    BuildContext? context,
  }) async {
    _isLoading = true;
    _registerProfileError = null;
    _verifyOtpResponse = null;
    notifyListeners();
    try {
      final response = await _authService.verifyOtp(
        mobile: mobile,
        otp: otp,
        name: name,
        email: email.isNotEmpty ? email : null,
      );
      _verifyOtpResponse = response;
      if (verifyOtpResponse?.user != null && verifyOtpResponse?.success == true) {
        await _newUserAdder.addUser(_verifyOtpResponse!.user!);
        // Register device for push notifications (non-blocking)
        _registerDeviceInBackground();
        // Clear all auth state after successful registration
        resetAuthState();
      }
      return response;
    } catch (e) {
      if (e is ServerSentException) {
        // Use the server-sent message directly
        _registerProfileError = e.userReadableMessage;
      } else {
        _registerProfileError = e.toString();
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp(String phoneNumber) async {
    await requestOtp(phoneNumber);
  }

  void clearError() {
    _error = null;
    _requestOtpError = null;
    _verifyOtpError = null;
    _registerProfileError = null;
    notifyListeners();
  }

  void resetAuthState() {
    _error = null;
    _requestOtpError = null;
    _verifyOtpError = null;
    _registerProfileError = null;
    _expiresIn = null;
    _verifyOtpResponse = null;
    _isLoading = false;
    notifyListeners();
  }

  // Initialize with clean state
  void initializeCleanState() {
    resetAuthState();
  }

  // Clean logout - clears all auth state
  Future<bool> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Call logout API
      final success = await _authService.logout();
      
      // Clear FCM token
      await FCMService.deleteToken();
      
      // Clear notification data
      await DeviceService.clearRegistrationStatus();
      await NotificationService.clearHistory();
      
      // Clear all local user data regardless of API response
      // This ensures user data is cleared even if API call fails
      await LogoutService().clearAllUserData();
      
      // Clear all auth state
      resetAuthState();
      
      return success;
    } catch (e) {
      // Even if API call fails, clear local data
      await FCMService.deleteToken();
      await DeviceService.clearRegistrationStatus();
      await NotificationService.clearHistory();
      await LogoutService().clearAllUserData();
      resetAuthState();
      
      // Log error but don't prevent logout
      if (e is ServerSentException) {
        _error = e.userReadableMessage;
      } else {
        _error = e.toString();
      }
      // Return true to allow logout to proceed even if API fails
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _authService.deleteAccount();
      if (success) {
        // Clear all auth state after successful account deletion
        resetAuthState();
        return true;
      } else {
        _error = 'Failed to delete account. Please try again.';
        return false;
      }
    } catch (e) {
      if (e is ServerSentException) {
        // Use the server-sent message directly
        _error = e.userReadableMessage;
      } else {
        _error = e.toString();
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register device for push notifications (non-blocking)
  void _registerDeviceInBackground() {
    // Run in background without blocking login flow
    Future.microtask(() async {
      try {
        print('🔄 Starting device registration...');
        
        // Use retry policy for device registration
        await RetryPolicy.executeWithRetry(() async {
          // Get device ID
          final deviceId = await DeviceService.getOrCreateDeviceId();
          
          // Get device info
          final deviceInfo = await DeviceService.getDeviceInfo();
          
          // Get FCM token
          final fcmToken = await FCMService.getToken();
          
          if (fcmToken == null) {
            throw Exception('No FCM token available');
          }
          
          // Get user role from stored user data
          final prefs = await SharedPreferences.getInstance();
          final userRole = prefs.getString('user_role') ?? 'patient';
          
          // Create registration request
          final request = DeviceRegistrationRequest(
            deviceId: deviceId,
            deviceName: deviceInfo['device_name'],
            deviceType: deviceInfo['device_type']!,
            deviceModel: deviceInfo['device_model'],
            deviceOsVersion: deviceInfo['device_os_version'],
            appVersion: deviceInfo['app_version'],
            fcmToken: fcmToken,
          );
          
          // Register with backend
          final api = AROGYAMAPI();
          final repository = NotificationRepository(api, userRole);
          final response = await repository.registerDevice(request);
          
          if (response.statusCode == 200) {
            print('✅ Device registered successfully');
            await DeviceService.markDeviceRegistered();
          } else {
            throw Exception('Device registration failed: ${response.statusCode}');
          }
        });
      } catch (e) {
        print('❌ Error registering device after retries: $e');
        // Don't throw error - registration failure shouldn't block login
      }
    });
  }


} 