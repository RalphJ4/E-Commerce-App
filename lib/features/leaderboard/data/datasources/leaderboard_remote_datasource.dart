import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopease/core/constants/app_constants.dart';
import 'package:shopease/features/leaderboard/domain/entities/leaderboard_entry.dart';

abstract class LeaderboardRemoteDataSource {
  Future<List<LeaderboardEntry>> getLeaderboard();
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final FirebaseFirestore firestore;

  LeaderboardRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final snapshot = await firestore
        .collection(AppConstants.usersCollection)
        .orderBy('totalSpent', descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return LeaderboardEntry(
        rank: 0,
        uid: doc.id,
        displayName: data['displayName'] as String? ?? 'User',
        avatarUrl: data['avatarUrl'] as String?,
        totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
        level: (data['level'] as num?)?.toInt() ?? 1,
      );
    }).toList();
  }
}
