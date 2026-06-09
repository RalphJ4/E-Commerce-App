import 'package:equatable/equatable.dart';
import 'package:shopease/features/cart/domain/entities/cart_item.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading();
}

final class CartLoaded extends CartState {
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final bool hasActiveStreak;

  const CartLoaded({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.hasActiveStreak = false,
  });

  CartLoaded copyWith({
    List<CartItem>? items,
    double? subtotal,
    double? discount,
    double? total,
    bool? hasActiveStreak,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      hasActiveStreak: hasActiveStreak ?? this.hasActiveStreak,
    );
  }

  @override
  List<Object?> get props => [items, subtotal, discount, total, hasActiveStreak];
}

final class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
