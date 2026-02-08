
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

final userProvider = StreamProvider<UserModel?>((ref) {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  return auth.authStateChanges().asyncMap((user) async {
    if (user == null) {
      return null;
    }
    final userDoc = await firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      return UserModel.fromMap(user.uid, userDoc.data()!);
    }

    // For backward compatibility with existing child accounts:
    // Try to find this user as a child in any family's children collection
    try {
      final querySnapshot = await firestore
          .collectionGroup('children')
          .where('auth_uid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final childData = querySnapshot.docs.first.data();
        final parentId = childData['parent_id'] as String;

        // Create the missing user document for this child
        await firestore.collection('users').doc(user.uid).set({
          'email': user.email ?? '',
          'role': 'child',
          'parent': parentId,
        });

        return UserModel(
          uid: user.uid,
          email: user.email ?? '',
          role: 'child',
          parent: parentId,
        );
      }
    } catch (e) {
      // Ignore errors during fallback
    }

    // If no user document exists and no child record found, return null
    return null;
  });
});
