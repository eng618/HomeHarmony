
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chore_model.dart';

class ChoreState {
  final bool isLoading;
  final String? error;
  final Chore? chore;

  ChoreState({this.isLoading = false, this.error, this.chore});

  ChoreState copyWith({
    bool? isLoading,
    String? error,
    Chore? chore,
  }) {
    return ChoreState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      chore: chore ?? this.chore,
    );
  }
}

class ChoreController extends StateNotifier<ChoreState> {
  ChoreController() : super(ChoreState());

  // Add methods for adding, editing, and deleting chores here
}

final choreControllerProvider =
    StateNotifierProvider.autoDispose<
      ChoreController,
      ChoreState
    >((ref) {
      return ChoreController();
    });
