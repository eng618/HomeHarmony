import 'package:equatable/equatable.dart';

class ScreenTimeParams extends Equatable {
  final String familyId;
  final String childId;

  const ScreenTimeParams({required this.familyId, required this.childId});

  @override
  List<Object> get props => [familyId, childId];
}
