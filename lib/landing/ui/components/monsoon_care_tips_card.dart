import 'package:flutter/material.dart';
import 'dart:async';
import '../../../_shared/ui/app_colors.dart';

class MonsoonCareTipsCard extends StatefulWidget {
  const MonsoonCareTipsCard({super.key});

  @override
  State<MonsoonCareTipsCard> createState() => _MonsoonCareTipsCardState();
}

class _MonsoonCareTipsCardState extends State<MonsoonCareTipsCard> {
  late PageController _pageController;
  late Timer _timer;
  int _currentIndex = 0;

  final List<Map<String, String>> _tips = [
    {
      'title': 'Monsoon Care Tips',
      'description': 'Stay healthy during monsoon with proper hygiene and nutrition',
      'image': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400',
    },
    {
      'title': 'Immunity Boosters',
      'description': 'Boost your immunity with vitamin C rich foods and exercise',
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
    },
    {
      'title': 'Hydration Tips',
      'description': 'Keep yourself hydrated with clean water and healthy drinks',
      'image': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
    },
    {
      'title': 'Mental Wellness',
      'description': 'Take care of your mental health with meditation and rest',
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        _currentIndex = (_currentIndex + 1) % _tips.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to tips detail
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: _tips.length,
          itemBuilder: (context, index) {
            final tip = _tips[index];
            return Row(
              children: [
                // Circular image section
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen.withOpacity(0.1),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        tip['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.health_and_safety_rounded,
                              color: AppColors.primaryGreen,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Content section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tip['title']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tip['description']!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                // Indicator dots and arrow
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Page indicators
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_tips.length, (dotIndex) {
                          return Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: dotIndex == _currentIndex
                                  ? AppColors.primaryGreen
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      // Arrow icon
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
