import 'package:flutter/material.dart';
import '../ui/app_colors.dart';
import '../routing/app_navigation.dart';

class GuestModeHandler {
  /// Check if user is in guest mode (not authenticated)
  static Future<bool> isGuestMode() async {
    // TODO: Implement actual authentication check
    // For now, return false - replace with actual auth check
    return false;
  }

  /// Show professional guest mode prompt for protected features
  static void showGuestModePrompt(
    BuildContext context, {
    required String featureName,
    String? customMessage,
    VoidCallback? onSignIn,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GuestModePromptSheet(
        featureName: featureName,
        customMessage: customMessage,
        onSignIn: onSignIn,
      ),
    );
  }

  /// Create a professional empty state for guest users
  static Widget buildGuestEmptyState({
    required String title,
    required String description,
    required String featureName,
    IconData? icon,
    VoidCallback? onSignIn,
  }) {
    return Builder(
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.1),
                        AppColors.primaryGreen.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon ?? Icons.login_rounded,
                    size: 32,
                    color: AppColors.primaryBlue,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 10),
                
                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onSignIn ?? () => AppNavigation.offAllToRequestOtpScreen(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text(
                      'Sign In to Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Continue as Guest Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Continue Browsing',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Create a professional banner for guest users
  static Widget buildGuestBanner({
    VoidCallback? onSignIn,
    VoidCallback? onDismiss,
  }) {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGreen.withOpacity(0.1),
              AppColors.primaryBlue.withOpacity(0.1),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: AppColors.primaryGreen,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sign in for full access',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Access your appointments, records, and more',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onSignIn ?? () => AppNavigation.offAllToRequestOtpScreen(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 6),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.grey500,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GuestModePromptSheet extends StatelessWidget {
  final String featureName;
  final String? customMessage;
  final VoidCallback? onSignIn;

  const GuestModePromptSheet({
    super.key,
    required this.featureName,
    this.customMessage,
    this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.login_rounded,
                  color: AppColors.primaryGreen,
                  size: 32,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Sign In Required',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Message
              Text(
                customMessage ?? 
                'To access $featureName, please sign in to your account. This helps us provide personalized healthcare services.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.grey600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Sign In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onSignIn != null) {
                      onSignIn!();
                    } else {
                      AppNavigation.offAllToRequestOtpScreen();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.login_rounded, size: 20),
                  label: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Continue as Guest Button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}