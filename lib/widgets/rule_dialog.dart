import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ruleDialogErrorProvider = StateProvider<String?>((ref) => null);
final ruleDialogLoadingProvider = StateProvider<bool>((ref) => false);
final ruleDialogSelectedChildrenProvider = StateProvider<List<String>>(
  (ref) => [],
);

/// Dialog widget for adding or editing a rule.
class RuleDialog extends ConsumerStatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final List<String> initialAssignedChildren;
  final List<Map<String, dynamic>> children;
  final void Function(
    String title,
    String description,
    List<String> assignedChildren,
  )
  onSubmit;
  final VoidCallback onCancel;
  final bool isEdit;

  const RuleDialog({
    super.key,
    this.initialTitle,
    this.initialDescription,
    this.initialAssignedChildren = const [],
    required this.children,
    required this.onSubmit,
    required this.onCancel,
    this.isEdit = false,
  });

  @override
  ConsumerState<RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends ConsumerState<RuleDialog> {
  late TextEditingController titleController;
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle ?? '');
    descController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ruleDialogSelectedChildrenProvider.notifier).state =
          List<String>.from(widget.initialAssignedChildren);
      ref.read(ruleDialogErrorProvider.notifier).state = null;
      ref.read(ruleDialogLoadingProvider.notifier).state = false;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = ref.watch(ruleDialogErrorProvider);
    final loading = ref.watch(ruleDialogLoadingProvider);
    final selectedChildren = ref.watch(ruleDialogSelectedChildrenProvider);
    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit Rule' : 'Add Rule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                counterText: '${titleController.text.length}/50',
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
                counterText: '${descController.text.length}/200',
              ),
              minLines: 1,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Assign to:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (widget.children.length > 1)
                  Row(
                    children: [
                      Checkbox(
                        value:
                            selectedChildren.length == widget.children.length,
                        tristate: false,
                        onChanged: (checked) {
                          final notifier = ref.read(
                            ruleDialogSelectedChildrenProvider.notifier,
                          );
                          if (checked == true) {
                            notifier.state = widget.children
                                .map<String>((c) => c['id'] as String)
                                .toList();
                          } else {
                            notifier.state = [];
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      const Text('Select All'),
                    ],
                  ),
              ],
            ),
            ...widget.children.map(
              (child) => CheckboxListTile(
                value: selectedChildren.contains(child['id']),
                title: Text(child['name'] ?? 'No name'),
                subtitle: Text('Age: ${child['age'] ?? 'N/A'}'),
                onChanged: (checked) {
                  final notifier = ref.read(
                    ruleDialogSelectedChildrenProvider.notifier,
                  );
                  final current = List<String>.from(notifier.state);
                  if (checked == true) {
                    if (!current.contains(child['id'])) {
                      current.add(child['id']);
                    }
                  } else {
                    current.remove(child['id']);
                  }
                  notifier.state = current;
                },
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error, style: const TextStyle(color: Colors.red)),
            ],
            if (loading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: loading ? null : widget.onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () {
                  final title = titleController.text.trim();
                  final desc = descController.text.trim();
                  final assigned = List<String>.from(
                    ref.read(ruleDialogSelectedChildrenProvider),
                  );
                  if (title.isEmpty || assigned.isEmpty) {
                    ref.read(ruleDialogErrorProvider.notifier).state =
                        'Title and at least one child required.';
                    return;
                  }
                  ref.read(ruleDialogErrorProvider.notifier).state = null;
                  ref.read(ruleDialogLoadingProvider.notifier).state = true;
                  widget.onSubmit(title, desc, assigned);
                },
          child: Text(widget.isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
