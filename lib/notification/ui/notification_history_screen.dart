import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/notification_controller.dart';
import '../entities/notification_history_item.dart';
import '../utils/notification_router.dart';
import '../repository/notification_repository.dart';
import '../../_shared/ui/app_colors.dart';
import '../../network/services/arogyam_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> with SingleTickerProviderStateMixin {
  NotificationController? _controller;
  String? _selectedFilter;
  late TabController _tabController;

  final List<String> _filterTabs = [
    'All',
    'Appointments',
    'Messages',
    'Prescriptions',
    'Consultations',
  ];

  final Map<String, String?> _filterValues = {
    'All': null,
    'Appointments': 'appointment_reminder',
    'Messages': 'chat_message',
    'Prescriptions': 'prescription_ready',
    'Consultations': 'consultation_started',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterTabs.length, vsync: this);
    _initializeController();
  }

  void _initializeController() async {
    try {
      if (Get.isRegistered<NotificationController>()) {
        _controller = Get.find<NotificationController>();
      } else {
        // Initialize controller if not registered
        final prefs = await SharedPreferences.getInstance();
        final userRole = prefs.getString('user_role') ?? 'patient';
        final api = AROGYAMAPI();
        final repository = NotificationRepository(api, userRole);
        _controller = Get.put(NotificationController(repository), permanent: true);
      }
      
      if (mounted) {
        setState(() {});
        _loadHistory();
      }
    } catch (e) {
      print('Error initializing NotificationController: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    if (_controller == null) return;
    await _controller!.loadNotificationHistory();
  }

  Future<void> _onRefresh() async {
    await _loadHistory();
  }

  void _onTabChanged(int index) {
    if (_controller == null) return;
    
    final filterKey = _filterTabs[index];
    setState(() {
      _selectedFilter = _filterValues[filterKey];
    });
    _controller!.loadNotificationHistory(
      filters: _selectedFilter != null
          ? {'notification_type': _selectedFilter}
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar color to match gradient
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.grey50,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          // Custom App Bar with gradient and status bar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.teal,
                  AppColors.teal.withOpacity(0.9),
                  AppColors.primaryGreen,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifications',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Stay updated with your health',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_controller != null)
                          Obx(() {
                            final unreadCount = _controller!.notificationHistory
                                .where((n) => n.status != 'clicked')
                                .length;
                            if (unreadCount > 0) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$unreadCount new',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                      ],
                    ),
                  ),
                  // Filter Tabs
                  Container(
                    height: 48,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      onTap: _onTabChanged,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      tabAlignment: TabAlignment.start,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      dividerColor: Colors.transparent,
                      tabs: _filterTabs.map((tab) => Tab(text: tab)).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
            // Content
            Expanded(
              child: _controller == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Initializing notifications...',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Obx(() {
                      if (_controller!.isLoading.value) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGreen,
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading notifications...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.grey600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (_controller!.notificationHistory.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.primaryGreen,
                        child: ListView.builder(
                          itemCount: _controller!.notificationHistory.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final notification = _controller!.notificationHistory[index];
                            return _buildNotificationCard(notification);
                          },
                        ),
                      );
                    }),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: AppColors.grey400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.grey800,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == null
                ? 'You\'ll see all your notifications here'
                : 'No ${_filterTabs[_tabController.index].toLowerCase()} notifications',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationHistoryItem notification) {
    final isUnread = notification.status != 'clicked';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUnread 
            ? Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? AppColors.primaryGreen.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notification.notificationType, isUnread),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                color: AppColors.grey900,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isUnread)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey600,
                          height: 1.3,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: AppColors.grey500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(notification.sentAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildStatusChip(notification.status),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.grey400,
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String type, bool isUnread) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (type) {
      case 'appointment_reminder':
      case 'appointment_confirmed':
        icon = Icons.event_rounded;
        color = AppColors.primaryBlue;
        bgColor = AppColors.pendingBlue;
        break;
      case 'chat_message':
        icon = Icons.chat_bubble_rounded;
        color = AppColors.primaryGreen;
        bgColor = AppColors.confirmedGreen;
        break;
      case 'prescription_ready':
        icon = Icons.medication_rounded;
        color = AppColors.warningOrange;
        bgColor = AppColors.cancelledOrange;
        break;
      case 'consultation_started':
        icon = Icons.videocam_rounded;
        color = AppColors.infoBlue;
        bgColor = const Color(0xFFEDE7F6);
        break;
      case 'payment_success':
        icon = Icons.check_circle_rounded;
        color = AppColors.successGreen;
        bgColor = AppColors.confirmedGreen;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = AppColors.grey600;
        bgColor = AppColors.grey100;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: isUnread
            ? Border.all(color: color.withValues(alpha: 0.2), width: 1.5)
            : null,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'delivered':
        color = AppColors.successGreen;
        label = 'Delivered';
        icon = Icons.check_rounded;
        break;
      case 'clicked':
        color = AppColors.primaryBlue;
        label = 'Read';
        icon = Icons.done_all_rounded;
        break;
      case 'failed':
        color = AppColors.errorRed;
        label = 'Failed';
        icon = Icons.error_outline_rounded;
        break;
      default:
        color = AppColors.grey500;
        label = 'Sent';
        icon = Icons.send_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Pending';
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _handleNotificationTap(NotificationHistoryItem notification) {
    if (_controller == null) return;
    
    // Mark as clicked
    _controller!.markNotificationAsClicked(notification.id.toString());

    // Navigate based on notification type
    if (notification.data != null) {
      final message = RemoteMessage(
        data: notification.data!,
      );
      NotificationRouter.handleNotificationTap(message);
    }
  }
}
