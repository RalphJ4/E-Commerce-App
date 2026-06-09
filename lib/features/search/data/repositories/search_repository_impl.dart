import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/home/domain/entities/product.dart';
import 'package:shopease/features/search/data/datasources/search_remote_datasource.dart';
import 'package:shopease/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Product>>> searchProducts({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    try {
      final products = await remoteDataSource.searchProducts(
        query: query,
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
      );
      return Right(products);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(e.message ?? 'Search failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
