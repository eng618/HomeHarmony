
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chore_model.dart';

class ChoreService {
  final FirebaseFirestore _firestore;
  ChoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Chore>> choresStream(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('chores')
        .orderBy('created_at', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Chore.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<Chore?> getChore(
    String familyId,
    String choreId,
  ) async {
    final doc = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('chores')
        .doc(choreId)
        .get();
    if (!doc.exists) return null;
    return Chore.fromFirestore(doc.id, doc.data()!);
  }

  Future<void> addChore(String familyId, Chore chore) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('chores')
        .add(chore.toFirestore());
  }

  Future<void> updateChore(
    String familyId,
    String choreId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('chores')
        .doc(choreId)
        .update(data);
  }

  Future<void> deleteChore(String familyId, String choreId) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('chores')
        .doc(choreId)
        .delete();
  }
}
