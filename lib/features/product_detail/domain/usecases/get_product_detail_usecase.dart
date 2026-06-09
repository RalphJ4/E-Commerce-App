import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/home/domain/entities/product.dart';
import 'package:shopease/features/product_detail/domain/repositories/product_detail_repository.dart';

class GetProductDetailUseCase {
  final ProductDetailRepository repository;

  GetProductDetailUseCase(this.repository);

  Future<Either<Failure, Product>> call(String id) {
    return repository.getProduct(id);
  }
}
