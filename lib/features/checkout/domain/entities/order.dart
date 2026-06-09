import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String uid;
  final List<OrderItem> items;
  final String shippingAddress;
  final String paymentMethod;
  final double total;
  final int xpAwarded;
  final String status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.uid,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.total,
    this.xpAwarded = 0,
    this.status = 'pending',
    required this.createdAt,
  });

  Order copyWith({
    String? id,
    String? uid,
    List<OrderItem>? items,
    String? shippingAddress,
    String? paymentMethod,
    double? total,
    int? xpAwarded,
    String? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      total: total ?? this.total,
      xpAwarded: xpAwarded ?? this.xpAwarded,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'items': items.map((e) => e.toMap()).toList(),
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'total': total,
      'xpAwarded': xpAwarded,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      uid: map['uid'] as String? ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      shippingAddress: map['shippingAddress'] as String? ?? '',
      paymentMethod: map['paymentMethod'] as String? ?? '',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      xpAwarded: (map['xpAwarded'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        uid,
        items,
        shippingAddress,
        paymentMethod,
        total,
        xpAwarded,
        status,
        createdAt,
      ];
}

class OrderItem extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [productId, productName, quantity, price];
}
