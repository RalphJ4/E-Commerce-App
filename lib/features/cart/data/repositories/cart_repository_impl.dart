import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:shopease/features/cart/domain/entities/cart_item.dart';
import 'package:shopease/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<CartItem>>> getCart(String uid) async {
    try {
      final items = await remoteDataSource.getCart(uid);
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateItem(
    String uid,
    String itemId,
    int quantity,
  ) async {
    try {
      await remoteDataSource.updateItem(uid, itemId, quantity);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeItem(
    String uid,
    String itemId,
  ) async {
    try {
      await remoteDataSource.removeItem(uid, itemId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
