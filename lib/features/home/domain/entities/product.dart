import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isTrending;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    this.isTrending = false,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? imageUrl,
    String? category,
    double? rating,
    int? reviewCount,
    bool? isTrending,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isTrending: isTrending ?? this.isTrending,
    );
  }

  double get discountPercentage {
    if (originalPrice == null || originalPrice == 0) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'isTrending': isTrending,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      imageUrl: map['imageUrl'] as String? ?? '',
      category: map['category'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      isTrending: map['isTrending'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        originalPrice,
        imageUrl,
        category,
        rating,
        reviewCount,
        isTrending,
      ];
}
