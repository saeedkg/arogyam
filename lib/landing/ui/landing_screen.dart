import 'package:arogyam/appointment/appointments_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import 'pages/dashboard_screen.dart';
import '../../profile/profile_screen.dart';
import '../../health_records/ui/health_records_screen.dart';
import '../../_shared/ui/app_colors.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  final _pages = const [
    HomePage(),
    AppointmentsScreen(),
    HealthRecordsScreen(),
    UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Get.put(HomeController());
  }

  Future<bool> _onWillPop() async {
    // Only handle back press on home tab (index 0)
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }

    final now = DateTime.now();
    const exitTimeLimit = Duration(seconds: 2);

    if (_lastBackPressed == null || now.difference(_lastBackPressed!) > exitTimeLimit) {
      _lastBackPressed = now;
      _showExitSnackBar();
      return false;
    }

    // Exit the app
    SystemNavigator.pop();
    return true;
  }

  void _showExitSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Press back again to exit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(

            child: Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(
                       // color: Color(0xFF4DB6AC),
                        color: AppColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      );
                    }
                    return const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    );
                  }),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                elevation: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                height: 80,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Icons.home_outlined,
                      color: _currentIndex == 0 ? const Color(0xFF4DB6AC) : Colors.grey,
                      size: 24,
                    ),
                    selectedIcon: Icon(
                      Icons.home,
                      color: const Color(0xFF4DB6AC),
                      size: 24,
                    ),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.calendar_today_outlined,
                      color: _currentIndex == 1 ? const Color(0xFF4DB6AC) : Colors.grey,
                      size: 24,
                    ),
                    selectedIcon: Icon(
                      Icons.calendar_today,
                      color: const Color(0xFF4DB6AC),
                      size: 24,
                    ),
                    label: 'Appointment',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.folder_outlined,
                      color: _currentIndex == 2 ? const Color(0xFF4DB6AC) : Colors.grey,
                      size: 24,
                    ),
                    selectedIcon: Icon(
                      Icons.folder,
                      color: const Color(0xFF4DB6AC),
                      size: 24,
                    ),
                    label: 'Records',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.person_outline,
                      color: _currentIndex == 3 ? const Color(0xFF4DB6AC) : Colors.grey,
                      size: 24,
                    ),
                    selectedIcon: Icon(
                      Icons.person,
                      color: const Color(0xFF4DB6AC),
                      size: 24,
                    ),
                    label: 'Profile',
                  ),
                ],
                onDestinationSelected: (i) => setState(() => _currentIndex = i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

