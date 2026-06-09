import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String variant;

  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.variant = '',
  });

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? variant,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      variant: variant ?? this.variant,
    );
  }

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'variant': variant,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, String id) {
    return CartItem(
      id: id,
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      productImage: map['productImage'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      variant: map['variant'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productImage,
        price,
        quantity,
        variant,
      ];
}
