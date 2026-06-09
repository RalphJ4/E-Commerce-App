import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopease/core/constants/app_constants.dart';
import 'package:shopease/features/home/domain/entities/product.dart';
import 'package:shopease/features/home/domain/entities/user_profile.dart';

class HomeRemoteDataSource {
  final FirebaseFirestore _firestore;

  HomeRemoteDataSource(this._firestore);

  Future<List<Product>> getProducts({String? category}) async {
    Query query = _firestore.collection(AppConstants.productsCollection);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
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
