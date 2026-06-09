import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/cart/domain/entities/cart_item.dart';
import 'package:shopease/features/cart/domain/repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  Future<Either<Failure, List<CartItem>>> call(String uid) {
    return repository.getCart(uid);
  }
}
