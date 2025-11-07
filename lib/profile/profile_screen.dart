import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../_shared/ui/app_colors.dart';
import '../_shared/routing/app_navigation.dart';
import '../auth/provider/auth_provider.dart';
import 'controller/profile_controller.dart';



class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    Get.put(ProfileController());
    return Scaffold(
    //  backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Professional Header Section
            _buildHeaderSection(),
            const SizedBox(height: 24),

            // Professional Personal Info
            //_buildPersonalInfo(),
            const SizedBox(height: 20),

            // Health Insights
            _buildHealthInsights(),
            const SizedBox(height: 20),

            // Quick Actions
            _buildQuickActions(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final controller = Get.find<ProfileController>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Professional Avatar with Status
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.deepPurple.withOpacity(0.8), width: 2.5),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://i.pravatar.cc/300?img=25',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.sageGreen.withOpacity(0.1),
                      child: Icon(Icons.person, color: AppColors.deepPurple, size: 36),
                    ),
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.sageGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.check, color: Colors.white, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name with Professional Typography (from profile)
          Obx(() {
            final name = controller.profile.value?.name;
            return Text(
              name ?? '—',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            );
          }),

          const SizedBox(height: 4),

          // Subtitle: show phone from profile
          Obx(() {
            final phone = controller.profile.value?.mobile;
            return Text(
              phone ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline_rounded, color: AppColors.deepPurple, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildProfessionalInfoRow('Gender', 'Male'),
            const SizedBox(height: 16),
            _buildProfessionalInfoRow('Date of Birth', 'March 15, 1990'),
            const SizedBox(height: 16),
            _buildProfessionalInfoRow('Phone Number', '+1 (555) 123-4567'),
            const SizedBox(height: 16),
            _buildProfessionalInfoRow('Location', 'New York, NY'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthInsights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'Health Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard('Appointments', '12', AppColors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard('Prescriptions', '5', AppColors.roseDust),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard('Health Score', '92%', AppColors.sageGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildActionTile(context, 'Medical Records', Icons.medical_services_rounded, AppColors.teal),
            _buildDivider(),
            _buildActionTile(context, 'Health Profile', Icons.favorite_rounded, AppColors.roseDust),
            _buildDivider(),
            _buildActionTile(context, 'Appointments', Icons.calendar_today_rounded, AppColors.mediumSkyBlue),
            _buildDivider(),
            _buildActionTile(context, 'Payment & Insurance', Icons.payment_rounded, AppColors.sageGreen),
            _buildDivider(),
            _buildActionTile(context, 'Settings', Icons.settings_rounded, AppColors.peach),
            _buildDivider(),
            _buildActionTile(context, 'Help Center', Icons.help_rounded, AppColors.blueBell),
            _buildDivider(),
            _buildActionTile(context, 'Sign Out', Icons.logout_rounded, AppColors.deepPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade500),
      ),
      onTap: () {
        if (title == 'Sign Out') {
          _showSignOutDialog(context);
        }
      },
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              content: const Text(
                'Are you sure you want to sign out of your account?',
                style: TextStyle(fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          Navigator.of(ctx).pop();
                          
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (loadingCtx) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            // Call logout
                            final success = await authProvider.logout();
                            
                            // Close loading dialog
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (success || context.mounted) {
                              // Navigate to login screen
                              AppNavigation.offAllToRequestOtpScreen();
                            } else {
                              // Show error but still navigate
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      authProvider.error ?? 'Failed to logout. Please try again.',
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            // Close loading dialog
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                            // Even on error, navigate to login
                            AppNavigation.offAllToRequestOtpScreen();
                          }
                        },
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Sign Out',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}