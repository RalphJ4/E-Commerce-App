import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:shopease/core/constants/app_constants.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';
import 'package:shopease/features/auth/domain/entities/user.dart';

abstract class CheckoutRemoteDataSource {
  Future<Order> createOrder(Order order, String uid);
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final FirebaseFirestore firestore;
  final firebase.FirebaseAuth firebaseAuth;

  CheckoutRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<Order> createOrder(Order order, String uid) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final ordersToday = await firestore
        .collection(AppConstants.ordersCollection)
        .where('uid', isEqualTo: uid)
        .where('createdAt',
            isGreaterThanOrEqualTo: todayStart.toIso8601String())
        .get();
    final isFirstOrderToday = ordersToday.docs.isEmpty;

    return await firestore.runTransaction((transaction) async {
      final userRef =
          firestore.collection(AppConstants.usersCollection).doc(uid);
      final userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final user = User.fromMap({...userData, 'uid': uid});

      final orderRef =
          firestore.collection(AppConstants.ordersCollection).doc();

      final totalXpAwarded = order.xpAwarded +
          (isFirstOrderToday ? AppConstants.xpFirstOrderOfDay : 0);
      final newXp = user.xp + totalXpAwarded;
      final newLevel = (newXp / AppConstants.xpPerLevel).floor() + 1;
      final newCoins = user.coins + (order.total ~/ 10);
      final newStreak = isFirstOrderToday ? user.streak + 1 : user.streak;

      final newBadges = List<String>.from(user.badges);
      if (!newBadges.contains('First Purchase')) {
        newBadges.add('First Purchase');
      }
      if (!newBadges.contains('Big Spender') &&
          user.totalSpent + order.total >= 100) {
        newBadges.add('Big Spender');
      }
      if (newLevel >= 5 && !newBadges.contains('Level 5')) {
        newBadges.add('Level 5');
      }
      if (newLevel >= 10 && !newBadges.contains('Level 10')) {
        newBadges.add('Level 10');
      }
      if (newLevel >= 20 && !newBadges.contains('Level 20')) {
        newBadges.add('Level 20');
      }
      if (user.totalOrders + 1 >= 10 && !newBadges.contains('10 Orders')) {
        newBadges.add('10 Orders');
      }
      if (user.totalOrders + 1 >= 50 && !newBadges.contains('50 Orders')) {
        newBadges.add('50 Orders');
      }
      if (newStreak >= 7 && !newBadges.contains('Streak Master')) {
        newBadges.add('Streak Master');
      }

      transaction.set(orderRef,
          order.copyWith(id: orderRef.id, xpAwarded: totalXpAwarded).toMap());

      transaction.update(userRef, {
        'xp': newXp,
        'level': newLevel,
        'streak': newStreak,
        'coins': newCoins,
        'badges': newBadges,
        'totalOrders': FieldValue.increment(1),
        'totalSpent': FieldValue.increment(order.total),
      });

      return order.copyWith(id: orderRef.id, xpAwarded: totalXpAwarded);
    });
  }
}
