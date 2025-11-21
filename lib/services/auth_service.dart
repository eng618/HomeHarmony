import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screen_time_service.dart';
import '../models/screen_time_models.dart';
import 'package:flutter/foundation.dart';
import '../utils/error_message_mapper.dart';

class AuthService {
  static FirebaseAuth? _authInstance;
  static FirebaseFirestore? _firestoreInstance;
  
  // Allow injection for testing
  static set authInstance(FirebaseAuth auth) => _authInstance = auth;
  static set firestoreInstance(FirebaseFirestore firestore) => _firestoreInstance = firestore;
  
  static FirebaseAuth get _auth => _authInstance ?? FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => _firestoreInstance ?? FirebaseFirestore.instance;

  static Future<String?> signIn(String email, String password) async {
    try {
      debugPrint('Attempting signIn for email: $email');
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('SignIn error: code=${e.code}, message=${e.message}, details=${e.toString()}');
      String errorMsg = e.message ?? e.code.replaceAll('-', ' ').replaceAll('.', '');
      return errorMsg;
    } catch (e) {
      debugPrint('SignIn generic error: $e');
      return e.toString();
    }
  }

  static Future<String?> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final parentUid = cred.user!.uid;
      // Create user profile in users collection (optional, for lookup)
      await _firestore.collection('users').doc(parentUid).set({
        'email': cred.user!.email,
        'role': 'parent',
      });
      // Create family document with parent_ids and created_at
      await _firestore
          .collection('families')
          .doc(parentUid)
          .set({
            'parent_ids': [parentUid],
            'created_at': FieldValue.serverTimestamp(),
          });
      return null;
    } on FirebaseAuthException catch (e) {
      return ErrorMessageMapper.mapError(e);
    }
  }

  static Future<String?> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user is currently signed in.';
      final uid = user.uid;
      // Delete user data from Firestore (customize as needed for your data model)
      await _firestore.collection('users').doc(uid).delete();
      // TODO: Delete other user-related data (e.g., children, rules, etc.)
      await user.delete();
      return null;
    } on FirebaseAuthException catch (e) {
      return ErrorMessageMapper.mapError(e);
    } catch (e) {
      return ErrorMessageMapper.catchError(e);
    }
  }

  /// Creates a child account (full login-enabled) and adds it to the parent's family/children collection.
  static Future<(String? uid, String? error)> createChildAccount({
    required String parentUid,
    required String parentEmail,
    required String childName,
    required int childAge,
    required String email,
    required String password,
    String? profilePicture,
  }) async {
    FirebaseApp? tempApp;
    try {
      // Initialize a secondary Firebase App to avoid signing out the parent
      tempApp = await Firebase.initializeApp(
        name: 'tempChildCreationApp',
        options: Firebase.app().options,
      );

      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      final cred = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final childUid = cred.user!.uid;

      // Create child profile in users collection for authentication
      // Use the main _firestore instance (parent's session) to write data
      await _firestore.collection('users').doc(childUid).set({
        'email': cred.user!.email,
        'role': 'child',
        'parent': parentUid,
      });

      // Add child profile under the parent's family/children collection
      await _firestore
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
          ScreenTimeService(firestore: _firestore);
      await screenTimeService.updateBucket(
        familyId: parentUid, // The familyId is the parent's UID
        childId:
            childUid, // The childId is the child's Auth UID, used as doc ID
        bucket: ScreenTimeBucket(
          totalMinutes: 0,
          lastUpdated: Timestamp.now(), // Use client time for initial creation
        ),
      );

      return (childUid, null);
    } on FirebaseAuthException catch (e) {
      return (null, e.message);
    } catch (e) {
      return (null, e.toString());
    } finally {
      // Clean up the temporary app
      await tempApp?.delete();
    }
  }


  /// Migrates data (chores, rules, consequences, screen time) from a local child profile to a new full account.
  static Future<void> migrateChildData({
    required String oldChildId,
    required String newChildId,
    required String familyId,
  }) async {
    final batch = _firestore.batch();

    // 1. Migrate Chores
    final choresSnap = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('chores')
        .where('assigned_children', arrayContains: oldChildId)
        .get();
    
    for (var doc in choresSnap.docs) {
      final data = doc.data();
      final List<dynamic> children = List.from(data['assigned_children'] ?? []);
      if (children.contains(oldChildId)) {
        children.remove(oldChildId);
        if (!children.contains(newChildId)) {
          children.add(newChildId);
        }
        batch.update(doc.reference, {'assigned_children': children});
      }
    }

    // 2. Migrate Rules
    final rulesSnap = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('rules')
        .where('assigned_children', arrayContains: oldChildId)
        .get();

    for (var doc in rulesSnap.docs) {
      final data = doc.data();
      final List<dynamic> children = List.from(data['assigned_children'] ?? []);
      if (children.contains(oldChildId)) {
        children.remove(oldChildId);
        if (!children.contains(newChildId)) {
          children.add(newChildId);
        }
        batch.update(doc.reference, {'assigned_children': children});
      }
    }

    // 3. Migrate Consequences
    final consequencesSnap = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('consequences')
        .where('assigned_children', arrayContains: oldChildId)
        .get();

    for (var doc in consequencesSnap.docs) {
      final data = doc.data();
      final List<dynamic> children = List.from(data['assigned_children'] ?? []);
      if (children.contains(oldChildId)) {
        children.remove(oldChildId);
        if (!children.contains(newChildId)) {
          children.add(newChildId);
        }
        batch.update(doc.reference, {'assigned_children': children});
      }
    }

    // 4. Migrate Screen Time Bucket
    final oldBucketRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('children')
        .doc(oldChildId)
        .collection('screen_time')
        .doc('bucket');
    
    final oldBucketSnap = await oldBucketRef.get();
    if (oldBucketSnap.exists) {
      final newBucketRef = _firestore
          .collection('families')
          .doc(familyId)
          .collection('children')
          .doc(newChildId)
          .collection('screen_time')
          .doc('bucket');
      
      batch.set(newBucketRef, oldBucketSnap.data()!);
    }

    await batch.commit();
  }
}
