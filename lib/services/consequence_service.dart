import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/consequence_model.dart';

/// Service for managing consequences in Firestore for a family.
class ConsequenceService {
  final FirebaseFirestore _firestore;
  ConsequenceService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream all consequences for a family.
  Stream<List<Consequence>> consequencesStream(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('consequences')
        .orderBy('created_at', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Consequence.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Get a single consequence by ID.
  Future<Consequence?> getConsequence(
    String familyId,
    String consequenceId,
  ) async {
    final doc = await _firestore
        .collection('families')
        .doc(familyId)
        .collection('consequences')
        .doc(consequenceId)
        .get();
    if (!doc.exists) return null;
    return Consequence.fromFirestore(doc.id, doc.data()!);
  }

  /// Add a new consequence.
  Future<void> addConsequence(String familyId, Consequence consequence) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('consequences')
        .add(consequence.toFirestore());
  }

  /// Update an existing consequence.
  Future<void> updateConsequence(
    String familyId,
    String consequenceId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('consequences')
        .doc(consequenceId)
        .update(data);
  }

  /// Delete a consequence.
  Future<void> deleteConsequence(String familyId, String consequenceId) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('consequences')
        .doc(consequenceId)
        .delete();
  }
}
