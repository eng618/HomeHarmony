import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a child profile in a family.
class ChildProfile {
  /// Firestore document ID for the child.
  final String id;

  /// Child's name.
  final String name;

  /// Child's age.
  final int age;

  /// Timestamp when the profile was created.
  final Timestamp? createdAt;

  /// Profile type: 'local' (parent-managed) or 'full' (login-enabled).
  final String profileType;

  /// Firebase Auth UID for full accounts, null for local.
  final String? authUid;

  /// UID of parent who created the profile.
  final String parentId;

  /// Optional URL to Firebase Storage for profile picture.
  final String? profilePicture;

  ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.profileType,
    required this.parentId,
    this.authUid,
    this.createdAt,
    this.profilePicture,
  });

  /// Create a ChildProfile from Firestore data and document ID.
  factory ChildProfile.fromFirestore(String id, Map<String, dynamic> data) {
    return ChildProfile(
      id: id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      profileType: data['profile_type'] ?? 'local',
      authUid: data['auth_uid'],
      parentId: data['parent_id'] ?? '',
      createdAt: data['created_at'] ?? data['createdAt'],
      profilePicture: data['profile_picture'],
    );
  }

  /// Convert a ChildProfile to a Firestore map (without the ID).
  Map<String, dynamic> toFirestore() => {
    'name': name,
    'age': age,
    'profile_type': profileType,
    'auth_uid': authUid,
    'parent_id': parentId,
    'created_at': createdAt,
    'profile_picture': profilePicture,
  };
}
