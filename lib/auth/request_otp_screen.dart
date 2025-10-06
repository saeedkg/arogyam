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
    return error;
  }

  IconData _getErrorIcon(String error) {
    if (_isNetworkError(error)) {
      return Icons.wifi_off_rounded;
    }
    return Icons.error_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomPadding > 0;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!_hasClearedErrors && authProvider.requestOtpError != null) {
          _hasClearedErrors = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.clearError();
          });
        }

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
                  const SizedBox(height: 40),

                  // Header Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Your Phone',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "We'll send a verification code to your\nmobile number",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Phone Input Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mobile Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Country Code
                          Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Image.asset('assets/flag/flag_in.png', width: 24, height: 18, fit: BoxFit.cover),
                                const SizedBox(width: 8),
                                Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Phone Number Field
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade900,
                                letterSpacing: 1.0,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                counterText: '',
                                hintText: 'Enter 10-digit number',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF22C58B), width: 1.5),
                                ),
                                errorText: _phoneError,
                                errorStyle: TextStyle(color: Colors.red.shade600, fontSize: 12),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red.shade400),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Terms and Conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _checkboxValue,
                        builder: (context, value, _) {
                          return Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: value ? const Color(0xFF22C58B) : Colors.grey.shade400,
                                width: 1.5,
                              ),
                              color: value ? const Color(0xFF22C58B) : Colors.transparent,
                            ),
                            child: Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.transparent,
                              ),
                              child: Checkbox(
                                value: value,
                                onChanged: (val) => _checkboxValue.value = val ?? false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor: Colors.transparent,
                                checkColor: Colors.white,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildTermsAndPrivacyText(context)
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Error Display
                  if (authProvider.requestOtpError != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(
                              _getErrorIcon(authProvider.requestOtpError!),
                              color: Colors.red.shade600,
                              size: 20
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getErrorMessage(authProvider.requestOtpError!),
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Dynamic spacer that shrinks when keyboard is visible
                  if (!isKeyboardVisible) const Spacer(),

                  // Action Buttons - Stays at bottom but moves up with keyboard
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (authProvider.isLoading || !_isPhoneValid)
                              ? null
                              : () {
                            final phone = _phoneController.text.trim();

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
                              hasNavigated.value = false;
                              authProvider.requestOtp(phone);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C58B),
                            disabledBackgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: authProvider.isLoading
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Get.offAllNamed('/landing');
                        },
                        child: Text(
                          'Browse as guest',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      // Add bottom padding only when keyboard is visible
                      SizedBox(height: isKeyboardVisible ? 16 : 0),
                    ],
                  ),

                  SizedBox(height: isKeyboardVisible ? 0 : 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermsAndPrivacyText(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
          height: 1.4,
        ),
        children: [
          const TextSpan(text: "By continuing, you agree to our "),
          TextSpan(
            text: "Terms of Service",
            style: const TextStyle(
              color: Color(0xFF22C58B),
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _navigateToTerms(context),
          ),
          const TextSpan(text: " and "),
          TextSpan(
            text: "Privacy Policy",
            style: const TextStyle(
              color: Color(0xFF22C58B),
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _navigateToPrivacyPolicy(context),
          ),
          const TextSpan(text: "."),
        ],
      ),
    );
  }

  void _navigateToTerms(BuildContext context) {
    // Navigation logic for terms
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    // Navigation logic for privacy policy
  }
}