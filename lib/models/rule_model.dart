import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a rule in the family system.
class Rule {
  /// Firestore document ID for the rule.
  final String id;

  /// Title of the rule.
  final String title;

  /// Description of the rule.
  final String description;

  /// Optional age range for the rule (e.g., {min: 8, max: 12}).
  final Map<String, dynamic>? ageRange;

  /// List of child IDs assigned to this rule.
  final List<String> assignedChildren;

  /// Timestamp when the rule was created.
  final Timestamp? createdAt;

  /// UID of the parent who created the rule.
  final String createdBy;

  Rule({
    required this.id,
    required this.title,
    required this.description,
    this.ageRange,
    required this.assignedChildren,
    this.createdAt,
    required this.createdBy,
  });

  /// Create a Rule from Firestore data and document ID.
  factory Rule.fromFirestore(String id, Map<String, dynamic> data) {
    return Rule(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ageRange: data['age_range'],
      assignedChildren: List<String>.from(data['assigned_children'] ?? []),
      createdAt: data['created_at'],
      createdBy: data['created_by'] ?? '',
    );
  }

  /// Convert a Rule to a Firestore map (without the ID).
  Map<String, dynamic> toFirestore() => {
    'title': title,
    'description': description,
    'age_range': ageRange,
    'assigned_children': assignedChildren,
    'created_at': createdAt,
    'created_by': createdBy,
  };
}
