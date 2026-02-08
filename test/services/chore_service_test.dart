
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:home_harmony/models/chore_model.dart';
import 'package:home_harmony/services/chore_service.dart';
import 'package:home_harmony/services/activity_log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:home_harmony/models/activity_log_model.dart';

class MockActivityLogService extends Mock implements ActivityLogService {}
class FakeActivityLog extends Fake implements ActivityLog {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeActivityLog());
  });

  group('ChoreService', () {
    late FakeFirebaseFirestore firestore;
    late ChoreService choreService;
    late MockActivityLogService mockActivityLogService;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      mockActivityLogService = MockActivityLogService();
      choreService = ChoreService(firestore: firestore, activityLogService: mockActivityLogService);
    });

    test('addChore should add a chore to firestore', () async {
      final chore = Chore(
        id: '',
        title: 'Test Chore',
        description: 'Test Description',
        value: 10,
        assignedChildren: ['child1'],
        createdBy: 'user1',
        createdAt: Timestamp.now(),
      );

      when(() => mockActivityLogService.addActivityLog(any())).thenAnswer((_) async => {});

      await choreService.addChore('family1', chore);

      final snapshot = await firestore.collection('families').doc('family1').collection('chores').get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['title'], 'Test Chore');
    });
  });
}
