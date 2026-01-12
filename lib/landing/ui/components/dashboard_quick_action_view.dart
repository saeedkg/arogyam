import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/consultation/consultation_flow_manager.dart';
import '../../../_shared/consultation/consultation_type.dart';
import '../../../care_discovery/ui/care_discovery_screen.dart';
import '../../../instant_consultation/ui/instant_consult_screen.dart';

enum QuickActionType {
  hospitalAppointment,
  videoConsult,
  instantConsult,
}

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          _CircularQuickAction(
            icon: Icons.medical_services_rounded,
            title: 'All',
            color: AppColors.primaryBlue,
            onTap: () {
              Get.to(() => CareDiscoveryScreen(entry: 'All Services'));
            },
          ),
          _CircularQuickAction(
            icon: Icons.person_rounded,
            title: 'General\nPhysician',
            color: AppColors.successGreen,
            onTap: () {
              Get.to(() => CareDiscoveryScreen(
                entry: 'General Physician',
                preSelectedAppointmentType: AppointmentType.video,
              ));
            },
          ),
          _CircularQuickAction(
            icon: Icons.spa_rounded,
            title: 'Beauty',
            color: AppColors.roseDust,
            onTap: () {
              Get.to(() => CareDiscoveryScreen(entry: 'Beauty'));
            },
          ),
          _CircularQuickAction(
            icon: Icons.home_rounded,
            title: 'Decor',
            color: AppColors.warningOrange,
            onTap: () {
              Get.to(() => CareDiscoveryScreen(entry: 'Decor'));
            },
          ),
          _CircularQuickAction(
            icon: Icons.child_care_rounded,
            title: 'Kids',
            color: AppColors.peach,
            onTap: () {
              Get.to(() => CareDiscoveryScreen(entry: 'Kids'));
            },
          ),
          _CircularQuickAction(
            icon: Icons.card_giftcard_rounded,
            title: 'Gifts',
            color: AppColors.deepPurple,
            onTap: () {
              Get.to(() => CareDiscoveryScreen(entry: 'Gifts'));
            },
          ),
        ],
      ),
    );
  }
}

class _CircularQuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _CircularQuickAction({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}