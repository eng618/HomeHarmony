import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      // Set default role to parent for new users
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({'email': cred.user!.email, 'role': 'parent'});
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
}
