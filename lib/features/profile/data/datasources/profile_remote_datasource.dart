import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:shopease/core/constants/app_constants.dart';
import 'package:shopease/features/auth/domain/entities/user.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';

abstract class ProfileRemoteDataSource {
  Future<User> getProfile(String uid);
  Future<String> uploadAvatar(String uid, Uint8List imageBytes);
  Future<List<Order>> getOrderHistory(String uid);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final firebase.FirebaseAuth firebaseAuth;

  ProfileRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<User> getProfile(String uid) async {
    final doc = await firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) {
      throw Exception('User not found');
    }

    final data = doc.data()!;
    data['uid'] = uid;
    return User.fromMap(data);
  }

  @override
  Future<String> uploadAvatar(String uid, Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    final dataUri = 'data:image/jpeg;base64,$base64Image';

    await firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'avatarUrl': dataUri});

    return dataUri;
  }

  @override
  Future<List<Order>> getOrderHistory(String uid) async {
    final snapshot = await firestore
        .collection(AppConstants.ordersCollection)
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Order.fromMap(data, doc.id);
    }).toList();
  }
}
