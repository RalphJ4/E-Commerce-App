import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final int xp;
  final int level;
  final int streak;
  final int coins;
  final List<String> badges;
  final int totalOrders;
  final double totalSpent;

  const User({
    required this.uid,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.coins = 0,
    this.badges = const ['Welcome'],
    this.totalOrders = 0,
    this.totalSpent = 0.0,
  });

  User copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? avatarUrl,
    int? xp,
    int? level,
    int? streak,
    int? coins,
    List<String>? badges,
    int? totalOrders,
    double? totalSpent,
  }) {
    return User(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
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
      'uid': uid,
      'displayName': displayName,
      'email': email,
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

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      avatarUrl: map['avatarUrl'] as String?,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      badges: map['badges'] != null ? List<String>.from(map['badges'] as List) : ['Welcome'],
      totalOrders: (map['totalOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (map['totalSpent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        displayName,
        email,
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
