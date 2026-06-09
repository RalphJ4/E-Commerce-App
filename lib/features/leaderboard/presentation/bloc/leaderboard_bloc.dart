import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:shopease/features/leaderboard/domain/usecases/get_leaderboard_usecase.dart';
import 'package:shopease/features/leaderboard/presentation/bloc/leaderboard_event.dart';
import 'package:shopease/features/leaderboard/presentation/bloc/leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetLeaderboardUseCase getLeaderboardUseCase;

  LeaderboardBloc({
    required this.getLeaderboardUseCase,
  }) : super(const LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());
    final result = await getLeaderboardUseCase.call();
    result.fold(
      (failure) => emit(LeaderboardError(failure.message)),
      (entries) {
        final ranked = entries.asMap().entries.map((e) {
          return e.value.copyWith(rank: e.key + 1);
        }).toList();

        LeaderboardEntry? currentUserEntry;
        if (event.currentUserId.isNotEmpty) {
          final found = ranked.where((e) => e.uid == event.currentUserId);
          if (found.isNotEmpty) {
            currentUserEntry = found.first;
          }
        }

        emit(LeaderboardLoaded(
          entries: ranked,
          currentUserEntry: currentUserEntry,
        ));
      },
    );
  }
}
