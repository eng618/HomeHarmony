import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_harmony/screens/home/screen_time_screen.dart';
import '../models/child_profile.dart';

/// View for displaying a list of children in a family and handling child profile actions.
class FamilyMembersView extends StatelessWidget {
  final String familyId;
  final void Function(BuildContext context)? onAddChildProfile;
  final void Function(BuildContext context)? onAddChildAccount;
  final void Function(BuildContext context, ChildProfile child)? onEditChild;
  final void Function(BuildContext context, String childId, String childName)?
  onDeleteChild;
  final void Function(String childId, String childName)? onSelectChild;

  const FamilyMembersView({
    super.key,
    required this.familyId,
    this.onAddChildProfile,
    this.onAddChildAccount,
    this.onEditChild,
    this.onDeleteChild,
    this.onSelectChild,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: onAddChildProfile != null
                ? () => onAddChildProfile!(context)
                : null,
            child: const Text('Add Child Profile'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onAddChildAccount != null
                ? () => onAddChildAccount!(context)
                : null,
            child: const Text('Add Child Account (email)'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Children:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('families')
                  .doc(familyId)
                  .collection('children')
                  .orderBy('created_at', descending: false)
                  .snapshots(),
              builder: (context, childSnapshot) {
                if (childSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final children = childSnapshot.data?.docs ?? [];
                if (children.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No children added.'),
                  );
                }
                return ListView.builder(
                  itemCount: children.length,
                  itemBuilder: (context, idx) {
                    final childDoc = children[idx];
                    final child = ChildProfile.fromFirestore(
                      childDoc.id,
                      childDoc.data(),
                    );
                    return ListTile(
                      leading:
                          child.profilePicture != null &&
                              child.profilePicture!.isNotEmpty
                          ? CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: ClipOval(
                                child: FadeInImage.assetNetwork(
                                  placeholder:
                                      'assets/logo.png', // Use your app logo or a default avatar asset
                                  image: child.profilePicture!,
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.child_care,
                                          size: 32,
                                          color: Colors.grey,
                                        );
                                      },
                                ),
                              ),
                            )
                          : const CircleAvatar(
                              child: Icon(
                                Icons.child_care,
                                size: 32,
                                color: Colors.grey,
                              ),
                            ),
                      title: Text(child.name),
                      subtitle: Text(
                        'Age: ${child.age}\nType: ${child.profileType}',
                      ),
                      onTap: onSelectChild != null
                          ? () => onSelectChild!(child.id, child.name)
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.timer),
                            tooltip: 'Screen Time',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ScreenTimeScreen(
                                    familyId:
                                        familyId, // familyId from FamilyMembersView
                                    initialChildId: child
                                        .id, // child.id from the current item
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                            onPressed: onEditChild != null
                                ? () => onEditChild!(context, child)
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete',
                            onPressed: onDeleteChild != null
                                ? () => onDeleteChild!(
                                    context,
                                    child.id,
                                    child.name,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
