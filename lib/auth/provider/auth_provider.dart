import 'package:flutter/material.dart';
import '../user_management/service/new_user_adder.dart';
import '../service/auth_service.dart';
import '../entities/verify_otp_response.dart';
import '../../network/exceptions/server_sent_exception.dart';

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
      final expires = await _authService.getOtp(phoneNumber);
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
      final success = await _authService.logout();
      if (success) {
        // Clear all auth state after successful logout
        resetAuthState();
        return true;
      } else {
        _error = 'Failed to logout. Please try again.';
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



} 