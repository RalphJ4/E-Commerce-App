import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopease/core/constants/app_constants.dart';
import 'package:shopease/features/home/domain/entities/product.dart';

class ProductDetailRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProductDetailRemoteDataSource(this._firestore);

  Future<Product> getProduct(String id) async {
    final doc =
        await _firestore.collection(AppConstants.productsCollection).doc(id).get();
    if (!doc.exists) {
      throw Exception('Product not found');
    }
    return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> addToCart(
    String uid,
    String productId,
    int quantity,
    String variant,
  ) async {
    final cartRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('cart');

    final existing = await cartRef.where('productId', isEqualTo: productId).get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final currentQty = doc.data()['quantity'] as int? ?? 0;
      await cartRef.doc(doc.id).update({'quantity': currentQty + quantity});
    } else {
      final productDoc =
          await _firestore.collection(AppConstants.productsCollection).doc(productId).get();
      final productData = productDoc.data() as Map<String, dynamic>;

      await cartRef.add({
        'productId': productId,
        'productName': productData['name'] ?? '',
        'productImage': productData['imageUrl'] ?? '',
        'price': productData['price'] ?? 0,
        'quantity': quantity,
        'variant': variant,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({
      'xp': FieldValue.increment(AppConstants.xpPerCartItem * quantity),
    });
  }
}
