enum ParticipantEventType {
  join,
  leave,
  videoUpdate,
  audioUpdate,
}

class ParticipantEvent {
  final ParticipantEventType type;
  final String participantId;

  ParticipantEvent({
    required this.type,
    required this.participantId,
  });

  @override
  String toString() {
    return 'ParticipantEvent(type: $type, participantId: $participantId)';
  }
}
