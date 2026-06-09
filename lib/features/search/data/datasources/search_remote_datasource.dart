import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopease/core/constants/app_constants.dart';
import 'package:shopease/features/home/domain/entities/product.dart';

class SearchRemoteDataSource {
  final FirebaseFirestore _firestore;

  SearchRemoteDataSource(this._firestore);

  Future<List<Product>> searchProducts({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    Query queryRef = _firestore.collection(AppConstants.productsCollection);

    if (category != null && category.isNotEmpty) {
      queryRef = queryRef.where('category', isEqualTo: category);
    }

    if (minRating != null) {
      queryRef = queryRef.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    final snapshot = await queryRef.get();

    List<Product> products = snapshot.docs.map((doc) {
      return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      products = products
          .where((p) => p.name.toLowerCase().contains(lowerQuery))
          .toList();
    }

    if (minPrice != null) {
      products = products.where((p) => p.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      products = products.where((p) => p.price <= maxPrice).toList();
    }

    return products;
  }
}
