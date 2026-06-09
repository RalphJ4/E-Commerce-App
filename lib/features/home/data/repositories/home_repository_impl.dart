import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/home/data/datasources/home_remote_datasource.dart';
import 'package:shopease/features/home/domain/entities/product.dart';
import 'package:shopease/features/home/domain/entities/user_profile.dart';
import 'package:shopease/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Product>>> getProducts({String? category}) async {
    try {
      final products = await remoteDataSource.getProducts(category: category);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String uid) async {
    try {
      final profile = await remoteDataSource.getUserProfile(uid);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
