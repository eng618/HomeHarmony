import 'package:flutter/material.dart';
import 'package:home_harmony/views/screen_time_view.dart';

/// ScreenTimeScreen is a top-level route that hosts the ScreenTimeView.
/// It passes the required familyId and childId to the view.
class ScreenTimeScreen extends StatelessWidget {
  /// The family ID for Firestore queries.
  final String familyId;

  /// The child ID for Firestore queries.
  final String childId;

  /// Creates a [ScreenTimeScreen] for the given family and child.
  const ScreenTimeScreen({
    super.key,
    required this.familyId,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenTimeView(familyId: familyId, childId: childId);
  }
}
