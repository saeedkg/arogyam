import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/consultation/consultation_type.dart';
import '../../../care_discovery/ui/search_screen.dart';

class SearchSection extends StatelessWidget {
  final String? initialQuery;
  final String? searchType;
  final AppointmentType? preSelectedAppointmentType;
  
  const SearchSection({
    super.key,
    this.initialQuery,
    this.searchType,
    this.preSelectedAppointmentType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => SearchScreen(
          searchType: searchType ?? 'dashboard',
          initialQuery: initialQuery ?? '',
          preSelectedAppointmentType: preSelectedAppointmentType,
        ));
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            const Icon(
              Icons.search_rounded,
              color: Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Search for doctors or symptoms',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}