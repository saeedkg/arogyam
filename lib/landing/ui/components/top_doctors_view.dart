import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../_shared/constants/network_config.dart';
import '../../../_shared/routing/app_navigation.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../entities/doctor.dart';

class TopDoctors extends StatelessWidget {
  final List<Doctor> doctors;
  const TopDoctors({required this.doctors});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 40; // Account for horizontal padding (20px each side)
    final crossAxisSpacing = 16.0;
    final itemWidth = (availableWidth - crossAxisSpacing) / 2; // 2 items per row
    
    // Calculate responsive dimensions
    final isSmallScreen = screenWidth < 350;
    final isMediumScreen = screenWidth >= 350 && screenWidth < 400;
    
    final imageSize = isSmallScreen ? 70.0 : (isMediumScreen ? 75.0 : 80.0);
    final topSectionHeight = isSmallScreen ? 110.0 : (isMediumScreen ? 115.0 : 120.0);
    final cardPadding = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final buttonHeight = isSmallScreen ? 28.0 : (isMediumScreen ? 30.0 : 32.0);
    final buttonFontSize = isSmallScreen ? 11.0 : (isMediumScreen ? 11.5 : 12.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Responsive staggered grid for doctors
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: List.generate(
            doctors.length > 4 ? 4 : doctors.length, // Show max 4 doctors
            (index) {
              final d = doctors[index];
              print(d.imageUrl);
              
              return StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: GestureDetector(
                  onTap: () => AppNavigation.toDoctorDetail(d.id.toString()),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 200, // Minimum height to prevent overflow
                      maxWidth: itemWidth,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top section with image and rating
                        Container(
                          height: topSectionHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryGreen.withOpacity(0.05),
                                AppColors.primaryGreen.withOpacity(0.02),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Doctor image - centered
                              Center(
                                child: Container(
                                  width: imageSize,
                                  height: imageSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryGreen.withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: d.imageUrl.isNotEmpty
                                        ? Image.network(
                                            d.imageUrl.startsWith('http') 
                                                ? d.imageUrl 
                                                : '${NetworkConfig.baseUrl}/${d.imageUrl}',
                                            fit: BoxFit.cover,
                                            width: imageSize,
                                            height: imageSize,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: imageSize,
                                              height: imageSize,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    AppColors.primaryGreen.withOpacity(0.2),
                                                    AppColors.primaryGreen.withOpacity(0.1),
                                                  ],
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.person_rounded,
                                                color: AppColors.primaryGreen,
                                                size: imageSize * 0.45,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: imageSize,
                                            height: imageSize,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppColors.primaryGreen.withOpacity(0.2),
                                                  AppColors.primaryGreen.withOpacity(0.1),
                                                ],
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.person_rounded,
                                              color: AppColors.primaryGreen,
                                              size: imageSize * 0.45,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              
                              // Rating badge - top right
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        size: 12,
                                        color: Colors.amber.shade600,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        d.rating.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Bottom section with info and button
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.all(cardPadding),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Doctor name
                                Text(
                                  d.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: isSmallScreen ? 15 : 16,
                                    color: Colors.black87,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 3 : 4),
                                
                                // Specialization
                                Text(
                                  d.specialization,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: isSmallScreen ? 12 : 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                
                                SizedBox(height: isSmallScreen ? 8 : 12),
                                
                                // View Profile button
                                Container(
                                  width: double.infinity,
                                  height: buttonHeight,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryGreen,
                                        AppColors.primaryGreen.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(buttonHeight / 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryGreen.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => AppNavigation.toDoctorDetail(d.id.toString()),
                                      borderRadius: BorderRadius.circular(buttonHeight / 2),
                                      child: Center(
                                        child: Text(
                                          'View Profile',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: buttonFontSize,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}