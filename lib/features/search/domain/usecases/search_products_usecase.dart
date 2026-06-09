import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/home/domain/entities/product.dart';
import 'package:shopease/features/search/domain/repositories/search_repository.dart';

class SearchProductsUseCase {
  final SearchRepository repository;

  SearchProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) {
    return repository.searchProducts(
      query: query,
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
    );
  }
}
