import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({
    super.key,
    this.onNotificationPressed,
    this.onLocationPressed,
    this.location = 'Seattle, USA',
  });

  final VoidCallback? onNotificationPressed;
  final VoidCallback? onLocationPressed;
  final String location;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      title: Row(
        children: [
          // Location section with dropdown
          GestureDetector(
            onTap: onLocationPressed,
            child: Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Colors.grey[600]),
              ],
            ),
          ),
          const Spacer(),
          // Notification icon
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
            ),
            child: IconButton(
              onPressed: onNotificationPressed ?? () {},
              icon: Icon(Icons.notifications_outlined,
                  color: Colors.grey[700],
                  size: 20),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }
}