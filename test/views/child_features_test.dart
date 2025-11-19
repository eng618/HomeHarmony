import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:home_harmony/views/child_chores_view.dart';
import 'package:home_harmony/views/consequences_view.dart';
import 'package:home_harmony/models/child_profile.dart';
import 'package:home_harmony/models/chore_model.dart';
import 'package:home_harmony/models/consequence_model.dart';
import 'package:home_harmony/services/chore_service.dart';
import 'package:home_harmony/services/consequence_service.dart';
import 'package:home_harmony/services/screen_time_service.dart';
import 'package:home_harmony/services/activity_log_service.dart';
import 'package:home_harmony/utils/chore_providers.dart';
import 'package:home_harmony/utils/consequence_providers.dart';
import 'package:home_harmony/utils/screen_time_providers.dart';
import 'package:home_harmony/utils/activity_log_providers.dart';

class MockChoreService extends Mock implements ChoreService {}
class MockConsequenceService extends Mock implements ConsequenceService {}
class MockScreenTimeService extends Mock implements ScreenTimeService {}
class MockActivityLogService extends Mock implements ActivityLogService {}

void main() {
  late MockChoreService mockChoreService;
  late MockConsequenceService mockConsequenceService;
  late MockScreenTimeService mockScreenTimeService;
  late MockActivityLogService mockActivityLogService;

  setUp(() {
    mockChoreService = MockChoreService();
    mockConsequenceService = MockConsequenceService();
    mockScreenTimeService = MockScreenTimeService();
    mockActivityLogService = MockActivityLogService();
  });

  final child = ChildProfile(
    id: 'child1',
    name: 'Alice',
    age: 10,
    profileType: 'local',
    parentId: 'parent1',
  );

  testWidgets('Child can view chores but cannot add', (tester) async {
    when(() => mockChoreService.choresStream(any())).thenAnswer(
      (_) => Stream.value([]),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          choreServiceProvider.overrideWithValue(mockChoreService),
          screenTimeServiceProvider.overrideWithValue(mockScreenTimeService),
          activityLogServiceProvider.overrideWithValue(mockActivityLogService),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ChildChoresView(
              familyId: 'parent1',
              childId: 'child1',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Chore'), findsNothing);
    // Depending on implementation, it might show "No chores assigned" or similar
    // But mainly we check that "Add Chore" is NOT present
  });


}
