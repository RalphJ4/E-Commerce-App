import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartItemUseCase {
  final CartRepository repository;

  UpdateCartItemUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String uid,
    required String itemId,
    required int quantity,
  }) {
    return repository.updateItem(uid, itemId, quantity);
  }
}
