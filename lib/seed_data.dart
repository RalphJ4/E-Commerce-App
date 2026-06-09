import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

final _products = [
  (
    name: 'Wireless Noise-Cancelling Headphones',
    category: 'Electronics',
    price: 249.99,
    rating: 4.7,
    reviewCount: 342,
    isTrending: true,
  ),
  (
    name: 'Organic Green Tea Set',
    category: 'Food',
    price: 29.99,
    rating: 4.5,
    reviewCount: 89,
    isTrending: false,
  ),
  (
    name: 'Mechanical Gaming Keyboard',
    category: 'Gaming',
    price: 149.99,
    rating: 4.8,
    reviewCount: 512,
    isTrending: true,
  ),
  (
    name: 'Slim Fit Cotton T-Shirt',
    category: 'Fashion',
    price: 24.99,
    rating: 4.2,
    reviewCount: 176,
    isTrending: false,
  ),
  (
    name: 'The Art of Clean Code',
    category: 'Books',
    price: 34.99,
    rating: 4.6,
    reviewCount: 203,
    isTrending: true,
  ),
  (
    name: '4K Ultra HD Webcam',
    category: 'Electronics',
    price: 129.99,
    rating: 4.3,
    reviewCount: 98,
    isTrending: false,
  ),
  (
    name: 'Premium Dark Chocolate Box',
    category: 'Food',
    price: 19.99,
    rating: 4.9,
    reviewCount: 267,
    isTrending: true,
  ),
  (
    name: 'Wireless Gaming Mouse',
    category: 'Gaming',
    price: 79.99,
    rating: 4.6,
    reviewCount: 431,
    isTrending: false,
  ),
  (
    name: 'Denim Jacket Classic',
    category: 'Fashion',
    price: 89.99,
    rating: 4.4,
    reviewCount: 155,
    isTrending: false,
  ),
  (
    name: 'Atomic Habits - James Clear',
    category: 'Books',
    price: 14.99,
    rating: 4.9,
    reviewCount: 892,
    isTrending: true,
  ),
  (
    name: 'Portable Bluetooth Speaker',
    category: 'Electronics',
    price: 59.99,
    rating: 4.4,
    reviewCount: 214,
    isTrending: false,
  ),
  (
    name: 'Artisan Coffee Beans 1lb',
    category: 'Food',
    price: 22.99,
    rating: 4.7,
    reviewCount: 143,
    isTrending: false,
  ),
  (
    name: 'RGB LED Strip Lights',
    category: 'Gaming',
    price: 39.99,
    rating: 4.1,
    reviewCount: 378,
    isTrending: false,
  ),
  (
    name: 'Leather Crossbody Bag',
    category: 'Fashion',
    price: 69.99,
    rating: 4.5,
    reviewCount: 89,
    isTrending: true,
  ),
  (
    name: 'Dune - Frank Herbert',
    category: 'Books',
    price: 12.99,
    rating: 4.8,
    reviewCount: 654,
    isTrending: false,
  ),
  (
    name: 'Smart Fitness Watch',
    category: 'Electronics',
    price: 199.99,
    rating: 4.5,
    reviewCount: 567,
    isTrending: true,
  ),
  (
    name: 'Matcha Powder Ceremonial Grade',
    category: 'Food',
    price: 34.99,
    rating: 4.6,
    reviewCount: 112,
    isTrending: false,
  ),
  (
    name: 'Ergonomic Gaming Chair',
    category: 'Gaming',
    price: 399.99,
    rating: 4.3,
    reviewCount: 298,
    isTrending: false,
  ),
  (
    name: 'Cashmere V-Neck Sweater',
    category: 'Fashion',
    price: 129.99,
    rating: 4.7,
    reviewCount: 76,
    isTrending: true,
  ),
  (
    name: 'Sapiens - Yuval Noah Harari',
    category: 'Books',
    price: 16.99,
    rating: 4.7,
    reviewCount: 445,
    isTrending: false,
  ),
];

Future<void> main() async {
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();
  final collection = firestore.collection('products');

  print('Seeding ${_products.length} products...\n');

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
      'imageUrl': 'https://picsum.photos/seed/product$i/400/400',
      'category': p.category,
      'rating': p.rating,
      'reviewCount': p.reviewCount,
      'isTrending': p.isTrending,
    });

    print(
      '[${i + 1}/${_products.length}] ${p.name} (\$${p.price.toStringAsFixed(2)}) - ${p.category}',
    );
  }

  await batch.commit();
  print('\n✓ Successfully seeded ${_products.length} products to Firestore!');
}
