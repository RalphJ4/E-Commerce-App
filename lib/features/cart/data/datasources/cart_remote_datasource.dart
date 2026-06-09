import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopease/core/constants/app_constants.dart';
import 'package:shopease/features/cart/domain/entities/cart_item.dart';
import 'package:shopease/features/home/domain/entities/user_profile.dart';

class CartRemoteDataSource {
  final FirebaseFirestore _firestore;

  CartRemoteDataSource(this._firestore);

  Future<List<CartItem>> getCart(String uid) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('cart')
        .get();

    return snapshot.docs.map((doc) {
      return CartItem.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<void> updateItem(String uid, String itemId, int quantity) async {
    final docRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('cart')
        .doc(itemId);

    if (quantity <= 0) {
      await docRef.delete();
    } else {
      await docRef.update({'quantity': quantity});
    }
  }

  Future<void> removeItem(String uid, String itemId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('cart')
        .doc(itemId)
        .delete();
  }

  Future<UserProfile> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) {
      return UserProfile(uid: uid, displayName: 'User');
    }

    return UserProfile.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }
}
