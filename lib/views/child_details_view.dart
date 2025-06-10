import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_harmony/screens/screen_time_screen.dart';
import '../controllers/child_details_controller.dart';
import '../models/child_details.dart';

class ChildDetailsView extends ConsumerStatefulWidget {
  final String familyId;
  final String childId;

  const ChildDetailsView({
    super.key,
    required this.familyId,
    required this.childId,
  });

  @override
  ConsumerState<ChildDetailsView> createState() => _ChildDetailsViewState();
}

class _ChildDetailsViewState extends ConsumerState<ChildDetailsView> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(childDetailsControllerProvider.notifier)
          .loadChildDetails(widget.familyId, widget.childId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(childDetailsControllerProvider);
    final controller = ref.read(childDetailsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.details?.name ?? 'Child Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: 'Manage Screen Time',
            onPressed: state.details == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ScreenTimeScreen(
                          familyId: widget.familyId,
                          initialChildId: widget.childId,
                        ),
                      ),
                    );
                  },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            controller.loadChildDetails(widget.familyId, widget.childId),
        child: Builder(
          builder: (context) {
            if (state.isLoading && state.details == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null && state.details == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${state.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (state.details == null) {
              return const Center(child: Text('No child details found.'));
            }
            final details = state.details!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ProfileSection(details: details),
                const SizedBox(height: 24),
                _ExpandablePanel(
                  title: 'Assigned Rules',
                  icon: Icons.rule_folder_outlined,
                  children: details.assignedRules.isEmpty
                      ? [const ListTile(title: Text('No rules assigned.'))]
                      : details.assignedRules
                            .map((rule) => ListTile(title: Text(rule)))
                            .toList(),
                ),
                const SizedBox(height: 16),
                _ExpandablePanel(
                  title: 'Active Consequences',
                  icon: Icons.warning_amber_outlined,
                  children: details.activeConsequences.isEmpty
                      ? [const ListTile(title: Text('No active consequences.'))]
                      : details.activeConsequences
                            .map((c) => ListTile(title: Text(c)))
                            .toList(),
                ),
                const SizedBox(height: 16),
                _ExpandablePanel(
                  title: 'Screen Time Summary',
                  icon: Icons.hourglass_empty_outlined,
                  children: [ListTile(title: Text(details.screenTimeSummary))],
                ),
                if (details.deviceStatus != null) ...[
                  const SizedBox(height: 16),
                  _ExpandablePanel(
                    title: 'Device Status',
                    icon: Icons.devices_other_outlined,
                    children: [ListTile(title: Text(details.deviceStatus!))],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final ChildDetails details;
  const _ProfileSection({required this.details});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage:
                  details.profilePicture != null &&
                      details.profilePicture!.isNotEmpty
                  ? NetworkImage(details.profilePicture!)
                  : null,
              child:
                  details.profilePicture == null ||
                      details.profilePicture!.isEmpty
                  ? Text(
                      details.name.isNotEmpty
                          ? details.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('Age: ${details.age}'),
                  Text('Profile Type: ${details.profileType}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandablePanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  /// Creates an expandable panel with a title, icon, and child widgets.
  const _ExpandablePanel({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        initiallyExpanded: false, // All panels will be collapsed by default
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
