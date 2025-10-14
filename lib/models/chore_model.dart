
import 'package:cloud_firestore/cloud_firestore.dart';

class Chore {
  final String id;
  final String title;
  final String description;
  final int value;
  final List<String> assignedChildren;
  final bool completed;
  final bool approved;
  final Timestamp? createdAt;
  final String createdBy;

  Chore({
    required this.id,
    required this.title,
    required this.description,
    required this.value,
    required this.assignedChildren,
    this.completed = false,
    this.approved = false,
    this.createdAt,
    required this.createdBy,
  });

  factory Chore.fromFirestore(String id, Map<String, dynamic> data) {
    return Chore(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      value: data['value'] ?? 0,
      assignedChildren: List<String>.from(data['assigned_children'] ?? []),
      completed: data['completed'] ?? false,
      approved: data['approved'] ?? false,
      createdAt: data['created_at'],
      createdBy: data['created_by'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'description': description,
    'value': value,
    'assigned_children': assignedChildren,
    'completed': completed,
    'approved': approved,
    'created_at': createdAt,
    'created_by': createdBy,
  };
}
