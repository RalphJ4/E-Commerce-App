import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopease/core/constants/app_constants.dart';
import 'package:shopease/features/home/domain/entities/product.dart';

class ProductDetailRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProductDetailRemoteDataSource(this._firestore);

  Future<Product> getProduct(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(id)
          .get();
      if (doc.exists) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (_) {}

    final product = _mockProducts().where((p) => p.id == id).firstOrNull;
    if (product != null) return product;
    throw Exception('Product not found');
  }

  Future<void> addToCart(
    String uid,
    String productId,
    int quantity,
    String variant,
  ) async {
    Product? product;
    try {
      final doc = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .get();
      if (doc.exists) {
        product = Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (_) {}

    product ??= _mockProducts().where((p) => p.id == productId).firstOrNull;
    if (product == null) throw Exception('Product not found');

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
      await cartRef.add({
        'productId': productId,
        'productName': product.name,
        'productImage': product.imageUrl,
        'price': product.price,
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

  List<Product> _mockProducts() {
    return const [
      Product(
        id: 'mock-1',
        name: 'Wireless Noise-Cancelling Headphones',
        category: 'Electronics',
        price: 249.99,
        originalPrice: 299.99,
        rating: 4.7,
        reviewCount: 342,
        isTrending: true,
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop',
        description: 'High-quality wireless noise-cancelling headphones - perfect for everyday use.',
      ),
      Product(
        id: 'mock-2',
        name: 'Organic Green Tea Set',
        category: 'Food',
        price: 29.99,
        rating: 4.5,
        reviewCount: 89,
        isTrending: false,
        imageUrl: 'https://images.unsplash.com/photo-1556881286-fc6915169721?w=400&h=400&fit=crop',
        description: 'High-quality organic green tea set - perfect for everyday use.',
      ),
      Product(
        id: 'mock-3',
        name: 'Mechanical Gaming Keyboard',
        category: 'Gaming',
        price: 149.99,
        originalPrice: 179.99,
        rating: 4.8,
        reviewCount: 512,
        isTrending: true,
        imageUrl: 'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=400&h=400&fit=crop',
        description: 'High-quality mechanical gaming keyboard - perfect for everyday use.',
      ),
      Product(
        id: 'mock-4',
        name: 'Slim Fit Cotton T-Shirt',
        category: 'Fashion',
        price: 24.99,
        rating: 4.2,
        reviewCount: 176,
        isTrending: false,
        imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
        description: 'High-quality slim fit cotton t-shirt - perfect for everyday use.',
      ),
      Product(
        id: 'mock-5',
        name: 'The Art of Clean Code',
        category: 'Books',
        price: 34.99,
        originalPrice: 42.99,
        rating: 4.6,
        reviewCount: 203,
        isTrending: true,
        imageUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&h=400&fit=crop',
        description: 'High-quality the art of clean code - perfect for everyday use.',
      ),
      Product(
        id: 'mock-6',
        name: '4K Ultra HD Webcam',
        category: 'Electronics',
        price: 129.99,
        rating: 4.3,
        reviewCount: 98,
        isTrending: false,
        imageUrl: 'https://images.unsplash.com/photo-1587826080692-f439cd0b70da?w=400&h=400&fit=crop',
        description: 'High-quality 4k ultra hd webcam - perfect for everyday use.',
      ),
      Product(
        id: 'mock-7',
        name: 'Premium Dark Chocolate Box',
        category: 'Food',
        price: 19.99,
        originalPrice: 24.99,
        rating: 4.9,
        reviewCount: 267,
        isTrending: true,
        imageUrl: 'https://images.unsplash.com/photo-1606312619070-d48b4c652a52?w=400&h=400&fit=crop',
        description: 'High-quality premium dark chocolate box - perfect for everyday use.',
      ),
      Product(
        id: 'mock-8',
        name: 'Wireless Gaming Mouse',
        category: 'Gaming',
        price: 79.99,
        rating: 4.6,
        reviewCount: 431,
        isTrending: false,
        imageUrl: 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400&h=400&fit=crop',
        description: 'High-quality wireless gaming mouse - perfect for everyday use.',
      ),
      Product(
        id: 'mock-9',
        name: 'Denim Jacket Classic',
        category: 'Fashion',
        price: 89.99,
        rating: 4.4,
        reviewCount: 155,
        isTrending: false,
        imageUrl: 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=400&h=400&fit=crop',
        description: 'High-quality denim jacket classic - perfect for everyday use.',
      ),
      Product(
        id: 'mock-10',
        name: 'Atomic Habits - James Clear',
        category: 'Books',
        price: 14.99,
        originalPrice: 19.99,
        rating: 4.9,
        reviewCount: 892,
        isTrending: true,
        imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=400&fit=crop',
        description: 'High-quality atomic habits by james clear - perfect for everyday use.',
      ),
      Product(
        id: 'mock-11',
        name: 'Portable Bluetooth Speaker',
        category: 'Electronics',
        price: 59.99,
        rating: 4.4,
        reviewCount: 214,
        isTrending: false,
        imageUrl: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&h=400&fit=crop',
        description: 'High-quality portable bluetooth speaker - perfect for everyday use.',
      ),
      Product(
        id: 'mock-12',
        name: 'Artisan Coffee Beans 1lb',
        category: 'Food',
        price: 22.99,
        rating: 4.7,
        reviewCount: 143,
        isTrending: false,
        imageUrl: 'https://images.unsplash.com/photo-1559496417-e7f25cb247f3?w=400&h=400&fit=crop',
        description: 'High-quality artisan coffee beans - perfect for everyday use.',
      ),
      Product(
        id: 'mock-13',
        name: 'RGB LED Strip Lights',
        category: 'Gaming',
        price: 39.99,
        rating: 4.1,
        reviewCount: 378,
        isTrending: false,
        imageUrl: 'https://images.unsplash.com/photo-1624365169362-5d259b3bf0ce?w=400&h=400&fit=crop',
        description: 'High-quality rgb led strip lights - perfect for everyday use.',
      ),
      Product(
        id: 'mock-14',
        name: 'Leather Crossbody Bag',
        category: 'Fashion',
        price: 69.99,
        originalPrice: 89.99,
        rating: 4.5,
        reviewCount: 89,
        isTrending: true,
        imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400&h=400&fit=crop',
        description: 'High-quality leather crossbody bag - perfect for everyday use.',
      ),
      Product(
        id: 'mock-15',
        name: 'Dune - Frank Herbert',
        category: 'Books',
        price: 12.99,
        rating: 4.8,
        reviewCount: 654,
        isTrending: false,
        imageUrl: 'https://images.unsplash.com/photo-1621351183012-e2f9972dd9bf?w=400&h=400&fit=crop',
        description: 'High-quality dune by frank herbert - perfect for everyday use.',
      ),
      Product(
        id: 'mock-16',
        name: 'Smart Fitness Watch',
        category: 'Electronics',
        price: 199.99,
        originalPrice: 249.99,
        rating: 4.5,
        reviewCount: 567,
        isTrending: true,
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop',
        description: 'High-quality smart fitness watch - perfect for everyday use.',
      ),
      Product(
        id: 'mock-17',
        name: 'Matcha Powder Ceremonial Grade',
        category: 'Food',
        price: 34.99,
        rating: 4.6,
        reviewCount: 112,
        isTrending: false,
        imageUrl: 'https://images.unsplash.com/photo-1582794543139-8ac9cb41f9a5?w=400&h=400&fit=crop',
        description: 'High-quality matcha powder ceremonial grade - perfect for everyday use.',
      ),
      Product(
        id: 'mock-18',
        name: 'Ergonomic Gaming Chair',
        category: 'Gaming',
        price: 399.99,
        rating: 4.3,
        reviewCount: 298,
        isTrending: false,
        imageUrl: 'https://images.unsplash.com/photo-1598550473352-50d81e2c4a42?w=400&h=400&fit=crop',
        description: 'High-quality ergonomic gaming chair - perfect for everyday use.',
      ),
      Product(
        id: 'mock-19',
        name: 'Cashmere V-Neck Sweater',
        category: 'Fashion',
        price: 129.99,
        originalPrice: 159.99,
        rating: 4.7,
        reviewCount: 76,
        isTrending: true,
        imageUrl: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=400&h=400&fit=crop',
        description: 'High-quality cashmere v-neck sweater - perfect for everyday use.',
      ),
      Product(
        id: 'mock-20',
        name: 'Sapiens - Yuval Noah Harari',
        category: 'Books',
        price: 16.99,
        rating: 4.7,
        reviewCount: 445,
        isTrending: false,
        imageUrl: 'https://images.unsplash.com/photo-1491841550275-ad7854e35ca6?w=400&h=400&fit=crop',
        description: 'High-quality sapiens by yuval noah harari - perfect for everyday use.',
      ),
    ];
  }
}
