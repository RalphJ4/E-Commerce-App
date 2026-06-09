import 'package:equatable/equatable.dart';

sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

final class LoadProductDetail extends ProductDetailEvent {
  final String productId;

  const LoadProductDetail(this.productId);

  @override
  List<Object?> get props => [productId];
}

final class AddToCart extends ProductDetailEvent {
  final String productId;
  final int quantity;
  final String variant;

  const AddToCart({
    required this.productId,
    this.quantity = 1,
    this.variant = '',
  });

  @override
  List<Object?> get props => [productId, quantity, variant];
}
