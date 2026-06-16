import 'dart:typed_data';
import 'package:dartz/dartz.dart' hide Order;
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/auth/domain/entities/user.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';
import 'package:shopease/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:shopease/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> getProfile(String uid) async {
    try {
      final profile = await remoteDataSource.getProfile(uid);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateAvatar(
      String uid, Uint8List imageBytes) async {
    try {
      final url = await remoteDataSource.uploadAvatar(uid, imageBytes);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrderHistory(String uid) async {
    try {
      final orders = await remoteDataSource.getOrderHistory(uid);
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
