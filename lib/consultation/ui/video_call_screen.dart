import 'package:flutter/material.dart';
import 'package:dyte_uikit/dyte_uikit.dart';
import 'package:get/get.dart';
import '../service/dyte_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String doctorName;
  final String specialization;
  final String hospital;
  final String doctorImageUrl;

  const VideoCallScreen({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.hospital,
    required this.doctorImageUrl,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final DyteService _dyteService = DyteService();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Generate demo room and auth token
      final roomName = DyteService.generateRoomName();
      final authToken = DyteService.generateAuthToken(
        roomName: roomName,
        participantName: 'Patient',
      );

      final success = await _dyteService.initializeMeeting(
        authToken: authToken,
        roomName: roomName,
        participantName: 'Patient',
      );

      if (success) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to join the consultation';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error initializing call: $e';
      });
    }
  }

  @override
  void dispose() {
    _dyteService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingView()
            : _errorMessage.isNotEmpty
                ? _buildErrorView()
                : _buildCallView(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 20),
          Text(
            'Connecting to consultation...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'Connection Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _initializeCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
                ElevatedButton(
                  onPressed: _endCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('End Call'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallView() {
    if (_dyteService.meetingInfo == null) {
      return const Center(
        child: Text(
          'Meeting info not available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Use Dyte UI Kit for the meeting interface
    // final uiKit = DyteUIKit(
    //   meetingInfo: _dyteService.meetingInfo!,
    //   clientContext: context,
    // );

    final uikitInfo = DyteUIKitInfo(
      _dyteService.meetingInfo!,
      // Optional: Pass the DyteDesignTokens object to customize the UI
      designToken: DyteDesignTokens(
        colorToken: DyteColorToken(
          brandColor: Colors.purple,
          backgroundColor: Colors.black,
          textOnBackground: Colors.white,
          textOnBrand: Colors.white,
        ),
      ),
    );

    final uiKit = DyteUIKitBuilder.build(uiKitInfo: uikitInfo,
     // skipSetupScreen: true, // optional argument, to skip the setup screen, defaults to false
    );

    return uiKit;
  }

  void _endCall() {
    Get.back();
    
    // Show call ended dialog
    Get.snackbar(
      'Call Ended',
      'Your consultation has ended',
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
