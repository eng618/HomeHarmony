
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:home_harmony/models/consequence_model.dart';
import 'package:home_harmony/services/consequence_service.dart';
import 'package:home_harmony/services/activity_log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

class MockActivityLogService extends Mock implements ActivityLogService {}

void main() {
  group('ConsequenceService', () {
    late FakeFirebaseFirestore firestore;
    late ConsequenceService consequenceService;
    late MockActivityLogService mockActivityLogService;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      mockActivityLogService = MockActivityLogService();
      consequenceService = ConsequenceService(firestore: firestore, activityLogService: mockActivityLogService);
    });

    test('addConsequence should add a consequence to firestore', () async {
      final consequence = Consequence(
        id: '',
        title: 'Test Consequence',
        description: 'Test Description',
        deductionMinutes: 10,
        assignedChildren: ['child1'],
        linkedRules: [],
        createdBy: 'user1',
        createdAt: Timestamp.now(),
      );

      when(() => mockActivityLogService.addActivityLog(any())).thenAnswer((_) async => {});

      await consequenceService.addConsequence('family1', consequence);

      final snapshot = await firestore.collection('families').doc('family1').collection('consequences').get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['title'], 'Test Consequence');
    });
  });
}
