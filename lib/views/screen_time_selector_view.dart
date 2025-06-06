import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/family_service.dart';
import '../models/child_profile.dart';
import 'screen_time_view.dart';
import '../utils/screen_time_providers.dart';
import '../models/screen_time_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScreenTimeSelectorView extends ConsumerStatefulWidget {
  final String familyId;
  final String? initialChildId;
  const ScreenTimeSelectorView({
    super.key,
    required this.familyId,
    this.initialChildId,
  });

  @override
  ConsumerState<ScreenTimeSelectorView> createState() =>
      _ScreenTimeSelectorViewState();
}

class _ScreenTimeSelectorViewState
    extends ConsumerState<ScreenTimeSelectorView> {
  String? selectedChildId;

  @override
  void initState() {
    super.initState();
    selectedChildId = widget.initialChildId;
  }

  @override
  Widget build(BuildContext context) {
    final familyService = FamilyService();
    return StreamBuilder<List<ChildProfile>>(
      stream: familyService.childrenStream(widget.familyId),
      builder: (context, snapshot) {
        final children = snapshot.data ?? [];
        if (children.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No children found in this family.')),
          );
        }
        // If no child is selected, default to the first child
        selectedChildId ??= children.first.id;
        return Scaffold(
          appBar: AppBar(title: const Text('Screen Time')),
          floatingActionButton: selectedChildId == null
              ? null
              : FloatingActionButton.extended(
                  icon: const Icon(Icons.add_card), // Changed icon for clarity
                  label: const Text('Initialize Bucket'),
                  tooltip: 'Create or reset screen time bucket to 0',
                  onPressed: () async {
                    final service = ref.read(screenTimeServiceProvider);
                    await service.updateBucket(
                      familyId: widget.familyId,
                      childId: selectedChildId!,
                      bucket: ScreenTimeBucket(
                        totalMinutes: 0,
                        lastUpdated: Timestamp.now(),
                      ),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Screen time bucket initialized!'),
                      ),
                    );
                  },
                ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButton<String>(
                  value: selectedChildId,
                  isExpanded: true,
                  items: children
                      .map(
                        (child) => DropdownMenuItem(
                          value: child.id,
                          child: Text(child.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedChildId = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: ScreenTimeView(
                  familyId: widget.familyId,
                  childId: selectedChildId!,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
