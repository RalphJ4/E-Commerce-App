import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:shopease/features/leaderboard/domain/repositories/leaderboard_repository.dart';

class GetLeaderboardUseCase {
  final LeaderboardRepository repository;

  GetLeaderboardUseCase(this.repository);

  Future<Either<Failure, List<LeaderboardEntry>>> call() {
    return repository.getLeaderboard();
  }
}
