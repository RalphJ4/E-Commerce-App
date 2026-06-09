import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  final int rank;
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final double totalSpent;
  final int level;

  const LeaderboardEntry({
    required this.rank,
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.totalSpent,
    required this.level,
  });

  LeaderboardEntry copyWith({
    int? rank,
    String? uid,
    String? displayName,
    String? avatarUrl,
    double? totalSpent,
    int? level,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalSpent: totalSpent ?? this.totalSpent,
      level: level ?? this.level,
    );
  }

  @override
  List<Object?> get props =>
      [rank, uid, displayName, avatarUrl, totalSpent, level];
}
