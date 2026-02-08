
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  final String id;
  final Timestamp timestamp;
  final String userId;
  final String type;
  final String description;
  final String familyId;

  ActivityLog({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.type,
    required this.description,
    required this.familyId,
  });

  factory ActivityLog.fromFirestore(String id, Map<String, dynamic> data) {
    return ActivityLog(
      id: id,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      familyId: data['familyId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'timestamp': timestamp,
    'userId': userId,
    'type': type,
    'description': description,
    'familyId': familyId,
  };
}
