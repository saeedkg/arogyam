import 'package:flutter/material.dart';

/// Represents the state of a minimized video call
class MinimizedCallState {
  final bool isMinimized;
  final Offset position;
  final int durationSeconds;
  final bool isConnected;
  final bool isAudioMuted;
  final bool isVideoDisabled;

  const MinimizedCallState({
    required this.isMinimized,
    required this.position,
    required this.durationSeconds,
    required this.isConnected,
    required this.isAudioMuted,
    required this.isVideoDisabled,
  });

  /// Creates a copy of this state with the given fields replaced with new values
  MinimizedCallState copyWith({
    bool? isMinimized,
    Offset? position,
    int? durationSeconds,
    bool? isConnected,
    bool? isAudioMuted,
    bool? isVideoDisabled,
  }) {
    return MinimizedCallState(
      isMinimized: isMinimized ?? this.isMinimized,
      position: position ?? this.position,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isConnected: isConnected ?? this.isConnected,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isVideoDisabled: isVideoDisabled ?? this.isVideoDisabled,
    );
  }

  /// Formats the duration in MM:SS format with zero-padding
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Creates an initial state for a minimized call
  factory MinimizedCallState.initial() {
    return const MinimizedCallState(
      isMinimized: false,
      position: Offset.zero,
      durationSeconds: 0,
      isConnected: false,
      isAudioMuted: false,
      isVideoDisabled: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MinimizedCallState &&
        other.isMinimized == isMinimized &&
        other.position == position &&
        other.durationSeconds == durationSeconds &&
        other.isConnected == isConnected &&
        other.isAudioMuted == isAudioMuted &&
        other.isVideoDisabled == isVideoDisabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      isMinimized,
      position,
      durationSeconds,
      isConnected,
      isAudioMuted,
      isVideoDisabled,
    );
  }

  @override
  String toString() {
    return 'MinimizedCallState(isMinimized: $isMinimized, position: $position, '
        'duration: $formattedDuration, isConnected: $isConnected, '
        'isAudioMuted: $isAudioMuted, isVideoDisabled: $isVideoDisabled)';
  }
}
