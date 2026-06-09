import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/features/cart/domain/entities/cart_item.dart';
import 'package:shopease/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:shopease/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:shopease/features/cart/domain/usecases/update_cart_item_usecase.dart';
import 'package:shopease/features/cart/presentation/bloc/cart_event.dart';
import 'package:shopease/features/cart/presentation/bloc/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final UpdateCartItemUseCase updateCartItemUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.updateCartItemUseCase,
    required this.removeFromCartUseCase,
  }) : super(const CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<RemoveItem>(_onRemoveItem);
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _onLoadCart(
    LoadCart event,
    Emitter<CartState> emit,
  ) async {
    if (_uid == null) {
      emit(const CartError('User not authenticated'));
      return;
    }
    emit(const CartLoading());
    final result = await getCartUseCase.call(_uid!);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (items) => emit(_computeCartState(items, false)),
    );
  }

  Future<void> _onUpdateQuantity(
    UpdateQuantity event,
    Emitter<CartState> emit,
  ) async {
    if (_uid == null) return;
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final updatedItems = currentState.items.map((item) {
      if (item.id == event.itemId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();
    emit(_computeCartState(updatedItems, currentState.hasActiveStreak));

    final result = await updateCartItemUseCase.call(
      uid: _uid!,
      itemId: event.itemId,
      quantity: event.quantity,
    );
    result.fold(
      (failure) => emit(currentState),
      (_) {},
    );
  }

  Future<void> _onRemoveItem(
    RemoveItem event,
    Emitter<CartState> emit,
  ) async {
    if (_uid == null) return;
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final updatedItems =
        currentState.items.where((item) => item.id != event.itemId).toList();
    emit(_computeCartState(updatedItems, currentState.hasActiveStreak));

    final result = await removeFromCartUseCase.call(
      uid: _uid!,
      itemId: event.itemId,
    );
    result.fold(
      (failure) => emit(currentState),
      (_) {},
    );
  }

  CartLoaded _computeCartState(List<CartItem> items, bool hasActiveStreak) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final discount = hasActiveStreak ? subtotal * 0.1 : 0.0;
    final total = subtotal - discount;
    return CartLoaded(
      items: items,
      subtotal: subtotal,
      discount: discount,
      total: total,
      hasActiveStreak: hasActiveStreak,
    );
  }
}
