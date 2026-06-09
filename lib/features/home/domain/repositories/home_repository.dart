import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/home/domain/entities/product.dart';
import 'package:shopease/features/home/domain/entities/user_profile.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<Product>>> getProducts({String? category});
  Future<Either<Failure, UserProfile>> getUserProfile(String uid);
}
