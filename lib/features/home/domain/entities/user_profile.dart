import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String displayName;
  final String avatarUrl;
  final int xp;
  final int level;
  final int streak;
  final int coins;
  final List<String> badges;
  final int totalOrders;
  final double totalSpent;

  const UserProfile({
    required this.uid,
    required this.displayName,
    this.avatarUrl = '',
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.coins = 0,
    this.badges = const [],
    this.totalOrders = 0,
    this.totalSpent = 0.0,
  });

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? avatarUrl,
    int? xp,
    int? level,
    int? streak,
    int? coins,
    List<String>? badges,
    int? totalOrders,
    double? totalSpent,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      coins: coins ?? this.coins,
      badges: badges ?? this.badges,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'xp': xp,
      'level': level,
      'streak': streak,
      'coins': coins,
      'badges': badges,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      displayName: map['displayName'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      badges: (map['badges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      totalOrders: (map['totalOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (map['totalSpent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        displayName,
        avatarUrl,
        xp,
        level,
        streak,
        coins,
        badges,
        totalOrders,
        totalSpent,
      ];
}
