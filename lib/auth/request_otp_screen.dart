import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'provider/auth_provider.dart';
import 'enter_otp_screen.dart';

class RequestOtpScreen extends StatefulWidget {
  const RequestOtpScreen({super.key});

  @override
  State<RequestOtpScreen> createState() => _RequestOtpScreenState();
}

class _RequestOtpScreenState extends State<RequestOtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final ValueNotifier<bool> _checkboxValue = ValueNotifier<bool>(true);
  final ValueNotifier<bool> hasNavigated = ValueNotifier<bool>(false);
  bool _hasClearedErrors = false;
  
  // Validation state
  String? _phoneError;
  bool _isPhoneValid = false;
  
  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }
  
  @override
  void dispose() {
    _phoneController.removeListener(_validatePhone);
    _phoneController.dispose();
    super.dispose();
  }
  
  void _validatePhone() {
    final phone = _phoneController.text.trim();
    setState(() {
      if (phone.isEmpty) {
        _phoneError = null;
        _isPhoneValid = false;
      } else if (phone.length < 10) {
        _phoneError = 'Phone number must be 10 digits';
        _isPhoneValid = false;
      } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
        _phoneError = 'Please enter a valid Indian mobile number';
        _isPhoneValid = false;
      } else {
        _phoneError = null;
        _isPhoneValid = true;
      }
    });
  }

  bool _isNetworkError(String? error) {
    if (error == null) return false;
    return error.toLowerCase().contains('internet') || 
           error.toLowerCase().contains('network') ||
           error.toLowerCase().contains('connection') ||
           error.toLowerCase().contains('offline');
  }

  String _getErrorMessage(String error) {
    if (_isNetworkError(error)) {
      return 'No internet connection. Please check your network and try again.';
    }
    // Since provider already extracts the clean message, use it directly
    return error;
  }

  IconData _getErrorIcon(String error) {
    if (_isNetworkError(error)) {
      return Icons.wifi_off;
    }
    return Icons.error_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
          // Clear any previous errors when screen is built (only once)
          if (!_hasClearedErrors && authProvider.requestOtpError != null) {
            _hasClearedErrors = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authProvider.clearError();
            });
          }
          
          // Navigation logic
          if (authProvider.expiresIn != null && !authProvider.isLoading && !hasNavigated.value) {
            hasNavigated.value = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnterOtpScreen(
                    phoneNumber: "+91 "+_phoneController.text.trim(),
                  ),
                ),
              );
            });
          }

          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    const Text(
                      'Phone number',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Enter your mobile number and we’ll send you\na verification code to confirm",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300, width: 1.2),
                          ),
                          child: Row(
                            children: [
                              Image.asset('assets/flag/flag_in.png', width: 28, height: 20, fit: BoxFit.cover),
                              const SizedBox(width: 8),
                              const Text(
                                '+91',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                style: const TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  counterText: '',
                                  hintText: '9035XXXXXX',
                                  hintStyle: const TextStyle(
                                    color: Colors.black26,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFF22C58B), width: 1.8),
                                  ),
                                  errorText: _phoneError,
                                  errorStyle: TextStyle(color: Colors.red.shade600, fontSize: 12),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.red.shade400, width: 1.6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: _checkboxValue,
                          builder: (context, value, _) {
                            return Checkbox(
                              value: value,
                              onChanged: (val) => _checkboxValue.value = val ?? false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: const Color(0xFF22C58B),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                         Expanded(
                          child: _buildTermsAndPrivacyText(context)
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (authProvider.requestOtpError != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getErrorIcon(authProvider.requestOtpError!),
                              color: Colors.red.shade600, 
                              size: 20
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getErrorMessage(authProvider.requestOtpError!),
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (authProvider.isLoading || !_isPhoneValid)
                            ? null
                            : () {
                                final phone = _phoneController.text.trim();
                                
                                // Check terms and conditions
                                if (!_checkboxValue.value) {
                                  FocusScope.of(context).unfocus();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please accept terms and conditions'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                            );
                                  return;
                                }
                                
                                if (_isPhoneValid) {
                                  hasNavigated.value = false; // Reset before requesting OTP
                                  authProvider.requestOtp(phone);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (authProvider.isLoading || !_isPhoneValid)
                              ? Colors.grey.shade300
                              : const Color(0xFF22C58B),
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: (authProvider.isLoading || !_isPhoneValid)
                              ? Colors.grey.shade700
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        child: authProvider.isLoading 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Get OTP'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Get.offAllNamed('/landing');
                        },
                        child: const Text(
                          'Browse as guest',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // WhatsApp Community Join Button at bottom

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      );
  }

  // Create this function in your widget class
  Widget _buildTermsAndPrivacyText(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.3,
        ),
        children: [
          const TextSpan(text: "By continuing, you agree to our "),
          TextSpan(
            text: "Terms of Service",
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _navigateToTerms(context),
          ),
          const TextSpan(text: " and "),
          TextSpan(
            text: "Privacy Policy",
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _navigateToPrivacyPolicy(context),
          ),
          const TextSpan(
              text: ". You may receive SMS notifications from us and can opt out at any time."
          ),
        ],
      ),
    );
  }

// Helper navigation methods
  void _navigateToTerms(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
    // );
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    // );
  }
} 