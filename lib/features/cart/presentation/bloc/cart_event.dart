import 'package:equatable/equatable.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

final class LoadCart extends CartEvent {
  const LoadCart();
}

final class UpdateQuantity extends CartEvent {
  final String itemId;
  final int quantity;

  const UpdateQuantity({required this.itemId, required this.quantity});

  @override
  List<Object?> get props => [itemId, quantity];
}

final class RemoveItem extends CartEvent {
  final String itemId;
  final CartItemSnapshot? snapshot;

  const RemoveItem({required this.itemId, this.snapshot});

  @override
  List<Object?> get props => [itemId];
}

class CartItemSnapshot {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String variant;

  const CartItemSnapshot({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.variant,
  });
}
