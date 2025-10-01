import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'provider/auth_provider.dart';
import 'dart:async';

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
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}' ;
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
    // Since provider already extracts the clean message, use it directly
    return error;
  }

  IconData _getErrorIcon(String error) {
    if (_isNetworkError(error)) {
      return Icons.wifi_off;
    }
    return Icons.error_outline;
  }

  Future<void> _resendCode(BuildContext context) async {
    setState(() {
      _resending = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resendOtp(widget.phoneNumber.replaceFirst('+91', ''));
      
      // AuthProvider will handle the error display automatically
      
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
    
    // Validate OTP
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
      
      // AuthProvider will handle the error display automatically
      
      if (response != null && response.success == true) {
        if (response.profileComplete == false) {

        } else {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid OTP. Please check and try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Clear any previous errors when screen is built (only once)
        if (!_hasClearedErrors && authProvider.verifyOtpError != null) {
          _hasClearedErrors = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.clearError();
          });
        }
        
        // Remove timer start from build
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
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 20),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '$otpLength digit code',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Please enter $otpLength digit OTP verification code sent\nto "+widget.phoneNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_remainingSeconds != null)
                    Text(
                      _remainingSeconds! > 0
                          ? 'Expires in ${_formatDuration(_remainingSeconds!)}'
                          : 'OTP expired',
                      style: TextStyle(
                        color: _remainingSeconds! > 0 ? Colors.black54 : Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(otpLength, (i) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        width: 48,
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
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            onChanged: (value) => _onChanged(value, i),
                            onSubmitted: (value) => _closeKeyboard(),
                            textInputAction: i == otpLength - 1 ? TextInputAction.done : TextInputAction.next,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      const Text(
                        "Having trouble?",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: (_remainingSeconds ?? 0) > 0 || _resending ? null : () => _resendCode(context),
                        child: _resending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                "Resend code",
                                style: TextStyle(
                                  color: (_remainingSeconds ?? 0) > 0 ? Colors.grey : Colors.blue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                      ),
                    ],
                  ),
                  if (authProvider.verifyOtpError != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getErrorIcon(authProvider.verifyOtpError!),
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getErrorMessage(authProvider.verifyOtpError!),
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (authProvider.isLoading || _submitted || !_isOtpValid)
                          ? null
                          : () => _submitOtp(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (authProvider.isLoading || _submitted || !_isOtpValid) 
                          ? Colors.grey 
                          : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: authProvider.isLoading || _submitted
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Verify OTP'),
                    ),
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