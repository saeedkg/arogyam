import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../_shared/ui/app_colors.dart';
import '../_shared/routing/app_navigation.dart';
import '../_shared/components/guest_mode_handler.dart';
import '../auth/user_management/service/auth_token_provider.dart';
import '../auth/provider/auth_provider.dart';
import 'controller/profile_controller.dart';



class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isGuestMode = false;
  bool _showGuestBanner = true;

  @override
  void initState() {
    super.initState();
    // Delete any existing ProfileController from previous session
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>(force: true);
      print('🔄 Deleted existing ProfileController');
    }
    // Create fresh ProfileController for current user
    Get.put(ProfileController());
    print('✅ Created fresh ProfileController');
    _checkGuestMode();
  }

  Future<void> _checkGuestMode() async {
    final authTokenProvider = AuthTokenProvider();
    final token = await authTokenProvider.getToken();
    setState(() {
      _isGuestMode = token == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Guest mode handling
    if (_isGuestMode) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          //backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        body: Column(
          children: [
            // Guest banner
            if (_showGuestBanner)
              GuestModeHandler.buildGuestBanner(
                onDismiss: () => setState(() => _showGuestBanner = false),
              ),
            
            // Guest empty state
            Expanded(
              child: GuestModeHandler.buildGuestEmptyState(
                title: 'Sign In to Access Profile',
                description: 'View your personal information, health insights, manage settings, and access your complete healthcare profile.',
                featureName: 'profile',
                icon: Icons.person_rounded,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
    //  backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Professional Header Section
            _buildHeaderSection(),
            const SizedBox(height: 24),

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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.teal,
            AppColors.teal.withValues(alpha: 0.9),
            AppColors.primaryGreen,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar with edit button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  // Modern Edit Button
                  Material(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () async {
                        final result = await AppNavigation.toEditProfileScreen();
                        if (result != null) {
                          controller.fetchProfile();
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                            const SizedBox(width: 6),
                            const Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Avatar with Edit Button
            GestureDetector(
              onTap: () => _showPhotoOptions(controller),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Obx(() {
                    final profileImage = controller.profile.value?.profileImage;
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: profileImage != null && profileImage.isNotEmpty
                            ? Image.network(
                                profileImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.white,
                                  child: Icon(Icons.person, color: AppColors.primaryGreen, size: 40),
                                ),
                              )
                            : Container(
                                color: Colors.white,
                                child: Icon(Icons.person, color: AppColors.primaryGreen, size: 40),
                              ),
                      ),
                    );
                  }),
                  // Edit Photo Button
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Name
            Obx(() {
              final name = controller.profile.value?.name;
              return Text(
                name ?? '—',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              );
            }),

            const SizedBox(height: 6),

            // Phone
            Obx(() {
              final phone = controller.profile.value?.phone;
              return Text(
                phone ?? '',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
            
            const SizedBox(height: 24),
          ],
        ),
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
            _buildActionTile(context, 'Family Members', Icons.family_restroom_rounded, AppColors.deepPurple),
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
      onTap: () async {
        if (title == 'Sign Out') {
          _showSignOutDialog(context);
        } else if (title == 'Family Members') {
          AppNavigation.toFamilyMembersListScreen();
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

  void _showPhotoOptions(ProfileController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Update Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.primaryGreen),
                ),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(controller, isCamera: true);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.photo_library_rounded, color: AppColors.teal),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(controller, isCamera: false);
                },
              ),
              if (controller.profile.value?.profileImage != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto(controller);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ProfileController controller, {required bool isCamera}) async {
    // TODO: Implement image picker
    // For now, show a message that this feature is coming soon
    Get.snackbar(
      'Coming Soon',
      'Photo upload feature will be available soon',
      backgroundColor: AppColors.primaryGreen,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.info_rounded, color: Colors.white),
    );
  }

  Future<void> _removePhoto(ProfileController controller) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Remove Photo?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to remove your profile photo?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Remove',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement photo removal API call
      Get.snackbar(
        'Coming Soon',
        'Photo removal feature will be available soon',
        backgroundColor: AppColors.primaryGreen,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.info_rounded, color: Colors.white),
      );
    }
  }
}