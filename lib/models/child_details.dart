/// Model for child details data
class ChildDetails {
  final String id;
  final String name;
  final int age;
  final String profileType;
  final String? profilePicture;
  final List<String> assignedRules;
  final List<String> activeConsequences;
  final String screenTimeSummary;
  final String? deviceStatus; // e.g., "Online", "Offline", "Last seen..."

  ChildDetails({
    required this.id,
    required this.name,
    required this.age,
    required this.profileType,
    this.profilePicture,
    required this.assignedRules,
    required this.activeConsequences,
    required this.screenTimeSummary,
    this.deviceStatus,
  });
}
