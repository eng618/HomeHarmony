import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screen_time_service.dart';
import '../models/screen_time_models.dart';

class AuthService {
  static Future<String?> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  static Future<String?> signUp(String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final parentUid = cred.user!.uid;
      // Create user profile in users collection (optional, for lookup)
      await FirebaseFirestore.instance.collection('users').doc(parentUid).set({
        'email': cred.user!.email,
        'role': 'parent',
      });
      // Create family document with parent_ids and created_at
      await FirebaseFirestore.instance
          .collection('families')
          .doc(parentUid)
          .set({
            'parent_ids': [parentUid],
            'created_at': FieldValue.serverTimestamp(),
          });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  static Future<String?> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'No user is currently signed in.';
      final uid = user.uid;
      // Delete user data from Firestore (customize as needed for your data model)
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      // TODO: Delete other user-related data (e.g., children, rules, etc.)
      await user.delete();
      return null;
    } on FirebaseAuthException catch (e) {
      // If recent login is required, handle accordingly in the UI
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Creates a child account (full login-enabled) and adds it to the parent's family/children collection.
  static Future<String?> createChildAccount({
    required String parentUid,
    required String parentEmail,
    required String childName,
    required int childAge,
    required String email,
    required String password,
    String? profilePicture,
  }) async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final childUid = cred.user!.uid;
      // Add child profile under the parent's family/children collection
      await FirebaseFirestore.instance
          .collection('families')
          .doc(parentUid)
          .collection('children')
          .doc(childUid)
          .set({
            'name': childName,
            'age': childAge,
            'profile_type': 'full',
            'auth_uid': childUid,
            'parent_id': parentUid,
            'created_at': FieldValue.serverTimestamp(),
            'profile_picture': profilePicture,
          });

      // Initialize screen time bucket for the new child account
      final screenTimeService =
          ScreenTimeService(); // Uses default Firestore instance
      await screenTimeService.updateBucket(
        familyId: parentUid, // The familyId is the parent's UID
        childId:
            childUid, // The childId is the child's Auth UID, used as doc ID
        bucket: ScreenTimeBucket(
          totalMinutes: 0,
          lastUpdated: Timestamp.now(), // Use client time for initial creation
        ),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
