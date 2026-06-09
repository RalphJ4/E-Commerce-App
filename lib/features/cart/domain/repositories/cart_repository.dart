import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/cart/domain/entities/cart_item.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> getCart(String uid);
  Future<Either<Failure, void>> updateItem(
    String uid,
    String itemId,
    int quantity,
  );
  Future<Either<Failure, void>> removeItem(
    String uid,
    String itemId,
  );
}
