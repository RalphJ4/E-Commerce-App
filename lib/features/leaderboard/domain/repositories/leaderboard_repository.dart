import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/leaderboard/domain/entities/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard();
}
