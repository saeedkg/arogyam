import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../_shared/ui/app_text.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.local_hospital,
            title: 'Hospital\nAppointment',
            color: const Color(0xFF4DB6AC), // Teal
            bgColor: const Color(0xFF4DB6AC).withOpacity(0.15),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.video_call,
            title: 'Video\nConsult',
            color: const Color(0xFF7E57C2), // Deep purple
            bgColor: const Color(0xFF7E57C2).withOpacity(0.15),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.flash_on,
            title: 'Consult\nNow',
            color: const Color(0xFFFFB74D), // Soft orange/amber
            bgColor: const Color(0xFFFFB74D).withOpacity(0.18),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color bgColor;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          AppText.titleMedium(
            title,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
