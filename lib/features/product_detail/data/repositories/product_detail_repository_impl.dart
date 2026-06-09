import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/home/domain/entities/product.dart';
import 'package:shopease/features/product_detail/data/datasources/product_detail_remote_datasource.dart';
import 'package:shopease/features/product_detail/domain/repositories/product_detail_repository.dart';

class ProductDetailRepositoryImpl implements ProductDetailRepository {
  final ProductDetailRemoteDataSource remoteDataSource;

  ProductDetailRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Product>> getProduct(String id) async {
    try {
      final product = await remoteDataSource.getProduct(id);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(
    String uid,
    String productId,
    int quantity,
    String variant,
  ) async {
    try {
      await remoteDataSource.addToCart(uid, productId, quantity, variant);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
