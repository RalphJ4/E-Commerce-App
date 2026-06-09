import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/features/product_detail/domain/usecases/get_product_detail_usecase.dart';
import 'package:shopease/features/product_detail/domain/usecases/add_to_cart_usecase.dart';
import 'package:shopease/features/product_detail/presentation/bloc/product_detail_event.dart';
import 'package:shopease/features/product_detail/presentation/bloc/product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetProductDetailUseCase getProductDetailUseCase;
  final AddToCartUseCase addToCartUseCase;

  ProductDetailBloc({
    required this.getProductDetailUseCase,
    required this.addToCartUseCase,
  }) : super(const ProductDetailInitial()) {
    on<LoadProductDetail>(_onLoadProductDetail);
    on<AddToCart>(_onAddToCart);
  }

  Future<void> _onLoadProductDetail(
    LoadProductDetail event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(const ProductDetailLoading());
    final result = await getProductDetailUseCase.call(event.productId);
    result.fold(
      (failure) => emit(ProductDetailError(failure.message)),
      (product) => emit(ProductDetailLoaded(product)),
    );
  }

  Future<void> _onAddToCart(
    AddToCart event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(const ProductDetailLoading());
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const ProductDetailError('User not authenticated'));
      return;
    }
    final result = await addToCartUseCase.call(
      uid: user.uid,
      productId: event.productId,
      quantity: event.quantity,
      variant: event.variant,
    );
    result.fold(
      (failure) => emit(ProductDetailError(failure.message)),
      (_) => emit(const ProductDetailAddedToCart()),
    );
  }
}
