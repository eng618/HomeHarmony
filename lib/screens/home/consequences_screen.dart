import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/family_service.dart';
import '../../models/child_profile.dart';
import '../../services/screen_time_service.dart';

class ConsequencesScreen extends ConsumerStatefulWidget {
  final User user;
  const ConsequencesScreen({super.key, required this.user});

  @override
  ConsumerState<ConsequencesScreen> createState() => _ConsequencesScreenState();
}

class _ConsequencesScreenState extends ConsumerState<ConsequencesScreen> {
  String? selectedChildId;
  final _minutesController = TextEditingController();
  bool _isSubmitting = false;
  String? _infoMessage;

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _submitConsequence() async {
    final minutes = int.tryParse(_minutesController.text.trim());
    if (selectedChildId == null || minutes == null || minutes <= 0) {
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
      await service.addRewardToBucket(
        familyId: widget.user.uid,
        childId: selectedChildId!,
        minutes: -minutes, // Remove time
        reason: 'manual_consequence',
      );
      setState(() {
        _infoMessage = 'Removed $minutes minutes from child.';
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
    final familyService = FamilyService();
    return Scaffold(
      appBar: AppBar(title: const Text('Consequences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Remove Screen Time (Consequence)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<ChildProfile>>(
              stream: familyService.childrenStream(widget.user.uid),
              builder: (context, snapshot) {
                final children = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  value: selectedChildId,
                  isExpanded: true,
                  hint: const Text('Select child'),
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
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutes to remove',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickRemoveButton(
                  label: '-15m',
                  minutes: 15,
                  onPressed: (childId) {
                    setState(() {
                      _minutesController.text = '15';
                    });
                    _submitConsequence();
                  },
                  selectedChildId: selectedChildId,
                  isSubmitting: _isSubmitting,
                ),
                _QuickRemoveButton(
                  label: '-30m',
                  minutes: 30,
                  onPressed: (childId) {
                    setState(() {
                      _minutesController.text = '30';
                    });
                    _submitConsequence();
                  },
                  selectedChildId: selectedChildId,
                  isSubmitting: _isSubmitting,
                ),
                _QuickRemoveButton(
                  label: '-1h',
                  minutes: 60,
                  onPressed: (childId) {
                    setState(() {
                      _minutesController.text = '60';
                    });
                    _submitConsequence();
                  },
                  selectedChildId: selectedChildId,
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
                    ? const Text('Removing...')
                    : const Text('Remove Time'),
                onPressed: _isSubmitting ? null : _submitConsequence,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _QuickRemoveButton extends StatelessWidget {
  final String label;
  final int minutes;
  final void Function(String? childId) onPressed;
  final String? selectedChildId;
  final bool isSubmitting;
  const _QuickRemoveButton({
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
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: Text(label),
    );
  }
}
