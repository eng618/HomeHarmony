
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_profile.dart';

class ChoreForm extends ConsumerStatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final int? initialValue;
  final List<String> initialAssignedChildren;
  final List<ChildProfile> children;
  final bool isEdit;
  final void Function(
    String title,
    String description,
    int value,
    List<String> assignedChildren,
  )
  onSubmit;
  final VoidCallback onCancel;

  const ChoreForm({
    super.key,
    this.initialTitle,
    this.initialDescription,
    this.initialValue,
    this.initialAssignedChildren = const [],
    required this.children,
    required this.onSubmit,
    required this.onCancel,
    this.isEdit = false,
  });

  @override
  ConsumerState<ChoreForm> createState() => _ChoreFormState();
}

class _ChoreFormState extends ConsumerState<ChoreForm> {
  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController valueController;
  late List<String> selectedChildren;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle ?? '');
    descController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    valueController = TextEditingController(
      text: widget.initialValue?.toString() ?? '',
    );
    selectedChildren = List<String>.from(widget.initialAssignedChildren);
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit Chore' : 'Add Chore'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
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
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value (minutes)',
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
                value: selectedChildren.contains(child.id),
                title: Text(child.name),
                subtitle: Text('Age: ${child.age}'),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedChildren.add(child.id);
                    } else {
                      selectedChildren.remove(child.id);
                    }
                  });
                },
              ),
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
            final value =
                int.tryParse(valueController.text.trim()) ?? 0;
            if (title.isEmpty) {
              setState(() {
                errorMessage = 'Title is required.';
              });
              return;
            }
            if (value <= 0) {
              setState(() {
                errorMessage = 'Value must be greater than 0.';
              });
              return;
            }
            if (selectedChildren.isEmpty) {
              setState(() {
                errorMessage = 'Please assign at least one child.';
              });
              return;
            }
            setState(() {
              errorMessage = null;
            });
            widget.onSubmit(
              title,
              desc,
              value,
              selectedChildren,
            );
          },
          child: Text(widget.isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
