import 'package:equatable/equatable.dart';

sealed class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

final class LoadLeaderboard extends LeaderboardEvent {
  final String currentUserId;

  const LoadLeaderboard({this.currentUserId = ''});

  @override
  List<Object?> get props => [currentUserId];
}
