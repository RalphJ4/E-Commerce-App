import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/product_detail/domain/repositories/product_detail_repository.dart';

class AddToCartUseCase {
  final ProductDetailRepository repository;

  AddToCartUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String uid,
    required String productId,
    required int quantity,
    String variant = '',
  }) {
    return repository.addToCart(uid, productId, quantity, variant);
  }
}
