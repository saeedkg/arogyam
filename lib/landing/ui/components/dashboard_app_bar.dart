import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({
    super.key,
    this.onNotificationPressed,
    this.location = 'Seattle, USA',
  });

  final VoidCallback? onNotificationPressed;
  final String location;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      title: Row(
        children: [
          // Location section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Row(
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
                ],
              ),
            ],
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