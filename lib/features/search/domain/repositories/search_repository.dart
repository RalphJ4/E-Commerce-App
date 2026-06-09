import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/home/domain/entities/product.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<Product>>> searchProducts({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  });
}
