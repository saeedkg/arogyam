import 'dart:async';
import 'package:flutter/material.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/consultation/consultation_type.dart';
import '../search_screen.dart';

class EnhancedSearchBar extends StatefulWidget {
  final AppointmentType? preSelectedAppointmentType;

  const EnhancedSearchBar({
    super.key,
    this.preSelectedAppointmentType,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _displayedText = '';
  Timer? _rotationTimer;
  Timer? _typingTimer;
  int _charIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _iconPulseAnimation;

  final List<String> _searchTexts = [
    'doctors, specialists...',
    'by symptoms...',
    'specialties...',
    'health concerns...',
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

    _iconPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
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
          _displayedText =
              _searchTexts[_currentIndex].substring(0, _charIndex + 1);
          _charIndex++;
        });
      } else {
        timer.cancel();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(
              preSelectedAppointmentType: widget.preSelectedAppointmentType,
            ),
          ),
        );
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.grey300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated Search Icon
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: ScaleTransition(
                scale: _iconPulseAnimation,
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
            ),

            // Search Text with Typing Animation
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Search for ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _displayedText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey600,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Filter/Options Icon with subtle animation
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 8),
              child: ScaleTransition(
                scale: _iconPulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: AppColors.primaryGreen,
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
