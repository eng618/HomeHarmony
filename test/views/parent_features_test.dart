import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_harmony/views/chores_view.dart';
import 'package:home_harmony/views/consequences_view.dart';
import 'package:home_harmony/views/behavior/rules_view.dart';
import 'package:home_harmony/models/child_profile.dart';
import 'package:home_harmony/models/chore_model.dart';
import 'package:home_harmony/models/consequence_model.dart';
import 'package:home_harmony/models/rule_model.dart';
import 'package:home_harmony/services/chore_service.dart';
import 'package:home_harmony/services/consequence_service.dart';
import 'package:home_harmony/services/screen_time_service.dart';
import 'package:home_harmony/services/activity_log_service.dart';
import 'package:home_harmony/services/family_service.dart';
import 'package:home_harmony/utils/chore_providers.dart';
import 'package:home_harmony/utils/consequence_providers.dart';
import 'package:home_harmony/utils/screen_time_providers.dart';
import 'package:home_harmony/utils/activity_log_providers.dart';
import 'package:home_harmony/utils/family_providers.dart';

class MockChoreService extends Mock implements ChoreService {}
class MockConsequenceService extends Mock implements ConsequenceService {}
class MockScreenTimeService extends Mock implements ScreenTimeService {}
class MockActivityLogService extends Mock implements ActivityLogService {}
class MockFamilyService extends Mock implements FamilyService {}
class MockUser extends Mock implements User {}

void main() {
  late MockChoreService mockChoreService;
  late MockConsequenceService mockConsequenceService;
  late MockScreenTimeService mockScreenTimeService;
  late MockActivityLogService mockActivityLogService;
  late MockFamilyService mockFamilyService;
  late MockUser mockUser;

  setUp(() {
    mockChoreService = MockChoreService();
    mockConsequenceService = MockConsequenceService();
    mockScreenTimeService = MockScreenTimeService();
    mockActivityLogService = MockActivityLogService();
    mockFamilyService = MockFamilyService();
    mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('parent1');
    when(() => mockUser.email).thenReturn('test@test.com');
  });

  final children = [
    ChildProfile(
      id: 'child1',
      name: 'Alice',
      age: 10,
      profileType: 'local',
      parentId: 'parent1',
    ),
  ];

  testWidgets('Parent can view and add chores', (tester) async {
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
            body: ChoresView(
              familyId: 'parent1',
              children: children,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Chore'), findsOneWidget);
    expect(find.text('No chores added.'), findsOneWidget);

    await tester.tap(find.text('Add Chore'));
    await tester.pumpAndSettle();

    expect(find.text('Add Chore'), findsNWidgets(2)); // Button and Dialog Title
    expect(find.byType(TextField), findsNWidgets(3)); // Title, Description, Value
  });

  testWidgets('Parent can view and add consequences', (tester) async {
    when(() => mockConsequenceService.consequencesStream(any())).thenAnswer(
      (_) => Stream.value([]),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          consequenceServiceProvider.overrideWithValue(mockConsequenceService),
          screenTimeServiceProvider.overrideWithValue(mockScreenTimeService),
          activityLogServiceProvider.overrideWithValue(mockActivityLogService),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ConsequencesView(
              familyId: 'parent1',
              children: children,
              rules: [],
              onAdd: () {}, // Mock callback
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Consequence'), findsOneWidget);
    expect(find.text('No consequences added.'), findsOneWidget);
  });

  testWidgets('Parent can view and add rules', (tester) async {
    when(() => mockFamilyService.rulesStream(any())).thenAnswer(
      (_) => Stream.value([]),
    );
    when(() => mockFamilyService.getChildren(any())).thenAnswer(
      (_) async => [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          familyServiceProvider.overrideWithValue(mockFamilyService),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: RulesView(
              user: mockUser,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Rule'), findsOneWidget);
    expect(find.text('No rules added.'), findsOneWidget);

    await tester.tap(find.text('Add Rule'));
    await tester.pumpAndSettle();

    expect(find.text('Add Rule'), findsNWidgets(2)); // Button and Dialog Title
    expect(find.byType(TextField), findsNWidgets(2)); // Title, Description
  });
}
