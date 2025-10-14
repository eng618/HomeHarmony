import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/child_profile.dart';
import '../services/screen_time_service.dart';
import '../services/activity_log_service.dart';
import '../models/activity_log_model.dart';
import '../utils/activity_log_providers.dart';

/// View for manually deducting screen time from a child.
class ManualConsequenceView extends ConsumerStatefulWidget {
  final String familyId;
  final List<ChildProfile> children;
  const ManualConsequenceView({
    super.key,
    required this.familyId,
    required this.children,
  });

  @override
  ConsumerState<ManualConsequenceView> createState() =>
      _ManualConsequenceViewState();
}

class _ManualConsequenceViewState extends ConsumerState<ManualConsequenceView> {
  final _minutesController = TextEditingController();
  String? _selectedChildId;
  bool _isSubmitting = false;
  String? _infoMessage;

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _submitManualConsequence() async {
    final minutes = int.tryParse(_minutesController.text.trim());
    if (_selectedChildId == null || minutes == null || minutes <= 0) {
      setState(() {
        _infoMessage =
            'Please select a child and enter a valid number of minutes.';
      });
      return;
    }
    setState(() {
      _isSubmitting = true;
      _infoMessage = null;
    });
    try {
      final service = ScreenTimeService();
      await service.addScreenTime(
        familyId: widget.familyId,
        childId: _selectedChildId!,
        minutes: -minutes, // Negative to deduct
        reason: 'manual_consequence',
      );

      final activityLogService = ref.read(activityLogServiceProvider);
      final user = FirebaseAuth.instance.currentUser;
      final child = widget.children.firstWhere((c) => c.id == _selectedChildId);
      final log = ActivityLog(
        id: '',
        timestamp: Timestamp.now(),
        userId: user!.uid,
        type: 'consequence',
        description: 'Manually deducted $minutes minutes from ${child.name}.',
        familyId: widget.familyId,
      );
      await activityLogService.addActivityLog(log);

      setState(() {
        _infoMessage = 'Deducted $minutes minutes from child.';
        _minutesController.clear();
      });
    } catch (e) {
      setState(() {
        _infoMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manually Deduct Screen Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedChildId,
          isExpanded: true,
          hint: const Text('Select child'),
          items: widget.children
              .map(
                (child) =>
                    DropdownMenuItem(value: child.id, child: Text(child.name)),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedChildId = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _minutesController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutes to deduct',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickDeductButton(
              label: '-5m',
              minutes: 5,
              onPressed: (childId) {
                setState(() {
                  _minutesController.text = '5';
                });
                _submitManualConsequence();
              },
              selectedChildId: _selectedChildId,
              isSubmitting: _isSubmitting,
            ),
            _QuickDeductButton(
              label: '-15m',
              minutes: 15,
              onPressed: (childId) {
                setState(() {
                  _minutesController.text = '15';
                });
                _submitManualConsequence();
              },
              selectedChildId: _selectedChildId,
              isSubmitting: _isSubmitting,
            ),
            _QuickDeductButton(
              label: '-30m',
              minutes: 30,
              onPressed: (childId) {
                setState(() {
                  _minutesController.text = '30';
                });
                _submitManualConsequence();
              },
              selectedChildId: _selectedChildId,
              isSubmitting: _isSubmitting,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_infoMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(_infoMessage!, style: TextStyle(color: Colors.red)),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.remove),
            label: _isSubmitting
                ? const Text('Deducting...')
                : const Text('Deduct Time'),
            onPressed: _isSubmitting ? null : _submitManualConsequence,
          ),
        ),
      ],
    );
  }
}

class _QuickDeductButton extends StatelessWidget {
  final String label;
  final int minutes;
  final void Function(String? childId) onPressed;
  final String? selectedChildId;
  final bool isSubmitting;
  const _QuickDeductButton({
    required this.label,
    required this.minutes,
    required this.onPressed,
    required this.selectedChildId,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (selectedChildId != null && !isSubmitting)
          ? () => onPressed(selectedChildId)
          : null,
      child: Text(label),
    );
  }
}
