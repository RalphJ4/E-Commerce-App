import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopease/core/constants/app_constants.dart';
import 'package:shopease/firebase_options.dart';

final _products = [
  (
    name: 'Wireless Noise-Cancelling Headphones',
    category: 'Electronics',
    price: 249.99,
    rating: 4.7,
    reviewCount: 342,
    isTrending: true,
    imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop',
  ),
  (
    name: 'Organic Green Tea Set',
    category: 'Food',
    price: 29.99,
    rating: 4.5,
    reviewCount: 89,
    isTrending: false,
    imageUrl: 'https://images.unsplash.com/photo-1556881286-fc6915169721?w=400&h=400&fit=crop',
  ),
  (
    name: 'Mechanical Gaming Keyboard',
    category: 'Gaming',
    price: 149.99,
    rating: 4.8,
    reviewCount: 512,
    isTrending: true,
    imageUrl: 'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=400&h=400&fit=crop',
  ),
  (
    name: 'Slim Fit Cotton T-Shirt',
    category: 'Fashion',
    price: 24.99,
    rating: 4.2,
    reviewCount: 176,
    isTrending: false,
    imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
  ),
  (
    name: 'The Art of Clean Code',
    category: 'Books',
    price: 34.99,
    rating: 4.6,
    reviewCount: 203,
    isTrending: true,
    imageUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&h=400&fit=crop',
  ),
  (
    name: '4K Ultra HD Webcam',
    category: 'Electronics',
    price: 129.99,
    rating: 4.3,
    reviewCount: 98,
    isTrending: false,
    imageUrl: 'https://images.unsplash.com/photo-1587826080692-f439cd0b70da?w=400&h=400&fit=crop',
  ),
  (
    name: 'Premium Dark Chocolate Box',
    category: 'Food',
    price: 19.99,
    rating: 4.9,
    reviewCount: 267,
    isTrending: true,
    imageUrl: 'https://images.unsplash.com/photo-1606312619070-d48b4c652a52?w=400&h=400&fit=crop',
  ),
  (
    name: 'Wireless Gaming Mouse',
    category: 'Gaming',
    price: 79.99,
    rating: 4.6,
    reviewCount: 431,
    isTrending: false,
    imageUrl: 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400&h=400&fit=crop',
  ),
  (
    name: 'Denim Jacket Classic',
    category: 'Fashion',
    price: 89.99,
    rating: 4.4,
    reviewCount: 155,
    isTrending: false,
    imageUrl: 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=400&h=400&fit=crop',
  ),
  (
    name: 'Atomic Habits - James Clear',
    category: 'Books',
    price: 14.99,
    rating: 4.9,
    reviewCount: 892,
    isTrending: true,
    imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=400&fit=crop',
  ),
  (
    name: 'Portable Bluetooth Speaker',
    category: 'Electronics',
    price: 59.99,
    rating: 4.4,
    reviewCount: 214,
    isTrending: false,
    imageUrl: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&h=400&fit=crop',
  ),
  (
    name: 'Artisan Coffee Beans 1lb',
    category: 'Food',
    price: 22.99,
    rating: 4.7,
    reviewCount: 143,
    isTrending: false,
    imageUrl: 'https://images.unsplash.com/photo-1559496417-e7f25cb247f3?w=400&h=400&fit=crop',
  ),
  (
    name: 'RGB LED Strip Lights',
    category: 'Gaming',
    price: 39.99,
    rating: 4.1,
    reviewCount: 378,
    isTrending: false,
    imageUrl: 'https://images.unsplash.com/photo-1624365169362-5d259b3bf0ce?w=400&h=400&fit=crop',
  ),
  (
    name: 'Leather Crossbody Bag',
    category: 'Fashion',
    price: 69.99,
    rating: 4.5,
    reviewCount: 89,
    isTrending: true,
    imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400&h=400&fit=crop',
  ),
  (
    name: 'Dune - Frank Herbert',
    category: 'Books',
    price: 12.99,
    rating: 4.8,
    reviewCount: 654,
    isTrending: false,
    imageUrl: 'https://images.unsplash.com/photo-1621351183012-e2f9972dd9bf?w=400&h=400&fit=crop',
  ),
  (
    name: 'Smart Fitness Watch',
    category: 'Electronics',
    price: 199.99,
    rating: 4.5,
    reviewCount: 567,
    isTrending: true,
    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop',
  ),
  (
    name: 'Matcha Powder Ceremonial Grade',
    category: 'Food',
    price: 34.99,
    rating: 4.6,
    reviewCount: 112,
    isTrending: false,
    imageUrl: 'https://images.unsplash.com/photo-1582794543139-8ac9cb41f9a5?w=400&h=400&fit=crop',
  ),
  (
    name: 'Ergonomic Gaming Chair',
    category: 'Gaming',
    price: 399.99,
    rating: 4.3,
    reviewCount: 298,
    isTrending: false,
    imageUrl: 'https://images.unsplash.com/photo-1598550473352-50d81e2c4a42?w=400&h=400&fit=crop',
  ),
  (
    name: 'Cashmere V-Neck Sweater',
    category: 'Fashion',
    price: 129.99,
    rating: 4.7,
    reviewCount: 76,
    isTrending: true,
    imageUrl: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=400&h=400&fit=crop',
  ),
  (
    name: 'Sapiens - Yuval Noah Harari',
    category: 'Books',
    price: 16.99,
    rating: 4.7,
    reviewCount: 445,
    isTrending: false,
    imageUrl: 'https://images.unsplash.com/photo-1491841550275-ad7854e35ca6?w=400&h=400&fit=crop',
  ),
];

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final firestore = FirebaseFirestore.instance;
  await seedProducts(firestore);
}

Future<int> seedProducts(FirebaseFirestore firestore) async {
  final batch = firestore.batch();
  final collection = firestore.collection(AppConstants.productsCollection);

  for (var i = 0; i < _products.length; i++) {
    final p = _products[i];
    final originalPrice = (p.price * (1.1 + (i % 4) * 0.1)).roundToDouble();
    final docRef = collection.doc();

    batch.set(docRef, {
      'name': p.name,
      'description':
          'High-quality ${p.name.toLowerCase()} - perfect for everyday use. Premium design with durable materials.',
      'price': p.price,
      'originalPrice': originalPrice > p.price ? originalPrice : null,
      'imageUrl': p.imageUrl,
      'category': p.category,
      'rating': p.rating,
      'reviewCount': p.reviewCount,
      'isTrending': p.isTrending,
    });
  }

  await batch.commit();
  return _products.length;
}
