import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/home/domain/entities/product.dart';

abstract class ProductDetailRepository {
  Future<Either<Failure, Product>> getProduct(String id);
  Future<Either<Failure, void>> addToCart(
    String uid,
    String productId,
    int quantity,
    String variant,
  );
}
