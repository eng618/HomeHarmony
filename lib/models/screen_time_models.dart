import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';

/// Model representing the screen time bucket for a child.
/// Holds the total available screen time and the last update timestamp.
class ScreenTimeBucket {
  /// Total available screen time in minutes.
  final int totalMinutes;

  /// Timestamp of the last update to the bucket (nullable).
  final Timestamp? lastUpdated;

  /// Creates a [ScreenTimeBucket] instance.
  ScreenTimeBucket({required this.totalMinutes, this.lastUpdated});

  /// Creates a [ScreenTimeBucket] from a Firestore JSON map.
  factory ScreenTimeBucket.fromJson(Map<String, dynamic> json) {
    if (json['last_updated'] == null) {
      log.w('ScreenTimeBucket.fromJson: Missing last_updated');
    }
    return ScreenTimeBucket(
      totalMinutes: json['total_minutes'] ?? 0,
      lastUpdated: json['last_updated'],
    );
  }

  /// Converts the [ScreenTimeBucket] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
    'total_minutes': totalMinutes,
    'last_updated': lastUpdated,
  };
}

/// Model representing the active timer for a child's screen time session.
class ActiveTimer {
  /// Timestamp when the timer started (nullable).
  final Timestamp? startTime;

  /// Allocated time for the session in minutes.
  final int durationMinutes;

  /// Whether the timer is currently paused.
  final bool isPaused;

  /// Timestamp when the timer was paused (null if not paused).
  final Timestamp? pausedAt;

  /// Creates an [ActiveTimer] instance.
  ActiveTimer({
    this.startTime,
    required this.durationMinutes,
    required this.isPaused,
    this.pausedAt,
  });

  /// Creates an [ActiveTimer] from a Firestore JSON map.
  factory ActiveTimer.fromJson(Map<String, dynamic> json) {
    if (json['start_time'] == null) {
      log.w('ActiveTimer.fromJson: Missing start_time');
    }
    return ActiveTimer(
      startTime: json['start_time'],
      durationMinutes: json['duration_minutes'] ?? 0,
      isPaused: json['is_paused'] ?? false,
      pausedAt: json['paused_at'],
    );
  }

  /// Converts the [ActiveTimer] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
    'start_time': startTime,
    'duration_minutes': durationMinutes,
    'is_paused': isPaused,
    'paused_at': pausedAt,
  };
}

/// Model representing a screen time session for a child.
class ScreenTimeSession {
  /// Firestore document ID for the session.
  final String id;

  /// Timestamp when the session started (nullable).
  final Timestamp? startTime;

  /// Timestamp when the session ended (null if ongoing).
  final Timestamp? endTime;

  /// Duration of the session in minutes.
  final int durationMinutes;

  /// Reason for the session (e.g., 'reward', 'manual addition').
  final String reason;

  /// Creates a [ScreenTimeSession] instance.
  ScreenTimeSession({
    required this.id,
    this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.reason,
  });

  /// Creates a [ScreenTimeSession] from a Firestore JSON map and document ID.
  factory ScreenTimeSession.fromJson(String id, Map<String, dynamic> json) {
    if (json['start_time'] == null) {
      log.w(
        '[ScreenTimeSession.fromJson] Missing start_time for session id: $id',
      );
    }
    return ScreenTimeSession(
      id: id,
      startTime: json['start_time'],
      endTime: json['end_time'],
      durationMinutes: json['duration_minutes'] ?? 0,
      reason: json['reason'] ?? '',
    );
  }

  /// Converts the [ScreenTimeSession] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
    'start_time': startTime,
    'end_time': endTime,
    'duration_minutes': durationMinutes,
    'reason': reason,
  };
}
