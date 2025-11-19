class VideoCallConfig {
  final String authToken;
  final String roomName;
  final String participantId;
  final String doctorName;
  final String specialization;
  final String doctorImageUrl;

  VideoCallConfig({
    required this.authToken,
    required this.roomName,
    required this.participantId,
    required this.doctorName,
    required this.specialization,
    required this.doctorImageUrl,
  });

  /// Validate that all required fields are present and non-empty
  bool isValid() {
    return authToken.isNotEmpty &&
        roomName.isNotEmpty &&
        participantId.isNotEmpty &&
        doctorName.isNotEmpty &&
        specialization.isNotEmpty &&
        doctorImageUrl.isNotEmpty;
  }

  /// Get validation error message if config is invalid
  String? getValidationError() {
    if (authToken.isEmpty) return 'Authentication token is missing';
    if (roomName.isEmpty) return 'Room name is missing';
    if (participantId.isEmpty) return 'Participant ID is missing';
    if (doctorName.isEmpty) return 'Doctor name is missing';
    if (specialization.isEmpty) return 'Specialization is missing';
    if (doctorImageUrl.isEmpty) return 'Doctor image URL is missing';
    return null;
  }
}
