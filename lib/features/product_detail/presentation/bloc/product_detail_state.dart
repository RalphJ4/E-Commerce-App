import 'package:equatable/equatable.dart';
import 'package:shopease/features/home/domain/entities/product.dart';

sealed class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

final class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

final class ProductDetailLoaded extends ProductDetailState {
  final Product product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

final class ProductDetailAddedToCart extends ProductDetailState {
  const ProductDetailAddedToCart();
}

final class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
