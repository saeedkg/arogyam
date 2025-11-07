import 'package:arogyam/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../_shared/ui/app_colors.dart';
import '../landing/ui/landing_screen.dart';
import 'register_screen.dart';

class EnterOtpScreen extends StatefulWidget {
  final String phoneNumber;
  const EnterOtpScreen({super.key, required this.phoneNumber});

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  static const int otpLength = 6;
  final List<FocusNode> _focusNodes = List.generate(otpLength, (_) => FocusNode());
  final List<FocusNode> _keyboardFocusNodes = List.generate(otpLength, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(otpLength, (_) => TextEditingController());
  bool _submitted = false;
  int? _remainingSeconds;
  Timer? _timer;
  bool _resending = false;
  bool _hasClearedErrors = false;

  // Validation state
  bool _isOtpValid = false;
  bool _isOtpComplete = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.expiresIn != null && (_remainingSeconds == null || _remainingSeconds != authProvider.expiresIn)) {
      _startTimer(authProvider.expiresIn!);
    }
  }

  void _startTimer(int seconds) {
    _remainingSeconds = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == null) return;
      if (_remainingSeconds! > 0) {
        setState(() {
          _remainingSeconds = _remainingSeconds! - 1;
        });
      } else {
        timer.cancel();
        setState(() {});
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final node in _keyboardFocusNodes) {
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    _validateOtp();
    setState(() {});
  }

  void _onKeyPressed(KeyEvent event, int index) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isNotEmpty) {
          _controllers[index].clear();
          _validateOtp();
          setState(() {});
        } else if (index > 0) {
          _controllers[index - 1].clear();
          _focusNodes[index - 1].requestFocus();
          _validateOtp();
          setState(() {});
        }
      }
    }
  }

  void _closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _validateOtp() {
    final otp = _controllers.map((c) => c.text).join();
    setState(() {
      _isOtpComplete = otp.length == otpLength;
      _isOtpValid = otp.length == otpLength && RegExp(r'^\d{6}$').hasMatch(otp);
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

  Future<void> _resendCode(BuildContext context) async {
    setState(() {
      _resending = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resendOtp(widget.phoneNumber.replaceFirst('+91', ''));

      if (authProvider.expiresIn != null) {
        _startTimer(authProvider.expiresIn!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resend OTP. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _resending = false;
      });
    }
  }

  Future<void> _submitOtp(BuildContext context) async {
    _closeKeyboard();
    final otp = _controllers.map((c) => c.text).join();

    if (!_isOtpValid) {
      if (!_isOtpComplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter the complete $otpLength-digit OTP.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid $otpLength-digit OTP.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _submitted = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.verifyOtp(
        mobile: widget.phoneNumber.replaceFirst('+91', ''),
        otp: otp,
        context: context,
      );

      if (response != null && response.success == true) {
        // Check if user is new (is_new_user = true means userExists = false)
        if (!response.userExists) {
          // New user - navigate to registration screen
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RegisterScreen(
                  phoneNumber: widget.phoneNumber,
                  otp: otp,
                ),
              ),
            );
          }
        } else {
          // Existing user - go to landing page
          if (mounted) {
            authProvider.resetAuthState();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LandingPage()),
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid OTP. Please check and try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _submitted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomPadding > 0;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!_hasClearedErrors && authProvider.verifyOtpError != null) {
          _hasClearedErrors = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.clearError();
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
                  const SizedBox(height: 16),

                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Header Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter OTP Code',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "We've sent a 6-digit code to\n${widget.phoneNumber}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Timer
                  if (_remainingSeconds != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _remainingSeconds! > 0 ? Colors.blue.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _remainingSeconds! > 0 ? Icons.access_time_rounded : Icons.error_outline_rounded,
                            size: 16,
                            color: _remainingSeconds! > 0 ? Colors.blue.shade700 : Colors.red.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _remainingSeconds! > 0
                                ? 'Expires in ${_formatDuration(_remainingSeconds!)}'
                                : 'OTP expired',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _remainingSeconds! > 0 ? Colors.blue.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(otpLength, (i) {
                      return Container(
                        width: 48,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _controllers[i].text.isNotEmpty
                                ? AppColors.primaryGreen
                                : AppColors.grey300,
                            width: _controllers[i].text.isNotEmpty ? 1.5 : 1,
                          ),
                          color: Colors.grey.shade50,
                        ),
                        child: KeyboardListener(
                          focusNode: _keyboardFocusNodes[i],
                          onKeyEvent: (event) => _onKeyPressed(event, i),
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) => _onChanged(value, i),
                            onSubmitted: (value) => _closeKeyboard(),
                            textInputAction: i == otpLength - 1 ? TextInputAction.done : TextInputAction.next,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Resend Code Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive code?",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: (_remainingSeconds ?? 0) > 0 || _resending ? null : () => _resendCode(context),
                        child: _resending
                            ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                          ),
                        )
                            : Text(
                          "Resend OTP",
                          style: TextStyle(
                            color: (_remainingSeconds ?? 0) > 0 ? AppColors.grey400 : AppColors.primaryGreen,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Error Display
                  if (authProvider.verifyOtpError != null) ...[
                    const SizedBox(height: 16),
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
                            _getErrorIcon(authProvider.verifyOtpError!),
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getErrorMessage(authProvider.verifyOtpError!),
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
                  ],
                  SizedBox(height: 10,),
                  // Dynamic spacer
                  if (!isKeyboardVisible) const Spacer(),

                  // Verify Button
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (authProvider.isLoading || _submitted || !_isOtpValid)
                              ? null
                              : () => _submitOtp(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            disabledBackgroundColor: AppColors.grey300,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: authProvider.isLoading || _submitted
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text(
                            'Verify & Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isKeyboardVisible ? 16 : 32),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}