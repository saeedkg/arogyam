import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import '../_shared/ui/app_text.dart';
import '../_shared/ui/app_colors.dart';
import '../_shared/routing/routing.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final RxInt _current = 0.obs;

  final List<_OnboardData> _pages = const [
    _OnboardData(
      title: 'Find Trusted Doctors\nNear You',
      subtitle: 'Connect with certified healthcare professionals in your area for personalized medical care.',
      centerImage: 'https://i.pravatar.cc/300?img=32',
    ),
    _OnboardData(
      title: 'Book Appointments &\nVideo Consults',
      subtitle: 'Schedule in-person visits or virtual consultations with top specialists in minutes.',
      centerImage: 'https://i.pravatar.cc/300?img=55',
    ),
    _OnboardData(
      title: 'Secure Video\nConsultations',
      subtitle: 'Have private, secure video calls with doctors to discuss your health concerns.',
      centerImage: 'https://i.pravatar.cc/300?img=58',
    ),
  ];

  void _next() {
    if (_current.value < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    } else {
      AppNavigation.offAllToLanding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      if (_current.value == 0) {
                        Get.back<void>();
                      } else {
                        _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20,
                      color: AppColors.grey700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.offAllNamed('/landing'),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => _current.value = i,
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final data = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Illustration
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: _DoctorOrbitIllustration(centerImage: data.centerImage),
                          ),
                        ),

                        // Text Content
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                data.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                data.subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.grey600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicators and Button
            Column(
              children: [
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                        (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      width: _current.value == i ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _current.value == i ? AppColors.primaryGreen : AppColors.grey300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                )),

                const SizedBox(height: 32),

                Obx(() {
                  final progress = (_current.value + 1) / _pages.length;
                  return _NextButton(onPressed: _next, progress: progress);
                }),

                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String title;
  final String subtitle;
  final String centerImage;
  const _OnboardData({required this.title, required this.subtitle, required this.centerImage});
}

class _DoctorOrbitIllustration extends StatelessWidget {
  final List<String> _avatars = const [
    'https://i.pravatar.cc/150?img=66',
    'https://i.pravatar.cc/150?img=15',
    'https://i.pravatar.cc/150?img=25',
    'https://i.pravatar.cc/150?img=31',
    'https://i.pravatar.cc/150?img=45',
    'https://i.pravatar.cc/150?img=7',
  ];

  final String centerImage;

  const _DoctorOrbitIllustration({super.key, required this.centerImage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundLight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
          ),

          // Center Doctor
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                )
              ],
            ),
            child: ClipOval(
              child: Image.network(
                centerImage,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: AppColors.grey200,
                  child: Icon(Icons.person, color: Colors.grey.shade400, size: 40),
                ),
              ),
            ),
          ),

          // Orbiting Doctors
          ...List.generate(_avatars.length, (index) {
            final angle = (360 / _avatars.length) * index * math.pi / 180;
            final radius = 100.0;
            final x = radius * math.cos(angle);
            final y = radius * math.sin(angle);

            return Transform.translate(
              offset: Offset(x, y),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    _avatars[index],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double progress;
  const _NextButton({required this.onPressed, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress Circle
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              backgroundColor: AppColors.grey200,
            ),
          ),

          // Button
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.white, size: 24),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}