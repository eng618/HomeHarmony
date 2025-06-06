import 'package:cloud_firestore/cloud_firestore.dart';

class Consequence {
  final String id;
  final String title;
  final String description;
  final int deductionMinutes;
  final List<String> assignedChildren;
  final List<String> linkedRules;
  final Timestamp? appliedAt;
  final String? appliedTo;
  final Timestamp? createdAt;
  final String? createdBy;

  Consequence({
    required this.id,
    required this.title,
    required this.description,
    required this.deductionMinutes,
    required this.assignedChildren,
    required this.linkedRules,
    this.appliedAt,
    this.appliedTo,
    this.createdAt,
    this.createdBy,
  });

  factory Consequence.fromFirestore(String id, Map<String, dynamic> data) {
    // Log a warning if required timestamp fields are missing
    if (data['created_at'] == null) {
      print(
        '[WARNING] Consequence.fromFirestore: Missing created_at for consequence id: $id',
      );
    }
    if (data['created_by'] == null) {
      print(
        '[WARNING] Consequence.fromFirestore: Missing created_by for consequence id: $id',
      );
    }
    return Consequence(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      deductionMinutes: data['deduction_minutes'] ?? 0,
      assignedChildren: List<String>.from(data['assigned_children'] ?? []),
      linkedRules: List<String>.from(data['linked_rules'] ?? []),
      appliedAt: data['applied_at'],
      appliedTo: data['applied_to'],
      createdAt: data['created_at'],
      createdBy: data['created_by'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'description': description,
    'deduction_minutes': deductionMinutes,
    'assigned_children': assignedChildren,
    'linked_rules': linkedRules,
    'applied_at': appliedAt,
    'applied_to': appliedTo,
    'created_at': createdAt,
    'created_by': createdBy,
  };
}
