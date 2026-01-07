import 'package:flutter/material.dart';
import '../../_shared/routing/routing.dart';

class AppointmentEmptyStateCard extends StatelessWidget {
  const AppointmentEmptyStateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C58B).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration container with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF22C58B).withOpacity(0.1),
                    const Color(0xFF20BEE8).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 60,
                color: Color(0xFF22C58B),
              ),
            ),
            const SizedBox(height: 24),
            
            // Main heading
            const Text(
              'No Appointments Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            
            // Description text
            Text(
              'You haven\'t scheduled any appointments yet.\nStart your healthcare journey by booking\nyour first consultation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            
            // Action button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to care discovery or doctor search
                  AppNavigation.toCareDiscovery();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C58B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Secondary action
            TextButton(
              onPressed: () {
                // Navigate to instant consultation
                AppNavigation.toInstantConsult();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF20BEE8),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.video_call_rounded,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Instant Consultation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}