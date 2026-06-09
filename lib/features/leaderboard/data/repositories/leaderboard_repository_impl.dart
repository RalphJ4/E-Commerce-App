import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import 'package:shopease/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:shopease/features/leaderboard/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remoteDataSource;

  LeaderboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard() async {
    try {
      final entries = await remoteDataSource.getLeaderboard();
      return Right(entries);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
