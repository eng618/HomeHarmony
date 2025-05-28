class UserModel {
  final String uid;
  final String email;
  final String role;
  final String? parent;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.parent,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'child',
      parent: data['parent'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'role': role, if (parent != null) 'parent': parent};
  }
}
