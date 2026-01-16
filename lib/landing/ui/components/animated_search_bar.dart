import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../care_discovery/ui/search_screen.dart';

class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({super.key});

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _displayedText = '';
  Timer? _rotationTimer;
  Timer? _typingTimer;
  int _charIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _iconPulseAnimation;
  
  final List<String> _searchTexts = [
    'doctors, specialists...',
    'by symptoms...',
    'healthcare services...',
    'nearby clinics...',
    'appointments...',
  ];

  @override
  void initState() {
    super.initState();
    _setupPulseAnimation();
    _startTyping();
  }

  void _setupPulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Icon pulse animation (subtle)
    _iconPulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startTyping() {
    _typeCurrentText();
  }

  void _typeCurrentText() {
    _charIndex = 0;
    _displayedText = '';
    
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_charIndex < _searchTexts[_currentIndex].length) {
        setState(() {
          _displayedText = _searchTexts[_currentIndex].substring(0, _charIndex + 1);
          _charIndex++;
        });
      } else {
        timer.cancel();
        // Wait 2 seconds before moving to next text
        _rotationTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _currentIndex = (_currentIndex + 1) % _searchTexts.length;
            });
            _typeCurrentText();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _rotationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleVoiceSearch() {
    Get.snackbar(
      'Voice Search',
      'Voice search feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryGreen,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const SearchScreen());
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated search icon
            ScaleTransition(
              scale: _iconPulseAnimation,
              child: Icon(
                Icons.search_rounded,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Static "Search" + Typing animation text
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Search ',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _displayedText,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 10),
            
            // Voice search button
            GestureDetector(
              onTap: _handleVoiceSearch,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    color: AppColors.primaryGreen,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
