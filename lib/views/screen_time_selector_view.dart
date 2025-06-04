import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/family_service.dart';
import '../models/child_profile.dart';
import '../models/screen_time_params.dart';
import '../utils/screen_time_providers.dart';
import 'screen_time_view.dart';

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
        final selectedChild = children.firstWhere(
          (c) => c.id == selectedChildId,
        );
        return Scaffold(
          appBar: AppBar(title: const Text('Screen Time')),
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
