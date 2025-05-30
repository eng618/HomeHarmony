class Reward {
  final String id;
  final String title;
  final String description;
  final int value;
  final List<String> children;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.value,
    required this.children,
  });

  factory Reward.fromMap(String id, Map<String, dynamic> data) {
    return Reward(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      value: data['value'] ?? 0,
      children: List<String>.from(data['children'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'value': value,
      'children': children,
    };
  }
}
