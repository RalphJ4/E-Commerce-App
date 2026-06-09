import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/home/domain/entities/product.dart';
import 'package:shopease/features/home/domain/repositories/home_repository.dart';

class GetProductsUseCase {
  final HomeRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call({String? category}) {
    return repository.getProducts(category: category);
  }
}
