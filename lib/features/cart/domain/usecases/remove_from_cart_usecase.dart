import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/cart/domain/repositories/cart_repository.dart';

class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String uid,
    required String itemId,
  }) {
    return repository.removeItem(uid, itemId);
  }
}
