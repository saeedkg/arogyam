import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

/// Banner widget for displaying foreground notifications
class ForegroundNotificationBanner extends StatefulWidget {
  final RemoteMessage message;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const ForegroundNotificationBanner({
    super.key,
    required this.message,
    this.onTap,
    this.onDismiss,
  });

  @override
  State<ForegroundNotificationBanner> createState() => _ForegroundNotificationBannerState();

  /// Show notification banner
  static void show(RemoteMessage message, {VoidCallback? onTap}) {
    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(
          message.notification?.title ?? 'Notification',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        messageText: Text(
          message.notification?.body ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        icon: const Icon(
          Icons.notifications,
          color: Colors.white,
          size: 28,
        ),
        backgroundColor: const Color(0xFF2196F3),
        duration: const Duration(seconds: 5),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: (_) {
          if (onTap != null) {
            onTap();
          }
        },
        snackPosition: SnackPosition.TOP,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _ForegroundNotificationBannerState extends State<ForegroundNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dismissible(
          key: Key(widget.message.messageId ?? DateTime.now().toString()),
          direction: DismissDirection.horizontal,
          onDismissed: (_) {
            if (widget.onDismiss != null) {
              widget.onDismiss!();
            }
          },
          child: GestureDetector(
            onTap: () {
              _dismiss();
              if (widget.onTap != null) {
                widget.onTap!();
              }
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message.notification?.title ?? 'Notification',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message.notification?.body ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _dismiss,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
