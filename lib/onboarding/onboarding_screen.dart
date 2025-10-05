import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import '../_shared/ui/app_text.dart';

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
      title: 'Discover the Most Exemplary Doctors\nin Your Area',
      subtitle: 'Dynamically empower pandemic scenarios rather than wireless deliverables redefine ethical data before seamless web services.',
      centerImage: 'https://i.pravatar.cc/300?img=32',
    ),
    _OnboardData(
      title: 'Book appointments and video consults\nwith top specialists',
      subtitle: 'Find the right doctor by specialization and availability, then book in minutes from your phone.',
      centerImage: 'https://i.pravatar.cc/300?img=55',
    ),
    _OnboardData(
      title: 'A doctor–patient video talk about\nseveral health issues',
      subtitle: 'Dynamically empower pandemic scenarios rather than wireless deliverables redefine ethical data before seamless web services.',
      centerImage: 'https://i.pravatar.cc/300?img=58',
    ),
  ];

  void _next() {
    if (_current.value < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Get.offAllNamed('/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      if (_current.value == 0) {
                        Get.back<void>();
                      } else {
                        _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.offAllNamed('/landing'),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => _current.value = i,
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final data = _pages[i];
                  return Column(
                    children: [
                      const SizedBox(height: 8),
                      Expanded(
                        child: Center(
                          child: _DoctorOrbitIllustration(centerImage: data.centerImage),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppText.titleLarge(
                              data.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            AppText.bodySmall(
                              data.subtitle,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: _current.value == i ? 18 : 6,
                      decoration: BoxDecoration(
                        color: _current.value == i ? Colors.teal : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )),

            const SizedBox(height: 16),
            Obx(() {
              final progress = (_current.value + 1) / _pages.length;
              return _NextButton(onPressed: _next, progress: progress);
            }),
            const SizedBox(height: 16),
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
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16)],
            ),
          ),
          _avatar(url: centerImage, size: 120),
          // orbit rings
          _ring(260),
          _ring(200),
          // orbiting small avatars
          _orbitingAvatar(_avatars[0], 140, 0),
          _orbitingAvatar(_avatars[1], 140, 60),
          _orbitingAvatar(_avatars[2], 140, 120),
          _orbitingAvatar(_avatars[3], 140, 180),
          _orbitingAvatar(_avatars[4], 140, 240),
          _orbitingAvatar(_avatars[5], 140, 300),
        ],
      ),
    );
  }

  Widget _ring(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE6EEFA), width: 2),
        ),
      );

  Widget _avatar({required String url, required double size}) => ClipOval(
        child: Image.network(url, width: size, height: size, fit: BoxFit.cover),
      );

  Widget _orbitingAvatar(String url, double radius, double angle) {
    final radians = angle * math.pi / 180.0;
    final x = radius * math.cos(radians);
    final y = radius * math.sin(radians);
    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)
        ]),
        padding: const EdgeInsets.all(4),
        child: _avatar(url: url, size: 48),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double progress; // 0..1
  const _NextButton({required this.onPressed, this.progress = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent.shade400),
              backgroundColor: Colors.teal.withOpacity(0.15),
            ),
          ),
          FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: const Color(0xFF22C58B),
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

