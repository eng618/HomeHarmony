import 'package:flutter/material.dart';
import 'package:home_harmony/views/screen_time_selector_view.dart';

/// ScreenTimeScreen is a top-level route that hosts the ScreenTimeSelectorView.
/// It passes the required familyId and optionally an initialChildId to the selector view.
class ScreenTimeScreen extends StatelessWidget {
  /// The family ID for Firestore queries.
  final String familyId;
  final String? initialChildId;

  /// Creates a [ScreenTimeScreen] for the given family.
  const ScreenTimeScreen({
    super.key,
    required this.familyId,
    this.initialChildId,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenTimeSelectorView(
      familyId: familyId,
      initialChildId: initialChildId,
    );
  }
}
