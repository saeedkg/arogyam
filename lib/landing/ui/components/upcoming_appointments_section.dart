import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/utils/date_time_formatter.dart';
import '../../../_shared/routing/routing.dart';
import '../../../consultation_pending/ui/pending_consultation_screen.dart';
import '../../entities/dashboard_data.dart';

class UpcomingAppointmentsSection extends StatelessWidget {
  final List<UpcomingAppointment> appointments;

  const UpcomingAppointmentsSection({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink(); // Remove from main content
  }
}

// Expandable floating widget for bottom right corner
class FloatingAppointmentWidget extends StatefulWidget {
  final List<UpcomingAppointment> appointments;

  const FloatingAppointmentWidget({
    super.key,
    required this.appointments,
  });

  @override
  State<FloatingAppointmentWidget> createState() => _FloatingAppointmentWidgetState();
}

class _FloatingAppointmentWidgetState extends State<FloatingAppointmentWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _expandController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!_isExpanded) {
      // First tap: expand the widget
      setState(() {
        _isExpanded = true;
      });
      _expandController.forward();
      
      // Auto-collapse after 6 seconds for scrollable list
      Future.delayed(const Duration(seconds: 6), () {
        if (mounted && _isExpanded) {
          _handleCollapse();
        }
      });
    }
    // When expanded, tapping the main area does nothing - use close button instead
  }

  void _handleAppointmentTap(UpcomingAppointment appointment) {
    // Navigate to specific appointment detail
    Get.to(() => PendingConsultationScreen(
      appointmentId: appointment.id.toString()
    ));
  }

  void _handleCollapse() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
      });
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appointments.isEmpty) {
      return const SizedBox.shrink();
    }

    final mostUrgentAppointment = _getMostUrgentAppointment();
    final isToday = _isToday(mostUrgentAppointment.scheduledAt);
    final isUrgent = _isUrgent(mostUrgentAppointment.scheduledAt);
    
    // Get screen dimensions for safe positioning
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      bottom: _isExpanded ? (80 + bottomPadding) : 16, // Safe area + bottom nav padding
      right: 16, // Fixed right padding
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _expandAnimation, _fadeAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                width: _isExpanded ? (screenWidth - 32).clamp(260.0, 320.0) : 160, // Animated width transition
                constraints: BoxConstraints(
                  maxHeight: _isExpanded ? 
                    (screenHeight * 0.6).clamp(300.0, 450.0) : 200.0, // Use finite value instead of infinity
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getGradientColors(isToday, isUrgent),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getPrimaryColor(isToday, isUrgent).withOpacity(0.3),
                      blurRadius: _isExpanded ? 16 : 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.all(_isExpanded ? 14 : 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Compact header with close button when expanded
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                isToday ? 'Today' : 'Next',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _isExpanded ? 11 : 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (widget.appointments.length > 1 && !_isExpanded)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '+${widget.appointments.length - 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            // Close button when expanded
                            if (_isExpanded)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _handleCollapse,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Main appointment info
                        Row(
                          children: [
                            // Avatar
                            Container(
                              width: _isExpanded ? 32 : 24,
                              height: _isExpanded ? 32 : 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: _isExpanded ? 15 : 11,
                                backgroundImage: mostUrgentAppointment.doctorImage != null
                                    ? NetworkImage(mostUrgentAppointment.doctorImage!)
                                    : null,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: mostUrgentAppointment.doctorImage == null
                                    ? Icon(
                                        Icons.medical_services_rounded,
                                        color: Colors.white,
                                        size: _isExpanded ? 16 : 12,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time
                                  Text(
                                    _formatCompactTime(mostUrgentAppointment.scheduledAt, isToday),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: _isExpanded ? 12 : 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  
                                  // Doctor name
                                  Text(
                                    _isExpanded 
                                        ? 'Dr. ${mostUrgentAppointment.doctorName}'
                                        : _shortenDoctorName(mostUrgentAppointment.doctorName),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: _isExpanded ? 11 : 9,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Type icon
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                mostUrgentAppointment.type == 'online' 
                                    ? Icons.videocam_rounded 
                                    : Icons.local_hospital_rounded,
                                size: _isExpanded ? 12 : 10,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        
                        // Expanded content - Show all appointments in scrollable list
                        if (_isExpanded) ...[
                          const SizedBox(height: 10),
                          AnimatedOpacity(
                            opacity: _fadeAnimation.value,
                            duration: const Duration(milliseconds: 200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header for appointment list
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: Colors.white.withOpacity(0.8),
                                        size: 12,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${widget.appointments.length} Appointment${widget.appointments.length > 1 ? 's' : ''}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Scrollable appointment list
                                Container(
                                  constraints: BoxConstraints(
                                    maxHeight: (screenHeight * 0.35).clamp(200.0, 280.0), // Responsive max height
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: widget.appointments.map((appointment) {
                                        final isToday = _isToday(appointment.scheduledAt);
                                        final isUrgent = _isUrgent(appointment.scheduledAt);
                                        
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () => _handleAppointmentTap(appointment),
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.2),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Avatar
                                                    Container(
                                                      width: 28,
                                                      height: 28,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white.withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: CircleAvatar(
                                                        radius: 13,
                                                        backgroundImage: appointment.doctorImage != null
                                                            ? NetworkImage(appointment.doctorImage!)
                                                            : null,
                                                        backgroundColor: Colors.white.withOpacity(0.2),
                                                        child: appointment.doctorImage == null
                                                            ? Icon(
                                                                Icons.medical_services_rounded,
                                                                color: Colors.white,
                                                                size: 14,
                                                              )
                                                            : null,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    
                                                    // Appointment details
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // Time and urgency indicator
                                                          Row(
                                                            children: [
                                                              if (isUrgent)
                                                                Container(
                                                                  width: 6,
                                                                  height: 6,
                                                                  margin: const EdgeInsets.only(right: 4),
                                                                  decoration: const BoxDecoration(
                                                                    color: Colors.orange,
                                                                    shape: BoxShape.circle,
                                                                  ),
                                                                ),
                                                              Expanded(
                                                                child: Text(
                                                                  _formatCompactTime(appointment.scheduledAt, isToday),
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 2),
                                                          
                                                          // Doctor name
                                                          Text(
                                                            'Dr. ${appointment.doctorName}',
                                                            style: TextStyle(
                                                              color: Colors.white.withOpacity(0.9),
                                                              fontSize: 9,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          
                                                          // Patient info if not self
                                                          if (appointment.patientType != 'self')
                                                            Text(
                                                              'For ${appointment.patientName}',
                                                              style: TextStyle(
                                                                color: Colors.white.withOpacity(0.7),
                                                                fontSize: 8,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    
                                                    // Type and status icons
                                                    Column(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.all(3),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withOpacity(0.2),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Icon(
                                                            appointment.type == 'online' 
                                                                ? Icons.videocam_rounded 
                                                                : Icons.local_hospital_rounded,
                                                            size: 10,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withOpacity(0.15),
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          child: Text(
                                                            _getStatusText(appointment.status),
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 7,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  UpcomingAppointment _getMostUrgentAppointment() {
    final sortedAppointments = List<UpcomingAppointment>.from(widget.appointments);
    sortedAppointments.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    
    final now = DateTime.now();
    final todayAppointments = sortedAppointments.where((apt) {
      return apt.scheduledAt.year == now.year &&
             apt.scheduledAt.month == now.month &&
             apt.scheduledAt.day == now.day;
    }).toList();
    
    if (todayAppointments.isNotEmpty) {
      return todayAppointments.first;
    }
    
    return sortedAppointments.first;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  bool _isUrgent(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inHours <= 2 && difference.inHours >= 0;
  }

  List<Color> _getGradientColors(bool isToday, bool isUrgent) {
    if (isUrgent) {
      return [
        AppColors.warningOrange,
        AppColors.warningOrange.withOpacity(0.8),
      ];
    } else if (isToday) {
      return [
        AppColors.primaryGreen,
        AppColors.primaryGreen.withOpacity(0.85),
      ];
    } else {
      return [
        AppColors.primaryBlue,
        AppColors.primaryBlue.withOpacity(0.85),
      ];
    }
  }

  Color _getPrimaryColor(bool isToday, bool isUrgent) {
    if (isUrgent) return AppColors.warningOrange;
    if (isToday) return AppColors.primaryGreen;
    return AppColors.primaryBlue;
  }

  String _formatCompactTime(DateTime dateTime, bool isToday) {
    if (isToday) {
      return DateTimeFormatter.formatTime(dateTime);
    } else {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      
      if (dateTime.year == tomorrow.year &&
          dateTime.month == tomorrow.month &&
          dateTime.day == tomorrow.day) {
        return 'Tom ${DateTimeFormatter.formatTime(dateTime)}';
      }
      
      return DateTimeFormatter.formatTime(dateTime);
    }
  }

  String _shortenDoctorName(String fullName) {
    final words = fullName.split(' ');
    if (words.length > 1) {
      return 'Dr. ${words.first}';
    }
    return 'Dr. $fullName';
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
