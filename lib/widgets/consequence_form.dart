import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dialog/form for creating or editing a consequence, including rule linking.
class ConsequenceForm extends ConsumerStatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final int? initialDeductionMinutes;
  final List<String> initialAssignedChildren;
  final List<String> initialLinkedRules;
  final List<Map<String, dynamic>> children;
  final List<Map<String, dynamic>> rules;
  final bool isEdit;
  final void Function(
    String title,
    String description,
    int deductionMinutes,
    List<String> assignedChildren,
    List<String> linkedRules,
  )
  onSubmit;
  final VoidCallback onCancel;

  const ConsequenceForm({
    super.key,
    this.initialTitle,
    this.initialDescription,
    this.initialDeductionMinutes,
    this.initialAssignedChildren = const [],
    this.initialLinkedRules = const [],
    required this.children,
    required this.rules,
    required this.onSubmit,
    required this.onCancel,
    this.isEdit = false,
  });

  @override
  ConsumerState<ConsequenceForm> createState() => _ConsequenceFormState();
}

class _ConsequenceFormState extends ConsumerState<ConsequenceForm> {
  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController deductionController;
  late List<String> selectedChildren;
  late List<String> selectedRules;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle ?? '');
    descController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    deductionController = TextEditingController(
      text: widget.initialDeductionMinutes?.toString() ?? '',
    );
    selectedChildren = List<String>.from(widget.initialAssignedChildren);
    selectedRules = List<String>.from(widget.initialLinkedRules);
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    deductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Compute children inherited from selected rules
    final inheritedChildren = <String>{};
    for (final rule in widget.rules) {
      if (selectedRules.contains(rule['id'])) {
        final assigned = rule['assigned_children'] as List<dynamic>? ?? [];
        inheritedChildren.addAll(assigned.map((e) => e.toString()));
      }
    }
    // Merge selected children and inherited children
    final effectiveChildren = <String>{
      ...selectedChildren,
      ...inheritedChildren,
    };
    // Helper: get child name by id
    String childName(String id) =>
        widget.children.firstWhere(
          (c) => c['id'] == id,
          orElse: () => {'name': id},
        )['name'] ??
        id;
    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit Consequence' : 'Add Consequence'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              maxLength: 50,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              minLines: 1,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: deductionController,
              decoration: const InputDecoration(
                labelText: 'Deduction (minutes)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Assign to (children):',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ...widget.children.map(
              (child) => CheckboxListTile(
                value: selectedChildren.contains(child['id']),
                title: Text(child['name'] ?? 'No name'),
                subtitle: Text('Age: ${child['age'] ?? 'N/A'}'),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedChildren.add(child['id']);
                    } else {
                      selectedChildren.remove(child['id']);
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Link to Rules:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ...widget.rules.map(
              (rule) => CheckboxListTile(
                value: selectedRules.contains(rule['id']),
                title: Text(rule['title'] ?? 'No title'),
                subtitle: Text(rule['description'] ?? ''),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedRules.add(rule['id']);
                    } else {
                      selectedRules.remove(rule['id']);
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            if (selectedRules.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Children inherited from selected rules:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Wrap(
                    spacing: 8,
                    children: inheritedChildren.map((id) {
                      // Find which rules this child is inherited from
                      final ruleTitles = widget.rules
                          .where(
                            (rule) =>
                                selectedRules.contains(rule['id']) &&
                                (rule['assigned_children'] as List<dynamic>? ??
                                        [])
                                    .contains(id),
                          )
                          .map((rule) => rule['title'] ?? rule['id'])
                          .toSet();
                      final label = ruleTitles.isNotEmpty
                          ? '${childName(id)} (via ${ruleTitles.join(", ")})'
                          : childName(id);
                      return Chip(label: Text(label));
                    }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              'Consequences can be assigned directly to children, to rules, or both. If you link to rules, all children assigned to those rules will inherit this consequence.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final title = titleController.text.trim();
            final desc = descController.text.trim();
            final deduction =
                int.tryParse(deductionController.text.trim()) ?? 0;
            if (title.isEmpty || deduction <= 0 || effectiveChildren.isEmpty) {
              // TODO: Show error state
              return;
            }
            widget.onSubmit(
              title,
              desc,
              deduction,
              effectiveChildren.toList(),
              selectedRules,
            );
          },
          child: Text(widget.isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
