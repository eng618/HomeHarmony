
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
    return null;
  });
});
