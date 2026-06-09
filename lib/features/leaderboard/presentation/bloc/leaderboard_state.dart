import 'package:equatable/equatable.dart';
import 'package:shopease/features/leaderboard/domain/entities/leaderboard_entry.dart';

sealed class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

final class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

final class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

final class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;

  const LeaderboardLoaded({
    required this.entries,
    this.currentUserEntry,
  });

  @override
  List<Object?> get props => [entries, currentUserEntry];
}

final class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}
